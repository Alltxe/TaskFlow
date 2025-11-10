# Быстрое руководство: Тестирование авторизации

## 🚀 Запуск для тестирования

### Вариант 1: Web (РЕКОМЕНДУЕТСЯ для быстрой разработки)

```powershell
# 1. Запустите бэкенд (в отдельном терминале)
cd C:\projects\TaskFlow\backend
npm run dev

# 2. Запустите Flutter в Chrome
cd C:\projects\TaskFlow\mobile
flutter run -d chrome --web-port=8080
```

### Вариант 2: Android Эмулятор

```powershell
# Важно: для Android используйте 10.0.2.2 вместо localhost
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

---

## ✅ Что было исправлено

### Критическая ошибка #1: Неправильные параметры GraphQL

**Было** в `auth_remote_datasource.dart`:
```dart
mutation Login($email: String!, $passwordHash: String!) {
  login(input: {email: $email, passwordHash: $passwordHash}) { ... }
}
```

**Стало** (согласно `schema.gql`):
```dart
mutation Login($email: String!, $password: String!) {
  login(input: {email: $email, password: $password}) { ... }
}
```

### Критическая ошибка #2: Неправильная модель User

**Было**:
```dart
class User {
  final bool isActive;
  // ...
}
```

**Стало** (согласно `schema.gql`):
```dart
class User {
  final bool isAway;
  final DateTime? awayUntil;
  // ...
}
```

### Добавлено: Поддержка Web платформы

- ✅ Создана папка `web/` с необходимыми файлами
- ✅ Добавлены конфигурации запуска в `.vscode/launch.json`
- ✅ Настроены параметры для локального и удаленного бэкенда

---

## 🧪 Тестовые данные

### Для регистрации нового пользователя:

```
Email: test@example.com
Username: testuser
Password: password123
```

### Для тестирования валидации:

❌ **Невалидные данные** (должны показываться ошибки):
- Email без @: `testexample.com`
- Короткий пароль: `pass`
- Несовпадающие пароли в Confirm Password

✅ **Валидные данные**:
- Email: `test@example.com`
- Password: минимум 8 символов

---

## 🔍 Как проверить что исправления работают

### 1. Откройте Chrome DevTools (F12) во время работы приложения

### 2. Перейдите во вкладку Network

### 3. Попробуйте зарегистрироваться

### 4. Найдите запрос `graphql` и проверьте:

**Request Payload** должен содержать:
```json
{
  "operationName": "Register",
  "variables": {
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123"  // ✅ НЕ passwordHash!
  },
  "query": "mutation Register($email: String!, $username: String!, $password: String!) { ... }"
}
```

**Response** (успешная регистрация):
```json
{
  "data": {
    "register": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "some-uuid",
        "email": "test@example.com",
        "username": "testuser",
        "avatarUrl": null,
        "isAway": false,        // ✅ НЕ isActive!
        "awayUntil": null,
        "createdAt": "2024-11-10T...",
        "updatedAt": "2024-11-10T..."
      }
    }
  }
}
```

---

## 🐞 Возможные проблемы и решения

### Проблема: "Connection refused" или "Network error"

**Решение**:
1. Убедитесь что бэкенд запущен: `http://localhost:3000/graphql` должен открываться
2. Проверьте URL в `lib/core/config/app_config.dart`
3. Для Android используйте `10.0.2.2:3000` вместо `localhost:3000`

### Проблема: CORS ошибка в браузере

**Решение**: Добавьте в бэкенд (`backend/src/main.ts`):
```typescript
app.enableCors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true,
});
```

### Проблема: "Invalid credentials" даже с правильным паролем

**Возможные причины**:
1. Пользователь не существует в БД (попробуйте зарегистрироваться заново)
2. Бэкенд использует хэширование пароля (проверьте бэкенд код)
3. Email/пароль введены с ошибкой

### Проблема: Приложение зависает на Splash Screen

**Решение**: Проверьте консоль на ошибки. Возможно:
1. Бэкенд недоступен
2. Ошибка в `authStateProvider`
3. Неправильный формат токена в storage

---

## 📝 Чеклист перед тестированием

- [ ] Бэкенд запущен и доступен (`http://localhost:3000/graphql`)
- [ ] CORS настроен на бэкенде (если используете web)
- [ ] Flutter dependencies установлены (`flutter pub get`)
- [ ] Freezed код сгенерирован (`dart run build_runner build`)
- [ ] Chrome установлен (для web тестирования)

---

## 🎯 Следующие шаги после успешной авторизации

1. ✅ Проверить что токены сохранились
   - Откройте DevTools → Application → IndexedDB → flutter_secure_storage
   
2. ✅ Проверить редирект на главный экран
   - После логина должен открыться `/home` или `/tasks`

3. ✅ Проверить logout
   - Токены должны удалиться
   - Редирект на `/login`

4. ✅ Проверить refresh token
   - При истечении access token должен автоматически обновляться

---

## 💡 Полезные команды

```powershell
# Очистить кэш и build
flutter clean
flutter pub get

# Перегенерировать freezed код
dart run build_runner build --delete-conflicting-outputs

# Запустить widget тесты
flutter test

# Запустить integration тесты (требует запущенный бэкенд)
flutter test integration_test/auth_flow_test.dart

# Посмотреть доступные устройства
flutter devices

# Остановить все запущенные Flutter приложения
flutter run --stop
```

---

**Последнее обновление**: 2024-11-10  
**Статус**: ✅ Готово к тестированию
