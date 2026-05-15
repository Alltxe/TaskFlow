# GraphQL Code Generation Migration - Status Report

## Summary

Начата миграция мобильного приложения Flutter на GraphQL Code Generation. Были созданы все необходимые GraphQL операции в .graphql файлах, но столкнулись с техническими сложностями при настройке автоматической кодогенерации для Flutter.

## Completed Steps

1. ✅ **Структура проекта создана**
   - Создана директория `lib/graphql/` с поддиректориями для auth, group, task, profile, reward
   - Скопирована схема в `lib/graphql/schema.graphql`

2. ✅ **GraphQL операции извлечены**
   - `lib/graphql/auth/auth.graphql` - Login, Register, RefreshToken, Logout, ChangePassword, Me
   - `lib/graphql/group/group.graphql` - CRUD операции для групп, членов, инвайтов
   - `lib/graphql/task/task.graphql` - CRUD операции для задач, Complete, Approve, Claim
   - `lib/graphql/profile/profile.graphql` - Статистика пользователя, обновление профиля
   - `lib/graphql/reward/reward.graphql` - CRUD наград, запросы наград, баланс поинтов, лидерборд

3. ✅ **Fragments определены**
   - Все повторяющиеся поля вынесены во фрагменты (GroupFields, TaskFields, RewardFields и т.д.)

## Technical Challenges

### Попытка 1: gql_code_builder
- Добавлен пакет `gql_code_builder: ^0.9.0`
- Проблема: Builder не распознается build_runner, генерация не запускается
- Причина: Требует сложной кон фигурации, не работает из коробки

### Попытка 2: Ferry
- Добавлены пакеты: `ferry`, `ferry_generator`, `ferry_flutter`
- Проблема: Builder также не распознается, файлы не генерируются
- Причина: Ferry требует специфичную конфигурацию и может не совместим с существующей структурой

## Current State

**Проблема:** В Flutter/Dart экосистеме нет прямого эквивалента graphql-code-generator (который используется на фронтенде).  Доступные решения (Ferry, Artemis, gql_code_builder) требуют сложной настройки и часто не работают из коробки.

## Рекомендуемые решения

### Вариант 1: graphql-code-generator (Node.js) с Flutter плагином [RECOMMENDED]
**Преимущества:**
- Consistent с фронтендом (используется тот же инструмент)
- Большое community, много плагинов
- Можно использовать `graphql-codegen-flutter-freezed` плагин

**Шаги:**
1. Установить graphql-code-generator глобально: `npm install -g @graphql-codegen/cli`
2. Создать `codegen.yaml` в корне mobile/
3. Использовать плагины: `graphql-codegen-flutter-freezed` или `graphql-codegen-dart`
4. Запускать `graphql-codegen` как часть build процесса

### Вариант 2: Продолжить с Ferry (требует debugging)
**Что нужно:**
1. Изучить детальную документацию Ferry
2. Создать минимальный пример для отладки
3. Настроить правильную конфигурацию в build.yaml

### Вариант 3: Hybrid approach - сохранить текущие модели, улучшить типизацию
**Идея:**
- Оставить существующие Freezed модели
- Создать typed wrappers для GraphQL операций
- Использовать gql_code_builder только для schema типов (не для операций)

## Files Created

```
lib/graphql/
├── schema.graphql
├── auth/
│   └── auth.graphql
├── group/
│   └── group.graphql
├── task/
│   └── task.graphql
├── profile/
│   └── profile.graphql
└── reward/
    └── reward.graphql
```

## Next Steps

**Requires user decision:**
1. Какой вариант решения предпочесть?
2. Если graphql-code-generator - нужно ли установить Node.js в CI/CD?
3. Если Ferry - готовы ли потратить время на debugging конфигурации?

**После выбора варианта:**
1. Настроить выбранный инструмент
2. Сгенерировать типы
3. Рефакторить datasources для использования сгенерированных типов
4. Удалить старые ручные модели (опционально)
