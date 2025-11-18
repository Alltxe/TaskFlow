# Recurring Tasks - Documentation

## Overview

TaskFlow поддерживает автоматическое создание повторяющихся задач на основе правил повторения. Система работает через CRON-задачу, которая выполняется каждый час и генерирует задачи за 24 часа до их deadline.

## Supported Formats

Система поддерживает **два формата** правил повторения:

### 1. Simplified Format (Упрощенный)

Простой формат для базовых сценариев:

```
DAILY              # Каждый день
WEEKLY:1,3,5       # Еженедельно: Пн, Ср, Пт (1=Пн, 7=Вс)
MONTHLY:1,15       # Ежемесячно: 1-го и 15-го числа
```

**Примеры:**
- `DAILY` - задача создается каждый день в то же время
- `WEEKLY:1,3,5` - задача создается в понедельник, среду и пятницу
- `MONTHLY:1,15` - задача создается 1-го и 15-го числа каждого месяца

### 2. RFC 5545 (iCalendar RRULE)

Стандартный формат iCalendar для сложных сценариев:

```
FREQ=DAILY
FREQ=WEEKLY;BYDAY=MO,WE,FR
FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30;BYSECOND=0
FREQ=MONTHLY;BYMONTHDAY=1,15
FREQ=SECONDLY;INTERVAL=10
```

**Supported Parameters:**
- `FREQ` - частота: `DAILY`, `WEEKLY`, `MONTHLY`, `HOURLY`, `MINUTELY`, `SECONDLY`
- `INTERVAL` - интервал между повторениями (по умолчанию 1)
- `BYDAY` - дни недели: `MO`, `TU`, `WE`, `TH`, `FR`, `SA`, `SU`
- `BYMONTHDAY` - дни месяца: `1-31` или `-1` (последний день)
- `BYHOUR` - часы: `0-23`
- `BYMINUTE` - минуты: `0-59`
- `BYSECOND` - секунды: `0-59`
- `COUNT` - количество повторений
- `UNTIL` - дата окончания

**Примеры:**

```graphql
# Каждый день в 18:30:00 UTC
mutation {
  createTask(input: {
    title: "Daily Report"
    groupId: "group-id"
    priority: MEDIUM
    points: 10
    isRecurring: true
    recurrenceRule: "FREQ=DAILY;BYHOUR=18;BYMINUTE=30;BYSECOND=0"
  }) {
    id
  }
}

# Каждый понедельник, среду и пятницу
mutation {
  createTask(input: {
    title: "Gym Workout"
    groupId: "group-id"
    priority: HIGH
    points: 15
    isRecurring: true
    recurrenceRule: "FREQ=WEEKLY;BYDAY=MO,WE,FR"
  }) {
    id
  }
}

# Каждое 1-е и 15-е число месяца в 09:00
mutation {
  createTask(input: {
    title: "Monthly Report"
    groupId: "group-id"
    priority: HIGH
    points: 30
    isRecurring: true
    recurrenceRule: "FREQ=MONTHLY;BYMONTHDAY=1,15;BYHOUR=9;BYMINUTE=0"
  }) {
    id
  }
}

# Каждые 30 секунд (для тестирования)
mutation {
  createTask(input: {
    title: "Test Task"
    groupId: "group-id"
    priority: LOW
    points: 5
    isRecurring: true
    recurrenceRule: "FREQ=SECONDLY;INTERVAL=30"
  }) {
    id
  }
}

# Каждый час в течение 7 дней
mutation {
  createTask(input: {
    title: "Hourly Check"
    groupId: "group-id"
    priority: MEDIUM
    points: 5
    isRecurring: true
    recurrenceRule: "FREQ=HOURLY;COUNT=168"  # 7 дней * 24 часа
  }) {
    id
  }
}
```

## How It Works

### 1. Шаблон задачи (Template Task)

Повторяющаяся задача создается как "шаблон" с флагом `isRecurring: true`:

```graphql
mutation CreateRecurringTask {
  createTask(input: {
    title: "Weekly Team Meeting"
    description: "Discuss project progress"
    groupId: "abc123"
    priority: MEDIUM
    points: 10
    isRecurring: true
    recurrenceRule: "FREQ=WEEKLY;BYDAY=MO;BYHOUR=10;BYMINUTE=0"
    rotationType: ROUND_ROBIN  # или null для фиксированного исполнителя
  }) {
    id
    isRecurring
    recurrenceRule
  }
}
```

### 2. Автоматическая генерация

CRON-задача (`@Cron('0 * * * *')`) каждый час:

1. Находит все шаблоны с `isRecurring: true` и `status: COMPLETED`
2. Вычисляет следующий deadline на основе `recurrenceRule`
3. Если следующий deadline **в течение 24 часов**, создает новую задачу
4. Применяет ротацию исполнителей (если `rotationType` установлен)

### 3. Дочерние задачи (Child Tasks)

Созданные задачи имеют:
- `parentTaskId` - ссылка на шаблон
- `isRecurring: false` - это обычная задача
- Все остальные параметры копируются из шаблона

```graphql
query GetRecurringTaskChildren {
  task(id: "template-id") {
    id
    title
    isRecurring
    childTasks {
      id
      deadline
      assignee {
        username
      }
      status
    }
  }
}
```

## Rotation Types

Повторяющиеся задачи поддерживают ротацию исполнителей:

### ROUND_ROBIN (По кругу)

Задачи распределяются поочередно между участниками группы:

```
Task 1 → User A
Task 2 → User B
Task 3 → User C
Task 4 → User A  # Начинается заново
```

Логика:
- Сортировка по дате последнего выполнения задачи
- Пользователи с `isAway: true` пропускаются
- Если нет доступных исполнителей → режим "Up-for-Grabs"

### FIXED (Фиксированный)

Задачи всегда назначаются одному и тому же пользователю:

```graphql
mutation {
  createTask(input: {
    title: "Personal Report"
    groupId: "group-id"
    assigneeId: "user-id"
    isRecurring: true
    recurrenceRule: "FREQ=WEEKLY;BYDAY=FR"
    rotationType: null  # Фиксированный исполнитель
  }) {
    id
  }
}
```

## Testing & Manual Generation

### Force Generate Next Task

Для тестирования или ручной генерации:

```graphql
mutation ForceGenerate {
  generateNextRecurringTask(taskId: "template-id") {
    id
    title
    deadline
    assignee {
      username
    }
  }
}
```

⚠️ **Важно**: Эта мутация создает задачу **немедленно**, не дожидаясь CRON-задачи.

### Practical Testing with Secondly Interval

Для быстрого тестирования используйте `FREQ=SECONDLY`:

```graphql
mutation TestRecurring {
  createTask(input: {
    title: "Test Task - Every 10 seconds"
    groupId: "group-id"
    priority: LOW
    points: 1
    deadline: "2025-11-16T21:00:00Z"
    isRecurring: true
    recurrenceRule: "FREQ=SECONDLY;INTERVAL=10"
  }) {
    id
  }
}

# Подождите 10 секунд, затем вручную сгенерируйте:
mutation {
  generateNextRecurringTask(taskId: "<template-id>") {
    id
    deadline  # Должен быть на ~10 секунд позже
  }
}
```

## Implementation Details

### Service Architecture

```
RecurringTaskService
├── generateRecurringTasks()        # CRON job (каждый час)
├── forceGenerateNextTask()         # Ручная генерация
├── calculateNextDeadline()         # Вычисление следующего deadline
├── parseRecurrenceRule()           # Парсинг RRULE (упрощенный + RFC 5545)
└── createTaskFromTemplate()        # Создание дочерней задачи
```

### Database Schema

```prisma
model Task {
  id                String    @id @default(cuid())
  title             String
  isRecurring       Boolean   @default(false)
  recurrenceRule    String?   // "FREQ=WEEKLY;BYDAY=MO,WE,FR"
  rotationType      String?   // "ROUND_ROBIN" | null
  parentTaskId      String?   // Ссылка на шаблон
  
  parentTask        Task?     @relation("RecurringTasks", fields: [parentTaskId])
  childTasks        Task[]    @relation("RecurringTasks")
}
```

## RFC 5545 Resources

Библиотека: [rrule](https://github.com/jkbrzt/rrule)

**Документация:**
- [RFC 5545 Specification](https://tools.ietf.org/html/rfc5545)
- [rrule.js Documentation](https://github.com/jkbrzt/rrule#readme)
- [iCalendar RRULE Tester](https://icalendar.org/rrule-tool.html)

## Best Practices

1. **Используйте UTC время** для BYHOUR/BYMINUTE/BYSECOND
2. **Тестируйте с FREQ=SECONDLY** перед продакшеном
3. **Устанавливайте COUNT или UNTIL** чтобы избежать бесконечного повторения
4. **Проверяйте timezone** - rrule использует UTC по умолчанию
5. **Используйте упрощенный формат** для простых сценариев (быстрее и понятнее)

## Troubleshooting

### Задача не создается автоматически

Проверьте:
1. Шаблон имеет `isRecurring: true` и `status: COMPLETED`
2. Следующий deadline в течение 24 часов от текущего времени
3. CRON-задача работает (логи: `[RecurringTaskService] Checking for recurring tasks`)
4. Правило `recurrenceRule` валидное (проверьте логи на ошибки парсинга)

### Неправильный deadline

- Для RFC 5545: убедитесь, что используете UTC время
- Проверьте timezone интерпретацию (rrule возвращает UTC даты)
- Используйте `BYHOUR`, `BYMINUTE`, `BYSECOND` для точного времени

### Ротация не работает

1. Проверьте, что `rotationType` установлен в группе или задаче
2. Убедитесь, что есть доступные участники (`isAway: false`)
3. Проверьте логи: `[RecurringTaskService] Using rotation type: ...`

## Examples from Tests

См. полные примеры в:
- `src/modules/task/recurring-task.service.spec.ts` - Unit tests
- `test/recurring-tasks.e2e-spec.ts` - E2E tests

```typescript
// Примеры из тестов:

// RFC 5545 с конкретным временем
'FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30;BYSECOND=0'

// Каждые 10 секунд (для тестирования)
'FREQ=SECONDLY;INTERVAL=10'

// Ежемесячно 1-го и 15-го
'FREQ=MONTHLY;BYMONTHDAY=1,15'

// Упрощенный формат
'WEEKLY:1,3,5'  // Пн, Ср, Пт
'DAILY'
'MONTHLY:1,15'
```
