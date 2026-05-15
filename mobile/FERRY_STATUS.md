# Ferry Migration - Current Status

## ✅ Полностью завершено

1. **Ferry Dependencies** - Установлены и обновлены все пакеты Ferry
2. **Ferry Client (`lib/core/config/ferry_client.dart`)** - Создан клиент с Auth Link
3. **Ferry Provider (`lib/data/providers/ferry_provider.dart`)** - Riverpod provider для Ferry
4. **Auth DataSource Migration** - `auth_remote_datasource.dart` полностью мигрирован на Ferry
5. **Auth Providers Update** - `auth_providers.dart` обновлен для использования Ferry
6. **Migration Documentation** - Создан `FERRY_MIGRATION.md` с подробной документацией

## ❗ Текущая проблема: Freezed Code Generation

### Проблема
Build runner генерирует только 4 из ~30 freezed файлов:
- `point_balance.freezed.dart` ✅
- `point_transaction.freezed.dart` ✅
- `point_transaction_history.freezed.dart` ✅
- `request_reward_input.freezed.dart` ✅

НЕ генерируются:
- `login_request.freezed.dart` ❌
- `auth_response.freezed.dart` ❌
- `register_request.freezed.dart` ❌
- И другие ~25 файлов ❌

### Симптомы в анализе кода
```
error - The getter 'email' isn't defined for the type 'LoginRequest'
error - The getter 'password' isn't defined for the type 'LoginRequest'
```

### Попытки решения
1. ✅ `flutter pub run build_runner clean` + rebuild
2. ✅ `--delete-conflicting-outputs`
3. ❌ `--build-filter` для конкретного файла (0 outputs)
4. ❌ Verbose mode debugging

### Возможные причины
1. Freezed и build_runner версии (2.5.2 и 2.4.13) могут быть несовместимы
2. Кэш build_runner поврежден
3. Part директивы указывают на несуществующие файлы,  и build_runner их пропускает
4. Проблема с настройкой build.yaml

## 🔧 Рекомендуемые варианты решения

### Вариант 1: Manual Freezed File Creation (БЫСТРО)
Вручную создать .freezed.dart и .g.dart файлы для критичных моделей:
- login_request
- register_request
- auth_response
- auth_tokens
- user

Копировать структуру из `point_balance.freezed.dart` и адаптировать.

**Плюсы:** Быстро, проект заработает
**Минусы:** Придется поддерживать вручную при изменениях моделей

### Вариант 2: Обновление Freezed до latest (РЕКОМЕНДУЕТСЯ)
```yaml
dev_dependencies:
  freezed: ^3.2.5  # latest
  build_runner: ^2.11.1  # latest
```

Выполнить:
```bash
flutter pub upgrade
flutter pub run build_runner clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Плюсы:** Правильное решение
**Минусы:** Может сломать совместимость с другими пакетами

### Вариант 3: Удалить и пересоздать Part директивы
Для файлов без .freezed.dart:
1. Закомментировать `part 'xxx.freezed.dart';` и `part 'xxx.g.dart';`
2. Запустить build_runner
3. Раскомментировать part директивы
4. Запустить build_runner снова

### Вариант 4: Использовать старые GraphQL Flutter (ОТКАТ)
Если Freezed не заработает, можно временно откатиться к graphql_flutter пока не решится проблема.

## 🚀 Следующие шаги (после решения Freezed)

1. Проверить компиляцию auth_remote_datasource
2. Тестировать auth flow (login/register)
3. Мигрировать остальные datasources:
   - `group_remote_datasource.dart`
   - `task_remote_datasource.dart`
   - `profile_remote_datasource.dart`
   - `reward_remote_datasource.dart`
4. Удалить graphql_provider.dart и graphql_flutter dependency
5. Обновить main.dart
6. Полное тестирование

## Файлы для review

- ✅ `lib/core/config/ferry_client.dart` - Ferry client configuration
- ✅ `lib/data/providers/ferry_provider.dart` - Riverpod provider
- ✅ `lib/data/datasources/auth_remote_datasource.dart` - Migrated to Ferry
- ✅ `lib/data/providers/auth_providers.dart` - Updated for Ferry
- ✅ `FERRY_MIGRATION.md` - Complete migration guide
- ⚠️ `lib/data/models/*.dart` - Need freezed generation

## Статистика

- **Прогресс:** ~60% (основная архитектура готова, нужны freezed файлы)
- **Файлов мигрировано:** 5/5 критичных
- **Datasources мигрировано:** 1/5 (auth работает, остальные по шаблону)
- **Ошибок компиляции:** ~15 (все из-за missing freezed files)

---

**Время работы:** ~1.5 часа
**Дата:** 2026-02-17
