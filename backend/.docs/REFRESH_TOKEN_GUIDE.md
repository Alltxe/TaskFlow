# Refresh Token Authentication Guide

## Обзор

Backend использует механизм refresh tokens для обеспечения безопасной и удобной аутентификации пользователей. Система основана на JWT (JSON Web Tokens) с двумя типами токенов:

- **Access Token** - короткоживущий токен (15 минут), используется для авторизации запросов к API
- **Refresh Token** - долгоживущий токен (7 дней), используется для получения нового access token

## Архитектура

### База данных

Модель `RefreshToken` хранит хешированные refresh tokens в базе данных:

```prisma
model RefreshToken {
  id          String   @id @default(cuid())
  tokenHash   String   @unique @map("token_hash")
  expiresAt   DateTime @map("expires_at")
  createdAt   DateTime @default(now()) @map("created_at")
  revokedAt   DateTime? @map("revoked_at")
  userId      String   @map("user_id")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

### Безопасность

- Refresh tokens **хешируются** перед сохранением в БД (bcrypt)
- Access tokens **подписываются** с помощью JWT_SECRET
- Refresh tokens хранятся **только в памяти клиента** (рекомендуется httpOnly cookie)
- При обновлении access token старый refresh token **автоматически отзывается** (rotation)

## GraphQL API

### 1. Регистрация пользователя

```graphql
mutation Register {
  register(input: {
    email: "user@example.com"
    username: "username"
    password: "password123"
  }) {
    accessToken
    refreshToken
    user {
      id
      email
      username
    }
  }
}
```

**Ответ:**
```json
{
  "data": {
    "register": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "a1b2c3d4e5f6...",
      "user": {
        "id": "clxxx...",
        "email": "user@example.com",
        "username": "username"
      }
    }
  }
}
```

### 2. Вход в систему

```graphql
mutation Login {
  login(input: {
    email: "user@example.com"
    password: "password123"
  }) {
    accessToken
    refreshToken
    user {
      id
      email
      username
    }
  }
}
```

### 3. Обновление access token

```graphql
mutation RefreshToken {
  refreshToken(input: {
    refreshToken: "a1b2c3d4e5f6..."
  }) {
    accessToken
    refreshToken
    user {
      id
      email
      username
    }
  }
}
```

**Примечание:** При успешном обновлении возвращается **новый refresh token**. Старый автоматически отзывается.

### 4. Выход из системы (одно устройство)

```graphql
mutation Logout {
  logout(refreshToken: "a1b2c3d4e5f6...")
}
```

**Ответ:** `true` если токен успешно отозван, `false` если токен не найден.

### 5. Выход из всех устройств

```graphql
mutation LogoutAll {
  logoutAll
}
```

**Требует авторизации** (передайте access token в заголовке).

**Ответ:** Количество отозванных токенов (число).

## Использование в клиенте

### Рекомендуемый подход (httpOnly cookies)

**На фронтенде (рекомендация для разработчика клиента):**

1. При получении токенов после login/register:
   - Сохранить `refreshToken` в **httpOnly cookie** (через сервер или proxy)
   - Сохранить `accessToken` в **памяти** (переменная, state management)

2. Для авторизованных запросов:
   - Добавлять `Authorization: Bearer <accessToken>` в заголовки

3. При истечении access token (401 Unauthorized):
   - Отправить запрос `refreshToken` с refresh token из cookie
   - Обновить `accessToken` в памяти
   - Повторить исходный запрос

### Альтернативный подход (localStorage)

**Внимание:** Менее безопасно, но проще в реализации.

```javascript
// После логина
const { accessToken, refreshToken } = await login();
localStorage.setItem('accessToken', accessToken);
localStorage.setItem('refreshToken', refreshToken);

// При запросе
const accessToken = localStorage.getItem('accessToken');
fetch('/graphql', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});

// При 401 Unauthorized
const refreshToken = localStorage.getItem('refreshToken');
const { accessToken: newAccessToken, refreshToken: newRefreshToken } = 
  await refreshTokenMutation(refreshToken);

localStorage.setItem('accessToken', newAccessToken);
localStorage.setItem('refreshToken', newRefreshToken);
```

## Настройка времени жизни токенов

Время жизни токенов настраивается через переменные окружения в `.env`:

```bash
# Access Token (короткоживущий)
JWT_ACCESS_TOKEN_EXPIRES_IN="15m"  # 15 минут

# Refresh Token (долгоживущий)
JWT_REFRESH_TOKEN_EXPIRES_IN="7d"  # 7 дней

# JWT Secret (используйте сложный секретный ключ в продакшене)
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
```

**Поддерживаемые форматы времени:**
- `s` - секунды (например, `300s` = 5 минут)
- `m` - минуты (например, `15m` = 15 минут)
- `h` - часы (например, `24h` = 1 день)
- `d` - дни (например, `7d` = 7 дней)

## Обработка ошибок

### Невалидный или просроченный refresh token

```json
{
  "errors": [
    {
      "message": "Invalid or expired refresh token",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

**Действия клиента:** Перенаправить пользователя на страницу входа.

### Отозванный refresh token

Поведение аналогично просроченному токену. После отзыва (logout) токен больше нельзя использовать.

## Примеры с curl

### Логин и получение токенов

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { login(input: { email: \"user@example.com\", password: \"password123\" }) { accessToken refreshToken user { id email } } }"
  }'
```

### Обновление access token

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { refreshToken(input: { refreshToken: \"YOUR_REFRESH_TOKEN\" }) { accessToken refreshToken } }"
  }'
```

### Авторизованный запрос (получение текущего пользователя)

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "query": "query { me { id email username } }"
  }'
```

### Выход из системы

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { logout(refreshToken: \"YOUR_REFRESH_TOKEN\") }"
  }'
```

## Best Practices

### Для фронтенд-разработчиков

1. **Никогда не храните access token в localStorage/sessionStorage** - используйте переменные в памяти
2. **Храните refresh token в httpOnly cookie** для защиты от XSS
3. **Реализуйте автоматическое обновление токенов** при получении 401
4. **Перенаправляйте на login при невалидном refresh token**
5. **Реализуйте logout на всех устройствах** для критичных действий (смена пароля)

### Для бэкенд-разработчиков

1. **Используйте сложный JWT_SECRET в продакшене** (минимум 32 символа, случайная строка)
2. **Регулярно чистите просроченные refresh tokens** (создайте cron job)
3. **Логируйте попытки использования отозванных токенов** для обнаружения атак
4. **Реализуйте rate limiting** для endpoint'а refreshToken

## Мониторинг и очистка

### Автоматическая очистка просроченных токенов

Рекомендуется создать scheduled job для очистки:

```typescript
// Пример (не реализовано в текущей версии)
@Cron('0 0 * * *') // Каждый день в полночь
async cleanupExpiredTokens() {
  await this.prisma.refreshToken.deleteMany({
    where: {
      expiresAt: {
        lt: new Date()
      }
    }
  });
}
```

### Проверка активных сессий пользователя

```typescript
const activeSessions = await prisma.refreshToken.count({
  where: {
    userId: 'user-id',
    revokedAt: null,
    expiresAt: {
      gt: new Date()
    }
  }
});
```

## Troubleshooting

### Access token истекает слишком быстро

Увеличьте значение `JWT_ACCESS_TOKEN_EXPIRES_IN` в `.env` (не рекомендуется более 60m).

### Refresh token не работает после перезапуска сервера

Проверьте, что БД корректно подключена и таблица `refresh_tokens` существует. Запустите миграции:
```bash
npx prisma migrate dev
```

### "Module has no exported member 'User'" ошибка

Запустите генерацию Prisma Client:
```bash
npx prisma generate
```

## Заключение

Механизм refresh tokens обеспечивает баланс между безопасностью и удобством использования. Access tokens с коротким сроком жизни минимизируют риски при компрометации, а refresh tokens позволяют пользователям оставаться залогиненными длительное время без постоянного ввода пароля.
