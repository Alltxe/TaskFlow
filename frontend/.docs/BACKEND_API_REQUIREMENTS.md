# Backend API Requirements for TaskFlow

## Статус документа
- **Дата создания:** 16 ноября 2025
- **Версия:** 1.0
- **Статус:** Требуется реализация

---

## Обзор

Этот документ описывает отсутствующие Backend API, необходимые для завершения функциональности TaskFlow фронтенда (Phase 5-8). Все описанные API должны быть реализованы на бэкенде для полноценной работы приложения.

### Что уже реализовано ✅

Backend GraphQL API уже имеет следующие возможности:

- ✅ Аутентификация (login, register, logout, refreshToken, changePassword)
- ✅ Управление группами (create, update, delete, join, leave)
- ✅ Управление участниками (invite, remove, change role)
- ✅ CRUD задач (create, update, delete, complete, approve, claim)
- ✅ Система уведомлений (list, mark as read, preferences)
- ✅ Push-уведомления (device tokens, test push)
- ✅ Система наград (create, update, delete, request, approve)
- ✅ Баланс поинтов (getPointBalance)
- ✅ Leaderboard (getGroupLeaderboard)
- ✅ Статистика пользователя (myStatistics, userStatistics)
- ✅ Audit logs (getAuditLogs, getTaskAuditLog, getGroupAuditLog)

---

## Критичные API (блокируют Phase 5-6)

### 1. Обновление профиля пользователя

**Фаза:** Phase 8.1  
**Приоритет:** 🔴 Критичный  
**Статус:** ❌ Отсутствует

#### Описание
Мутация для обновления данных профиля пользователя (имя, аватар).

#### GraphQL Schema

```graphql
type Mutation {
  """Обновить профиль текущего пользователя"""
  updateUser(input: UpdateUserInput!): UserType!
}

input UpdateUserInput {
  """Новое имя пользователя (3-30 символов)"""
  username: String
  
  """URL аватара пользователя"""
  avatarUrl: String
}
```

#### Бизнес-логика

1. **Валидация:**
   - `username`: 3-30 символов, буквы/цифры/подчеркивание
   - `avatarUrl`: валидный URL (опционально)
   - Username должен быть уникальным

2. **Права доступа:**
   - Пользователь может изменять только свой профиль
   - Требуется аутентификация

3. **Поведение:**
   - Обновляет только переданные поля (partial update)
   - Возвращает обновленный объект UserType
   - При конфликте username → ошибка "Username already taken"

#### Пример использования

```graphql
mutation {
  updateUser(input: {
    username: "newUsername"
    avatarUrl: "https://example.com/avatar.jpg"
  }) {
    id
    username
    avatarUrl
    updatedAt
  }
}
```

#### Связанные фронтенд-компоненты
- `src/pages/Profile.tsx` - страница редактирования профиля

---

### 2. Управление статусом "Away"

**Фаза:** Phase 5.3  
**Приоритет:** 🔴 Критичный  
**Статус:** ❌ Отсутствует

#### Описание
Мутация для установки/снятия статуса "В отъезде" с автоматическим исключением из ротации задач.

#### GraphQL Schema

```graphql
type Mutation {
  """Установить статус 'В отъезде' для текущего пользователя"""
  setUserAwayStatus(input: SetAwayStatusInput!): UserType!
}

input SetAwayStatusInput {
  """Флаг статуса 'В отъезде'"""
  isAway: Boolean!
  
  """Дата возвращения (null = бессрочно)"""
  awayUntil: DateTime
}
```

#### Бизнес-логика

1. **Валидация:**
   - `awayUntil` должен быть в будущем (если указан)
   - Если `isAway = false`, то `awayUntil` должен быть null

2. **Права доступа:**
   - Пользователь может изменять только свой статус
   - Требуется аутентификация

3. **Поведение:**
   - Обновляет поля `isAway` и `awayUntil` в UserType
   - **Автоматическое исключение из ротации:**
     - Пользователи с `isAway = true` пропускаются при назначении задач через rotation
     - Существующие назначенные задачи НЕ переназначаются
   - **Автоматический возврат:**
     - Backend cron job проверяет `awayUntil` каждый день
     - Если `awayUntil < now()`, автоматически устанавливает `isAway = false`

4. **Отображение:**
   - Фронтенд показывает чип "В отъезде до [дата]" на странице участников группы
   - Пользователь видит предупреждение на своей странице профиля

#### Пример использования

```graphql
# Установить статус "В отъезде до 25 декабря"
mutation {
  setUserAwayStatus(input: {
    isAway: true
    awayUntil: "2025-12-25T00:00:00Z"
  }) {
    id
    username
    isAway
    awayUntil
  }
}

# Вернуться из отъезда досрочно
mutation {
  setUserAwayStatus(input: {
    isAway: false
    awayUntil: null
  }) {
    id
    isAway
    awayUntil
  }
}
```

#### Связанные фронтенд-компоненты
- `src/pages/Profile.tsx` - редактирование статуса
- `src/pages/GroupMembers.tsx` - отображение статуса участников

#### Альтернатива
Можно реализовать через мутацию `updateUser`, добавив поля `isAway` и `awayUntil` в `UpdateUserInput`.

---

### 3. Расписание ротации задач

**Фаза:** Phase 5.1  
**Приоритет:** 🔴 Критичный  
**Статус:** ❌ Отсутствует

#### Описание
Query для получения расписания предстоящих автоматических назначений задач через систему ротации.

#### GraphQL Schema

```graphql
type Query {
  """Получить расписание предстоящих назначений задач через ротацию"""
  getRotationSchedule(groupId: ID!): [RotationScheduleEntry!]!
}

type RotationScheduleEntry {
  """ID задачи (для recurring tasks - ID шаблона)"""
  taskId: ID!
  
  """Название задачи"""
  taskTitle: String!
  
  """ID пользователя, которому будет назначена задача"""
  userId: ID!
  
  """Имя пользователя"""
  username: String!
  
  """Аватар пользователя"""
  avatarUrl: String
  
  """Дата и время планируемого назначения"""
  scheduledDate: DateTime!
  
  """Тип ротации для этой задачи"""
  rotationType: String!
  
  """Приоритет задачи"""
  priority: String!
  
  """Базовые баллы за выполнение"""
  points: Int!
}
```

#### Бизнес-логика

1. **Что возвращать:**
   - Список предстоящих назначений на ближайшие 30 дней
   - Только для задач с `isRecurring = true` и `rotationType != null`
   - Сортировка по `scheduledDate` (от ближайшей к дальней)

2. **Алгоритм расчета:**
   - Для **CYCLIC** ротации:
     - Определить текущую позицию в цикле участников
     - Рассчитать следующие N назначений по круговому алгоритму
     - Исключить пользователей с `isAway = true`
   - Для **RANDOM** ротации:
     - Показать только следующее назначение (рандом непредсказуем)
     - Случайный выбор из активных участников
   - Для **DISABLED** ротации:
     - Вернуть пустой массив

3. **Права доступа:**
   - Любой участник группы может видеть расписание
   - Не участники группы → ошибка доступа

4. **Учет recurrenceRule:**
   - Парсить `recurrenceRule` (RFC 5545 RRULE)
   - Генерировать даты на основе правила повторения
   - Для каждой даты назначать следующего пользователя по ротации

#### Пример использования

```graphql
query {
  getRotationSchedule(groupId: "group-123") {
    taskId
    taskTitle
    userId
    username
    avatarUrl
    scheduledDate
    rotationType
    priority
    points
  }
}
```

#### Пример ответа

```json
[
  {
    "taskId": "task-456",
    "taskTitle": "Вынести мусор",
    "userId": "user-789",
    "username": "Иван",
    "avatarUrl": "https://example.com/ivan.jpg",
    "scheduledDate": "2025-11-18T09:00:00Z",
    "rotationType": "CYCLIC",
    "priority": "MEDIUM",
    "points": 50
  },
  {
    "taskId": "task-456",
    "taskTitle": "Вынести мусор",
    "userId": "user-101",
    "username": "Мария",
    "avatarUrl": null,
    "scheduledDate": "2025-11-20T09:00:00Z",
    "rotationType": "CYCLIC",
    "priority": "MEDIUM",
    "points": 50
  }
]
```

#### Связанные фронтенд-компоненты
- `src/pages/RotationSchedule.tsx` - страница визуализации расписания

---

### 4. История ротации задач

**Фаза:** Phase 5.1  
**Приоритет:** 🔴 Критичный  
**Статус:** ❌ Отсутствует

#### Описание
Query для получения истории прошлых назначений задач через систему ротации.

#### GraphQL Schema

```graphql
type Query {
  """Получить историю назначений задач через ротацию"""
  getRotationHistory(
    groupId: ID!
    limit: Int = 50
    offset: Int = 0
  ): RotationHistoryResult!
}

type RotationHistoryResult {
  items: [RotationHistoryEntry!]!
  total: Int!
}

type RotationHistoryEntry {
  """ID задачи"""
  taskId: ID!
  
  """Название задачи"""
  taskTitle: String!
  
  """ID пользователя, которому была назначена задача"""
  userId: ID!
  
  """Имя пользователя"""
  username: String!
  
  """Аватар пользователя"""
  avatarUrl: String
  
  """Дата и время назначения"""
  assignedAt: DateTime!
  
  """Дата и время завершения (null если не завершена)"""
  completedAt: DateTime
  
  """Статус задачи"""
  status: String!
  
  """Тип ротации"""
  rotationType: String!
  
  """Баллы, полученные за выполнение (0 если не завершена)"""
  pointsEarned: Int!
}
```

#### Бизнес-логика

1. **Что возвращать:**
   - Задачи, которые были **назначены через ротацию** (не вручную)
   - Маркер: при создании задачи через rotation сохранять флаг в БД
   - Сортировка по `assignedAt` DESC (новые сверху)
   - Пагинация (limit/offset)

2. **Фильтрация:**
   - Только задачи группы `groupId`
   - Только задачи с автоматическим назначением (не manual assignment)
   - Все статусы (PENDING, COMPLETED, AWAITING_APPROVAL, etc.)

3. **Права доступа:**
   - Любой участник группы может видеть историю
   - Не участники группы → ошибка доступа

#### Пример использования

```graphql
query {
  getRotationHistory(
    groupId: "group-123"
    limit: 20
    offset: 0
  ) {
    items {
      taskId
      taskTitle
      userId
      username
      assignedAt
      completedAt
      status
      rotationType
      pointsEarned
    }
    total
  }
}
```

#### Связанные фронтенд-компоненты
- `src/pages/RotationSchedule.tsx` - секция "История ротации"

---

### 5. Паттерн/правила ротации группы

**Фаза:** Phase 5.1  
**Приоритет:** 🟡 Важный  
**Статус:** ❌ Отсутствует

#### Описание
Query для получения текущей конфигурации ротации и состояния цикла.

#### GraphQL Schema

```graphql
type Query {
  """Получить информацию о паттерне ротации группы"""
  getRotationPattern(groupId: ID!): RotationPatternType!
}

type RotationPatternType {
  """Тип ротации группы"""
  rotationType: String!
  
  """Массив userId в порядке очереди (только для CYCLIC)"""
  currentCycle: [String!]!
  
  """Текущий индекс в цикле (только для CYCLIC, 0-based)"""
  currentCycleIndex: Int
  
  """Дата последнего назначения через ротацию"""
  lastRotationAt: DateTime
  
  """Дата следующего планируемого назначения"""
  nextRotationAt: DateTime
  
  """Активные участники (не в отъезде)"""
  activeMembers: [GroupMemberUserType!]!
  
  """Участники в отъезде"""
  awayMembers: [GroupMemberUserType!]!
}
```

#### Бизнес-логика

1. **Для CYCLIC ротации:**
   - `currentCycle`: упорядоченный список userId (порядок определяется датой присоединения к группе)
   - `currentCycleIndex`: индекс пользователя, который получит следующую задачу
   - Исключаются пользователи с `isAway = true`

2. **Для RANDOM ротации:**
   - `currentCycle`: все активные участники (порядок не важен)
   - `currentCycleIndex`: null

3. **Для DISABLED ротации:**
   - `currentCycle`: пустой массив
   - `currentCycleIndex`: null

4. **Права доступа:**
   - Любой участник группы
   - Админы видят расширенную информацию

#### Пример использования

```graphql
query {
  getRotationPattern(groupId: "group-123") {
    rotationType
    currentCycle
    currentCycleIndex
    lastRotationAt
    nextRotationAt
    activeMembers {
      id
      username
      avatarUrl
    }
    awayMembers {
      id
      username
      awayUntil
    }
  }
}
```

#### Связанные фронтенд-компоненты
- `src/pages/RotationSchedule.tsx` - секция "Паттерн ротации"

---

### 6. История транзакций поинтов

**Фаза:** Phase 6.4  
**Приоритет:** 🔴 Критичный  
**Статус:** ❌ Отсутствует

#### Описание
Query для получения детальной истории начислений и списаний поинтов пользователя.

#### GraphQL Schema

```graphql
type Query {
  """Получить историю транзакций поинтов"""
  getPointTransactionHistory(
    groupId: ID
    limit: Int = 50
    offset: Int = 0
  ): PointTransactionHistoryResult!
}

type PointTransactionHistoryResult {
  items: [PointTransactionType!]!
  total: Int!
}

type PointTransactionType {
  """ID транзакции"""
  id: ID!
  
  """Тип транзакции"""
  type: PointTransactionTypeEnum!
  
  """Сумма (положительная для EARNED, отрицательная для SPENT)"""
  amount: Int!
  
  """Описание транзакции"""
  description: String!
  
  """ID связанной задачи (если применимо)"""
  relatedTaskId: ID
  
  """Название связанной задачи"""
  relatedTaskTitle: String
  
  """ID связанной награды (если применимо)"""
  relatedRewardId: ID
  
  """Название связанной награды"""
  relatedRewardName: String
  
  """Дата и время транзакции"""
  createdAt: DateTime!
}

enum PointTransactionTypeEnum {
  """Начислены за выполнение задачи"""
  EARNED
  
  """Потрачены на награду"""
  SPENT
  
  """Зарезервированы (ожидание одобрения reward request)"""
  RESERVED
  
  """Возвращены (reward request отклонен)"""
  REFUNDED
}
```

#### Бизнес-логика

1. **Источники транзакций:**
   - **EARNED**: Задача одобрена (`approveTask` mutation)
   - **SPENT**: Reward request одобрен (`approveRewardRequest` mutation)
   - **RESERVED**: Reward request создан (`requestReward` mutation)
   - **REFUNDED**: Reward request отклонен (`approveRewardRequest` с `approved: false`)

2. **Фильтрация:**
   - Если `groupId` указан → транзакции только этой группы
   - Если `groupId = null` → транзакции всех групп пользователя
   - Сортировка по `createdAt` DESC

3. **Права доступа:**
   - Пользователь видит только свои транзакции
   - Требуется аутентификация

4. **Описание (description):**
   - EARNED: "Выполнение задачи: [Task Title] (+50% бонус)" или "Выполнение задачи: [Task Title]"
   - SPENT: "Награда: [Reward Name]"
   - RESERVED: "Резерв для награды: [Reward Name]"
   - REFUNDED: "Возврат за отклоненную награду: [Reward Name]"

#### Пример использования

```graphql
query {
  getPointTransactionHistory(
    groupId: "group-123"
    limit: 20
    offset: 0
  ) {
    items {
      id
      type
      amount
      description
      relatedTaskTitle
      relatedRewardName
      createdAt
    }
    total
  }
}
```

#### Пример ответа

```json
{
  "items": [
    {
      "id": "tx-1",
      "type": "EARNED",
      "amount": 150,
      "description": "Выполнение задачи: Вынести мусор (+50% бонус)",
      "relatedTaskTitle": "Вынести мусор",
      "relatedRewardName": null,
      "createdAt": "2025-11-15T14:30:00Z"
    },
    {
      "id": "tx-2",
      "type": "SPENT",
      "amount": -100,
      "description": "Награда: Дополнительный выходной",
      "relatedTaskTitle": null,
      "relatedRewardName": "Дополнительный выходной",
      "createdAt": "2025-11-14T10:00:00Z"
    }
  ],
  "total": 2
}
```

#### Связанные фронтенд-компоненты
- `src/pages/Profile.tsx` - вкладка "История транзакций" (будущая)
- Будущая страница Point Transaction History

---

## Важные API (улучшают UX)

### 7. GraphQL Subscriptions для real-time уведомлений

**Фаза:** Phase 7.3  
**Приоритет:** 🟡 Важный  
**Статус:** ❌ Отсутствует

#### Описание
WebSocket subscriptions для мгновенных уведомлений о событиях в системе.

#### GraphQL Schema

```graphql
type Subscription {
  """Подписка на назначение задач текущему пользователю"""
  taskAssigned: TaskType!
  
  """Подписка на новые уведомления текущего пользователя"""
  notificationCreated: NotificationType!
  
  """Подписка на изменения задачи"""
  taskUpdated(taskId: ID!): TaskType!
}
```

#### Бизнес-логика

1. **taskAssigned:**
   - Триггер: Задача назначена пользователю (через ротацию или вручную)
   - Отправляется только пользователю, которому назначена задача
   - Фронтенд показывает toast-уведомление

2. **notificationCreated:**
   - Триггер: Создано новое уведомление для пользователя
   - Типы: TASK_ASSIGNED, TASK_APPROVED, REWARD_APPROVED, etc.
   - Фронтенд обновляет счетчик непрочитанных уведомлений

3. **taskUpdated:**
   - Триггер: Задача изменена (статус, assignee, deadline, etc.)
   - Подписчики: все участники группы, которые просматривают эту задачу
   - Фронтенд обновляет данные в реальном времени

#### Технические требования

- Использовать WebSocket (Apollo Server Subscriptions или graphql-ws)
- Аутентификация через JWT токен в connection params
- Auto-reconnect при потере соединения
- Heartbeat для проверки живого соединения

#### Альтернатива
Если subscriptions сложно реализовать, можно использовать **polling**:
- Фронтенд каждые 30 секунд вызывает `myNotifications(input: { isRead: false })`
- Показывает новые уведомления

#### Связанные фронтенд-компоненты
- `src/components/layout/ToastNotifications.tsx` - toast уведомления
- `src/components/layout/Header.tsx` - счетчик непрочитанных (будущая реализация)

---

### 8. Лента активности пользователя

**Фаза:** Phase 8.3  
**Приоритет:** 🟡 Важный  
**Статус:** ❌ Отсутствует

#### Описание
Query для получения временной ленты действий пользователя в системе.

#### GraphQL Schema

```graphql
type Query {
  """Получить ленту активности пользователя"""
  getUserActivityHistory(
    userId: ID
    limit: Int = 50
    offset: Int = 0
  ): ActivityHistoryResult!
}

type ActivityHistoryResult {
  items: [ActivityEntryType!]!
  total: Int!
}

type ActivityEntryType {
  """ID записи активности"""
  id: ID!
  
  """Тип действия"""
  actionType: ActivityActionTypeEnum!
  
  """Описание действия (для пользователя)"""
  description: String!
  
  """Тип связанной сущности"""
  relatedEntityType: String
  
  """ID связанной сущности"""
  relatedEntityId: String
  
  """Дата и время действия"""
  createdAt: DateTime!
}

enum ActivityActionTypeEnum {
  """Задача завершена"""
  TASK_COMPLETED
  
  """Задача одобрена"""
  TASK_APPROVED
  
  """Задача отклонена"""
  TASK_REJECTED
  
  """Задача взята из Up-for-Grabs"""
  TASK_CLAIMED
  
  """Награда запрошена"""
  REWARD_REQUESTED
  
  """Награда получена"""
  REWARD_CLAIMED
  
  """Баллы начислены"""
  POINTS_EARNED
  
  """Присоединился к группе"""
  GROUP_JOINED
  
  """Покинул группу"""
  GROUP_LEFT
}
```

#### Бизнес-логика

1. **Источники активности:**
   - События из audit logs
   - Транзакции поинтов
   - Изменения задач
   - Изменения membership

2. **Фильтрация:**
   - Если `userId` не указан → активность текущего пользователя
   - Если `userId` указан → активность этого пользователя (только если он в той же группе)
   - Сортировка по `createdAt` DESC

3. **Права доступа:**
   - Пользователь видит свою активность
   - Админы групп видят активность участников своих групп
   - Другие пользователи → ошибка доступа

4. **Описание (description):**
   - TASK_COMPLETED: "Выполнил задачу: [Task Title]"
   - REWARD_CLAIMED: "Получил награду: [Reward Name]"
   - POINTS_EARNED: "Заработал 150 баллов"
   - GROUP_JOINED: "Присоединился к группе: [Group Name]"

#### Пример использования

```graphql
query {
  getUserActivityHistory(
    limit: 20
    offset: 0
  ) {
    items {
      id
      actionType
      description
      relatedEntityType
      relatedEntityId
      createdAt
    }
    total
  }
}
```

#### Связанные фронтенд-компоненты
- `src/pages/Profile.tsx` - вкладка "Активность" (будущая)

---

### 9. Email-уведомления (Backend Service)

**Фаза:** Phase 5.5  
**Приоритет:** 🟡 Важный  
**Статус:** ❌ Отсутствует

#### Описание
Background job для отправки email-уведомлений пользователям.

**Это НЕ GraphQL API**, а серверный сервис (cron job + email sender).

#### Требования

1. **Еженедельный digest:**
   - Запускается каждое воскресенье в 20:00
   - Тема: "Ваши задачи на следующую неделю"
   - Содержание:
     - Список задач, назначенных на ближайшие 7 дней
     - Deadline каждой задачи
     - Баллы за выполнение
     - Ссылка на группу в TaskFlow

2. **Уведомление о назначении задачи:**
   - Триггер: Задача назначена пользователю
   - Тема: "Вам назначена новая задача: [Task Title]"
   - Содержание:
     - Название задачи
     - Описание
     - Deadline
     - Баллы
     - Ссылка на задачу

3. **Уведомление об одобрении/отклонении reward:**
   - Триггер: Reward request одобрен/отклонен
   - Тема: "Ваш запрос на награду одобрен/отклонен"
   - Содержание:
     - Название награды
     - Статус (одобрено/отклонено)
     - Причина отклонения (если применимо)

#### Технические детали

- Email sender: Nodemailer + Gmail SMTP / SendGrid / AWS SES
- Шаблоны: Handlebars или React Email
- Настройки пользователя: проверять `notificationPreference.enableEmail`
- Unsubscribe link в каждом письме

#### Конфигурация (опционально в GraphQL)

```graphql
# Расширить UpsertNotificationPreferenceInput:
input UpsertNotificationPreferenceInput {
  # ... существующие поля ...
  
  """Включить email-уведомления"""
  enableEmail: Boolean
  
  """Частота email-дайджеста"""
  emailDigestFrequency: EmailDigestFrequency
}

enum EmailDigestFrequency {
  DAILY
  WEEKLY
  NEVER
}
```

---

## Опциональные API (не блокируют MVP)

### 10. Leaderboard с фильтром по периодам

**Фаза:** Phase 6.5  
**Приоритет:** 🟢 Низкий  
**Статус:** ❌ Отсутствует (но есть базовый getGroupLeaderboard)

#### Описание
Расширить существующий `getGroupLeaderboard` фильтром по временным периодам.

#### GraphQL Schema

```graphql
type Query {
  """Leaderboard группы с фильтром по периоду"""
  getGroupLeaderboard(
    groupId: String!
    period: LeaderboardPeriod = ALL_TIME
  ): [LeaderboardEntryType!]!
}

enum LeaderboardPeriod {
  """За сегодня"""
  DAILY
  
  """За текущую неделю (пн-вс)"""
  WEEKLY
  
  """За текущий месяц"""
  MONTHLY
  
  """За все время"""
  ALL_TIME
}
```

#### Бизнес-логика

- Считать только поинты, заработанные в указанном периоде
- DAILY: с 00:00 текущего дня
- WEEKLY: с понедельника текущей недели
- MONTHLY: с 1 числа текущего месяца
- ALL_TIME: все поинты (текущее поведение)

#### Связанные фронтенд-компоненты
- Будущая страница Leaderboard с вкладками периодов

---

### 11. Инстансы повторяющихся задач

**Фаза:** Phase 5.1  
**Приоритет:** 🟢 Низкий  
**Статус:** Частично реализовано

#### Описание
Query для получения всех экземпляров (instances) повторяющейся задачи.

#### GraphQL Schema

```graphql
type Query {
  """Получить все экземпляры повторяющейся задачи"""
  getRecurringTaskInstances(
    parentTaskId: ID!
    limit: Int = 100
  ): [TaskType!]!
}
```

#### Бизнес-логика

- `parentTaskId`: ID шаблона (задача с `isRecurring = true`)
- Возвращает все задачи с `parentTaskId = parentTaskId`
- Сортировка по `deadline` ASC
- Включает прошлые, текущие и будущие экземпляры

#### Примечание
Возможно, это уже работает через поле `parentTaskId` в TaskType. Нужно уточнить у бэкенд-команды.

---

## Приоритизация разработки

### Итерация 1: Критичные API (блокируют Phase 5-6)
1. ✅ `updateUser` mutation
2. ✅ `setUserAwayStatus` mutation
3. ✅ `getRotationSchedule` query
4. ✅ `getRotationHistory` query
5. ✅ `getRotationPattern` query
6. ✅ `getPointTransactionHistory` query

**Ожидаемый срок:** 1-2 недели  
**Результат:** Полное завершение Phase 5 и Phase 6 на фронтенде

---

### Итерация 2: Важные API (улучшают UX)
7. ⭐ GraphQL Subscriptions (real-time)
8. ⭐ `getUserActivityHistory` query
9. ⭐ Email service (background job)

**Ожидаемый срок:** 2-3 недели  
**Результат:** Завершение Phase 7 и Phase 8 на фронтенде

---

### Итерация 3: Опциональные API (полируют продукт)
10. Leaderboard с фильтрами
11. Recurring task instances query

**Ожидаемый срок:** 1 неделя  
**Результат:** Полностью завершенный MVP

---

## Тестирование и валидация

### Тестовые сценарии для каждого API

#### updateUser
- ✅ Успешное обновление username
- ✅ Успешное обновление avatarUrl
- ❌ Ошибка при дублировании username
- ❌ Ошибка при невалидном username (< 3 символов)

#### setUserAwayStatus
- ✅ Установка статуса "В отъезде" с датой
- ✅ Снятие статуса "В отъезде"
- ✅ Автоматическое исключение из ротации
- ✅ Автоматический возврат после awayUntil
- ❌ Ошибка при дате в прошлом

#### getRotationSchedule
- ✅ Получение расписания для CYCLIC ротации
- ✅ Получение расписания для RANDOM ротации
- ✅ Пустой массив для DISABLED ротации
- ✅ Исключение пользователей с isAway = true
- ❌ Ошибка доступа для не участника группы

#### getRotationHistory
- ✅ Получение истории с пагинацией
- ✅ Фильтрация по группе
- ✅ Только задачи, назначенные через ротацию
- ❌ Ошибка доступа для не участника группы

#### getPointTransactionHistory
- ✅ Получение всех типов транзакций
- ✅ Фильтрация по группе
- ✅ Правильные описания для каждого типа
- ✅ Пагинация работает корректно

#### GraphQL Subscriptions
- ✅ taskAssigned отправляется при назначении
- ✅ notificationCreated отправляется при создании уведомления
- ✅ Reconnect после разрыва соединения
- ✅ Аутентификация работает

---

## Контакты и координация

### Вопросы по требованиям
Если у бэкенд-команды возникли вопросы по спецификациям:
1. Открыть issue в репозитории
2. Тег: `backend-api`, `frontend-requirement`
3. Назначить: @frontend-lead

### Процесс согласования
1. Бэкенд-команда ревьюит требования
2. Обсуждение спорных моментов
3. Финализация GraphQL schema
4. Реализация API
5. Тестирование с фронтендом
6. Деплой в staging

### Timeline
- **Неделя 1-2:** API Итерации 1 (критичные)
- **Неделя 3-4:** Интеграция на фронтенде
- **Неделя 5-6:** API Итерации 2 (важные)
- **Неделя 7:** API Итерации 3 (опциональные)
- **Неделя 8:** Финальное тестирование

---

## Changelog

### Version 1.0 (16 ноября 2025)
- Первая версия документа
- Описаны все критичные, важные и опциональные API
- Добавлены примеры использования и бизнес-логика
- Определены приоритеты и timeline

---

**Документ подготовлен:** Frontend Team  
**Для команды:** Backend Team  
**Статус:** Требуется ревью и согласование
