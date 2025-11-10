# Руководство по тестированию TaskFlow Mobile

## 🐛 Исправленные проблемы

### 1. **Критическая ошибка авторизации**
**Проблема**: GraphQL мутации использовали неправильные параметры (`passwordHash` вместо `password`)
**Решение**: Исправлены параметры в `auth_remote_datasource.dart` согласно `schema.gql`:
- ✅ `login(input: {email: $email, password: $password})`
- ✅ `register(input: {email: $email, username: $username, password: $password})`
- ✅ Обновлена модель `User` (добавлены поля `isAway`, `awayUntil` вместо `isActive`)

---

## 🌐 Тестирование через Web (БЫСТРЕЕ И УДОБНЕЕ)

### Преимущества тестирования в браузере:
- ⚡ **Мгновенный запуск** - не нужно ждать запуска эмулятора
- 🔄 **Hot Reload** работает быстрее
- 🛠️ **Dev Tools** браузера для отладки сети и GraphQL запросов
- 🖥️ **Легкая отладка** - можно использовать Chrome DevTools

### Способ 1: Запуск из VS Code (РЕКОМЕНДУЕТСЯ)

1. **Запустите бэкенд** (если локальный):
   ```powershell
   cd ..\backend
   npm run dev
   ```

2. **В VS Code нажмите F5** и выберите конфигурацию:
   - `TaskFlow Mobile (Chrome - Local Backend)` - для локального бэкенда на `http://localhost:3000`
   - `TaskFlow Mobile (Chrome - Remote Backend)` - для удаленного сервера

3. **Приложение откроется в Chrome** по адресу `http://localhost:8080`

### Способ 2: Запуск через терминал

```powershell
# Локальный бэкенд
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000

# Удаленный бэкенд
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=https://your-backend-url.com
```

### Способ 3: Build для production

```powershell
# Создать web build
flutter build web --release --dart-define=API_BASE_URL=https://your-backend-url.com

# Запустить локальный сервер для тестирования
cd build\web
python -m http.server 8080
# Или используйте любой другой HTTP сервер
```

---

## 📱 Тестирование на Android эмуляторе

### Предварительные требования:
- Android Studio установлен
- Эмулятор создан (AVD)
- Бэкенд доступен по сети

### Запуск:

```powershell
# Проверить доступные устройства
flutter devices

# Запустить на эмуляторе
flutter run

# Для локального бэкенда используйте 10.0.2.2 вместо localhost:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

**⚠️ ВАЖНО для Android эмулятора**:
- `localhost` НЕ работает - используйте `10.0.2.2` (это IP хост-машины из эмулятора)
- Убедитесь, что бэкенд слушает `0.0.0.0`, а не только `127.0.0.1`

---

## 🧪 Интеграционные тесты

### Обновленные тесты (с реальным бэкендом)

```powershell
# Убедитесь что бэкенд запущен!
cd ..\backend
npm run dev

# В другом терминале запустите тесты:
cd ..\mobile
flutter test integration_test/auth_flow_test.dart
```

### Widget тесты (без бэкенда)

```powershell
# Тесты UI компонентов (не требуют бэкенд)
flutter test test/presentation/screens/auth/login_screen_test.dart
flutter test test/presentation/screens/auth/register_screen_test.dart
```

---

## 🔧 Настройка бэкенда для CORS (если используете web)

Если вы тестируете через web, бэкенд должен разрешать CORS запросы.

### В вашем NestJS бэкенде (`main.ts`):

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Включить CORS для web приложения
  app.enableCors({
    origin: [
      'http://localhost:8080',  // Flutter web dev server
      'http://127.0.0.1:8080',
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  await app.listen(3000, '0.0.0.0'); // Важно: слушать на 0.0.0.0
}
bootstrap();
```

---

## 🐞 Отладка GraphQL запросов

### В Chrome DevTools:

1. Откройте приложение в Chrome (`F12` для DevTools)
2. Перейдите во вкладку **Network**
3. Фильтр: `graphql` или `XHR`
4. Попробуйте войти/зарегистрироваться
5. Проверьте:
   - **Request Headers** - есть ли `Authorization: Bearer ...`
   - **Request Payload** - правильные ли переменные (`password`, а не `passwordHash`)
   - **Response** - что вернул сервер (токены, ошибки)

### Проверка ответа от сервера:

```json
// ✅ Успешный login/register
{
  "data": {
    "login": {
      "accessToken": "eyJhbGc...",
      "refreshToken": "eyJhbGc...",
      "user": {
        "id": "123",
        "email": "test@example.com",
        "username": "testuser",
        "avatarUrl": null,
        "isAway": false,
        "awayUntil": null,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z"
      }
    }
  }
}

// ❌ Ошибка (неправильный пароль)
{
  "errors": [
    {
      "message": "Invalid credentials",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

---

## 📝 Быстрая проверка исправлений

### 1. Проверка GraphQL мутации:

```dart
// ✅ ПРАВИЛЬНО (после исправления)
mutation Login($email: String!, $password: String!) {
  login(input: {email: $email, password: $password}) {
    accessToken
    refreshToken
    user { ... }
  }
}

// ❌ НЕПРАВИЛЬНО (старая версия)
mutation Login($email: String!, $passwordHash: String!) {
  login(input: {email: $email, passwordHash: $passwordHash}) { ... }
}
```

### 2. Проверка модели User:

```dart
// ✅ ПРАВИЛЬНО (после исправления)
class User {
  final bool isAway;
  final DateTime? awayUntil;
  // ...
}

// ❌ НЕПРАВИЛЬНО (старая версия)
class User {
  final bool isActive;
  // ...
}
```

---

## 🚀 Пошаговая инструкция для первого запуска

1. **Убедитесь что бэкенд работает**:
   ```powershell
   cd C:\projects\TaskFlow\backend
   npm run dev
   ```
   Проверьте: `http://localhost:3000/graphql` должен открыть GraphQL Playground

2. **Запустите мобильное приложение в Chrome**:
   ```powershell
   cd C:\projects\TaskFlow\mobile
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
   ```

3. **Попробуйте зарегистрироваться**:
   - Email: `test@example.com`
   - Username: `testuser`
   - Password: `password123`

4. **Если регистрация не работает**:
   - Откройте Chrome DevTools (F12)
   - Network → фильтр `graphql`
   - Проверьте запрос и ответ сервера
   - Убедитесь что CORS настроен на бэкенде

---

## ⚡ Рекомендуемый workflow разработки

1. **Разработка и отладка UI**: используйте **Chrome** (быстро, удобно)
2. **Тестирование нативных функций** (камера, уведомления): используйте **Android эмулятор**
3. **Финальное тестирование**: тестируйте на **реальном устройстве**

---

## 🔍 Частые проблемы и решения

| Проблема | Решение |
|----------|---------|
| `SocketException: Connection refused` | Бэкенд не запущен или неправильный URL |
| `GraphQL Error: Field 'login' not found` | Бэкенд не поддерживает GraphQL или неправильный endpoint |
| `CORS error` в браузере | Настройте CORS на бэкенде (см. выше) |
| `Invalid credentials` | Проверьте что пользователь существует в БД |
| Приложение зависает на splash screen | Проверьте что `authStateProvider` правильно обрабатывает ошибки |

---

## 📞 Следующие шаги

После успешной авторизации:
1. ✅ Проверьте что токены сохраняются (`flutter_secure_storage`)
2. ✅ Проверьте редирект на главный экран
3. ✅ Проверьте что API запросы включают `Authorization` header
4. ✅ Протестируйте logout

---

**Создано**: 2024-11-10  
**Версия**: 1.0  
**Статус**: ✅ Критические ошибки авторизации исправлены
