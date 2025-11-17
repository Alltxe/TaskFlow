# Аутентификация и обработка токенов в TaskFlow Mobile

## Обзор

Мобильное приложение TaskFlow использует **JWT-токены с автоматическим refresh** для безопасной аутентификации пользователей. Система включает:

- **Access Token** - короткоживущий токен (15 минут), используется для авторизации GraphQL запросов
- **Refresh Token** - долгоживущий токен (7 дней), используется для получения нового access token
- **Автоматический refresh** - при получении 401/UNAUTHENTICATED ошибки токены обновляются прозрачно для пользователя
- **Автологаут** - если refresh token истек или невалиден, пользователь автоматически разлогинивается

---

## Архитектура

### 1. Хранение токенов

Токены хранятся в **flutter_secure_storage** с шифрованием:

```dart
// Secure Storage (FlutterSecureStorage)
- accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
- refreshToken: "a1b2c3d4e5f6..."
- userId: "clxxx..."
```

**Важно:**
- Токены **не хранятся в SharedPreferences** или localStorage
- Используется **encryptedSharedPreferences** на Android для дополнительной защиты
- Токены **не логируются** в production

### 2. GraphQL Client с автоматическим refresh

GraphQL клиент настроен с цепочкой Links:

```
ErrorLink → RefreshTokenLink → AuthLink → HttpLink
```

**Как это работает:**

1. **AuthLink** - добавляет `Authorization: Bearer <accessToken>` к каждому запросу
2. **RefreshTokenLink** - перехватывает 401/UNAUTHENTICATED ошибки и автоматически обновляет токены
3. **ErrorLink** - логирует ошибки для отладки
4. **HttpLink** - отправляет запросы на backend

### 3. Автоматический refresh токена (RefreshTokenLink)

При получении 401/UNAUTHENTICATED ошибки:

```dart
1. Перехватывается ошибка UNAUTHENTICATED
2. Читается refreshToken из secure storage
3. Отправляется GraphQL mutation refreshToken
4. Получаются новые accessToken и refreshToken
5. Новые токены сохраняются в secure storage
6. Исходный запрос повторяется с новым accessToken
7. Ответ возвращается пользователю (прозрачно)
```

**Если refresh не удался:**
```dart
1. Все токены удаляются из secure storage
2. Пользователь перенаправляется на экран входа
3. В консоли логируется причина ошибки
```

---

## GraphQL Mutations

### 1. Логин

```graphql
mutation Login($input: LoginInput!) {
  login(input: $input) {
    accessToken
    refreshToken
    user {
      id
      email
      username
      avatarUrl
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

### 2. Регистрация

```graphql
mutation Register($input: RegisterInput!) {
  register(input: $input) {
    accessToken
    refreshToken
    user {
      id
      email
      username
      avatarUrl
    }
  }
}
```

### 3. Refresh Token (автоматический)

```graphql
mutation RefreshToken($input: RefreshTokenInput!) {
  refreshToken(input: $input) {
    accessToken
    refreshToken
    user {
      id
    }
  }
}
```

**Важно:** Старый refresh token становится невалидным после успешного обновления (token rotation).

### 4. Логаут

```graphql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```

### 5. Логаут со всех устройств

```graphql
mutation LogoutAll {
  logoutAll
}
```

**Требует:** Авторизация (access token в заголовке)

---

## Реализация

### 1. Data Layer

**AuthRemoteDataSource** (`lib/data/datasources/auth_remote_datasource.dart`):
- Отправляет GraphQL mutations для login, register, refreshToken
- Использует **input: { refreshToken }** формат (backend API v1.1)
- Возвращает `AuthTokens` с рассчитанными expiresAt датами

**AuthLocalDataSource** (`lib/data/datasources/auth_local_datasource.dart`):
- Сохраняет/читает токены из FlutterSecureStorage
- Проверяет истечение токенов (isAccessTokenExpired, isRefreshTokenExpired)
- Очищает все данные при logout

**AuthRepository** (`lib/data/repositories/auth_repository_impl.dart`):
- Координирует remote и local data sources
- Реализует login, register, logout, refreshToken методы
- Проверяет валидность токенов перед запросами

### 2. GraphQL Provider

**RefreshTokenLink** (`lib/data/providers/graphql_provider.dart`):
- Кастомный GraphQL Link для автоматического refresh
- Перехватывает UNAUTHENTICATED/401 ошибки
- Автоматически обновляет токены и повторяет запрос
- Очищает сессию при неудачном refresh

**Цепочка Links:**
```dart
Link.from([errorLink, refreshTokenLink, authLink, httpLink])
```

### 3. Auth Providers (Riverpod)

**authRepositoryProvider** (`lib/data/providers/auth_providers.dart`):
- Provider для AuthRepository
- Dependency injection для remote и local data sources

---

## Обработка ошибок

### 1. Access Token истек (401/UNAUTHENTICATED)

**Поведение:**
```
1. RefreshTokenLink перехватывает ошибку
2. Автоматически обновляет токены через refreshToken mutation
3. Повторяет исходный запрос с новым access token
4. Пользователь не замечает проблемы
```

**Лог:**
```
[Auth] Access token expired, attempting refresh...
[Auth] Token refreshed successfully, retrying request
```

### 2. Refresh Token истек или невалиден

**Поведение:**
```
1. RefreshTokenLink пытается обновить токены
2. Backend возвращает ошибку "Invalid or expired refresh token"
3. RefreshTokenLink очищает все токены
4. Пользователь видит экран входа
```

**Лог:**
```
[Auth] Access token expired, attempting refresh...
[Auth] Refresh mutation failed: Invalid or expired refresh token
[Auth] Session cleared
```

### 3. Нет refresh token в хранилище

**Поведение:**
```
1. RefreshTokenLink не находит refresh token
2. Сразу очищает сессию
3. Пользователь перенаправляется на login
```

**Лог:**
```
[Auth] Access token expired, attempting refresh...
[Auth] No refresh token found, clearing session
[Auth] Session cleared
```

---

## Использование в коде

### 1. Проверка аутентификации

```dart
final authRepository = ref.read(authRepositoryProvider);

// Проверить, авторизован ли пользователь
final isAuth = await authRepository.isAuthenticated();
if (!isAuth) {
  // Redirect to login
}

// Проверить, нужно ли обновить access token
final needsRefresh = await authRepository.needsTokenRefresh();
if (needsRefresh) {
  await authRepository.refreshToken();
}
```

### 2. Логин

```dart
final authRepository = ref.read(authRepositoryProvider);

try {
  final authResponse = await authRepository.login(
    LoginRequest(email: email, password: password),
  );
  
  // Токены автоматически сохранены в secure storage
  // Переход на главный экран
  context.go('/home');
} on AuthException catch (e) {
  // Неверные учетные данные
  showError(e.message);
} on NetworkException {
  showError('Проблема с сетью');
}
```

### 3. Логаут

```dart
final authRepository = ref.read(authRepositoryProvider);

await authRepository.logout();
// Все токены удалены, переход на login
context.go('/login');
```

### 4. Авторизованные GraphQL запросы

```dart
// Не требуется ручная установка токенов!
// AuthLink автоматически добавляет Authorization заголовок

final result = await client.query(
  QueryOptions(document: gql(query)),
);

// Если access token истек - RefreshTokenLink автоматически обновит
```

---

## Безопасность

### Best Practices

✅ **Используется:**
- FlutterSecureStorage с шифрованием для хранения токенов
- Token rotation (старый refresh token отзывается после обновления)
- Автоматический logout при невалидном refresh token
- HTTPS для всех запросов (production)
- Логирование только в debug режиме

❌ **Не используется:**
- localStorage/SharedPreferences для токенов
- Хранение паролей в памяти
- Логирование токенов в production

### Рекомендации для разработчиков

1. **Никогда не логируйте токены в production:**
   ```dart
   if (kDebugMode) {
     debugPrint('[Auth] Token: $accessToken');
   }
   ```

2. **Проверяйте isAuthenticated() перед защищенными экранами:**
   ```dart
   final isAuth = await authRepository.isAuthenticated();
   if (!isAuth) {
     context.go('/login');
     return;
   }
   ```

3. **Обрабатывайте AuthException отдельно от других ошибок:**
   ```dart
   try {
     // ...
   } on AuthException catch (e) {
     // Redirect to login
   } on NetworkException {
     // Show retry button
   }
   ```

4. **Не вызывайте refreshToken вручную:**
   - RefreshTokenLink делает это автоматически
   - Ручной вызов может привести к race conditions

---

## Отладка

### Логи

**Успешный refresh:**
```
[Auth] Access token expired, attempting refresh...
[Auth] Token refreshed successfully, retrying request
```

**Неудачный refresh:**
```
[Auth] Access token expired, attempting refresh...
[Auth] Refresh mutation failed: Invalid or expired refresh token
[Auth] Session cleared
```

**GraphQL ошибки:**
```
[GraphQL Error] Invalid credentials (UNAUTHENTICATED)
[GraphQL Error] Validation error (BAD_REQUEST)
```

### Проверка токенов в DevTools

```dart
// В debug режиме можно проверить токены:
final storage = ref.read(secureStorageProvider);
final accessToken = await storage.read(key: 'access_token');
final refreshToken = await storage.read(key: 'refresh_token');

print('Access: ${accessToken?.substring(0, 20)}...');
print('Refresh: ${refreshToken?.substring(0, 20)}...');
```

### Тестирование истечения токенов

**Backend для тестов:**
```bash
# Установить короткий TTL для access token (30 секунд)
JWT_ACCESS_TOKEN_EXPIRES_IN="30s"
```

**Проверить автоматический refresh:**
1. Авторизуйтесь в приложении
2. Подождите 35 секунд
3. Выполните любой GraphQL запрос
4. Проверьте логи - должен быть автоматический refresh

---

## Roadmap

### Планируется

- [ ] Биометрическая аутентификация (Face ID/Touch ID)
- [ ] Remember me (опциональное продление refresh token до 30 дней)
- [ ] Мультиакаунт (несколько пользователей на одном устройстве)
- [ ] Session management UI (активные сессии, logout с других устройств)

### В разработке

- [x] Автоматический refresh токенов
- [x] Автологаут при истекшем refresh token
- [x] Безопасное хранение токенов

---

## Ссылки

- **Backend PRD:** `backend.docs/PRD.md`
- **Backend API:** `backend.docs/API_DOCUMENTATION.md`
- **Backend Refresh Token Guide:** `backend.docs/REFRESH_TOKEN_GUIDE.md`
- **Mobile PRD:** `.docs/PRD.md`
- **Mobile Roadmap:** `.docs/ROADMAP.md`
