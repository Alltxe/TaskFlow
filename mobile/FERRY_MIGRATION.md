# Ferry Migration Guide

## Статус миграции

**Дата:** 2026-02-17
**Статус:** В процессе (Auth datasource мигрирован)

## Что сделано

### 1. Конфигурация зависимостей ✅
- Обновлены Ferry пакеты в `pubspec.yaml`:
  - `ferry: ^0.16.1+2`
  - `ferry_flutter: ^0.9.1+1`
  - `ferry_cache: ^0.10.1`
  - `ferry_generator: ^0.12.0`
  - `built_value: ^8.9.0`
  - `built_value_generator: ^8.9.0`

### 2. Конфигурация build.yaml ✅
- Настроен `build.yaml` для Ferry code generation
- Ferry автоматически обнаруживает `.graphql` файлы

### 3. Ferry Client Configuration ✅
- Создан `lib/core/config/ferry_client.dart` с:
  - HTTP Link для GraphQL запросов
  - Auth Link для автоматического добавления JWT токенов  
  - Cache для Ferry
  - Singleton pattern для client

### 4. Ferry Provider ✅
- Создан `lib/data/providers/ferry_provider.dart`
- Предоставляет Ferry Client через Riverpod

### 5. Auth Data Source Migration ✅
- Мигрирован `lib/data/datasources/auth_remote_datasource.dart`
- Использует Ferry Client напрямую с `gql_exec.Request`
- Все методы (login, register, refreshToken, logout, changePassword, getCurrentUser)

### 6. Auth Providers Update ✅
- Обновлен `lib/data/providers/auth_providers.dart`
- Использует `ferryClientProvider` вместо `graphqlClientProvider`

## Что нужно доделать

### 1. Регенерация Freezed моделей
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Миграция остальных datasources
- `lib/data/datasources/group_remote_datasource.dart`
- `lib/data/datasources/task_remote_datasource.dart`
- `lib/data/datasources/profile_remote_datasource.dart`
- `lib/data/datasources/reward_remote_datasource.dart`

Используйте `auth_remote_datasource.dart` как template.

### 3. Обновление main.dart
Заменить `graphql_flutter` import на Ferry:

```dart
// Старое:
import 'package:graphql_flutter/graphql_flutter.dart';

// Новое:
import 'package:ferry/ferry.dart';
import 'package:taskflow/core/config/ferry_client.dart';

// В initState удалить инициализацию GraphQL:
// await initHiveForFlutter(); // Удалить

// Добавить инициализацию Ferry client (если нужно):
FerryClientConfig.getClient(); // Опционально
```

### 4. Удаление старых зависимостей
После миграции всех datasources удалить из `pubspec.yaml`:
```yaml
# Удалить эти строки:
graphql_flutter: ^5.1.2
```

### 5. Удаление старых файлов
```bash
# Удалить graphql_provider.dart если больше не используется
rm lib/data/providers/graphql_provider.dart

# Удалить бэкапы
rm lib/data/datasources/auth_remote_datasource_old.dart
```

## Паттерн миграции для других datasources

### Шаблон Ferry DataSource

```dart
import 'package:ferry/ferry.dart';
import 'package:gql_exec/gql_exec.dart' as gql_exec;
import 'package:gql/language.dart' as gql_lang;
import 'package:taskflow/core/config/ferry_client.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;

class MyRemoteDataSource {
  final Client client;

  MyRemoteDataSource({Client? client})
      : client = client ?? FerryClientConfig.getClient();

  Future<MyModel> myQuery() async {
    const queryString = r'''
      query MyQuery {
        myQuery {
          id
          name
        }
      }
    ''';

    try {
      final gqlRequest = gql_exec.Request(
        operation: gql_exec.Operation(
          document: gql_lang.parseString(queryString),
          operationName: 'MyQuery',
        ),
      );

      final response = await client.request(gqlRequest).first;

      if (response.hasErrors) {
        _handleGraphQLErrors(response.graphqlErrors);
      }

      final data = response.data?['myQuery'];
      if (data == null) {
        throw const app_exceptions.ServerException(
          message: 'Query failed: No data returned',
        );
      }

      return MyModel.fromJson(data as Map<String, dynamic>);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Query error: ${e.toString()}',
      );
    }
  }

  void _handleGraphQLErrors(List<gql_exec.GraphQLError>? errors) {
    if (errors == null || errors.isEmpty) return;
    
    final message = errors.first.message;
    
    if (message.toLowerCase().contains('unauthorized')) {
      throw app_exceptions.AuthenticationException(message: message);
    }
    
    throw app_exceptions.ServerException(message: message);
  }
}
```

### Обновление Providers

```dart
// Старое:
final myDataSourceProvider = Provider<MyRemoteDataSource>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return MyRemoteDataSource(client);
});

// Новое:
final myDataSourceProvider = Provider<MyRemoteDataSource>((ref) {
  final client = ref.watch(ferryClientProvider);
  return MyRemoteDataSource(client: client);
});
```

## Важные примечания

### 1. Именование импортов
Используйте алиасы для избежания конфликтов имен:
```dart
import 'package:gql_exec/gql_exec.dart' as gql_exec;
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
```

### 2. Type Casting
Всегда используйте явный casting для GraphQL response data:
```dart
data['user'] as Map<String, dynamic>
data['accessToken'] as String
```

### 3. Error Handling
Ferry возвращает ошибки в `response.graphqlErrors`, а не в exception.
Всегда проверяйте `response.hasErrors` перед доступом к data.

### 4. GraphQL операции
Используйте raw strings (r'''''') для GraphQL queries/mutations:
```dart
const queryString = r'''
  query MyQuery {
    ...
  }
''';
```

## Тестирование после миграции

1. **Проверка компиляции:**
   ```bash
   flutter analyze
   ```

2. **Запуск тестов:**
   ```bash
   flutter test
   ```

3. **Функциональное тестирование:**
   - Логин / регистрация
   - Автоматический refresh токенов
   - Logout
   - Основные CRUD операции

## Rollback Plan

Если миграция вызывает критические проблемы:

1. Восстановить старые файлы из бэкапов
2. Вернуть `graphql_flutter` в pubspec.yaml
3. Вернуть старые providers
4. Запустить `flutter pub get`

## Контакты / Ресурсы

- **Ferry Documentation:** https://ferrygraphql.com/
- **Ferry GitHub:** https://github.com/gql-dart/ferry
- **Migration Status:** См. этот файл

---

**Последнее обновление:** 2026-02-17  
**Автор:** Claude (AI Assistant)
