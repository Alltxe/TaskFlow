# TaskFlow GraphQL API Documentation

**Version:** 1.1  
**Last Updated:** 2025-11-16  
**Target Audience:** Frontend developers, LLMs, API consumers

**Recent Changes (v1.1):**
- ✅ Added `updateUser` mutation - update username and avatar
- ✅ Added `setUserAwayStatus` mutation - manage away status for rotation exclusion
- ✅ Added `getRotationSchedule` query - upcoming task assignments
- ✅ Added `getRotationHistory` query - paginated rotation history
- ✅ Added `getRotationPattern` query - current rotation state
- ✅ Added `getPointTransactionHistory` query - detailed point ledger

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Error Handling](#error-handling)
4. [User Management](#user-management)
5. [Group Management](#group-management)
6. [Task Management](#task-management)
7. [Notifications](#notifications)
8. [Rewards & Gamification](#rewards--gamification)
9. [Statistics & Leaderboards](#statistics--leaderboards)
10. [Audit Logs](#audit-logs)
11. [Common Patterns](#common-patterns)
12. [Complete Examples](#complete-examples)

---

## Overview

### Base URL
```
POST /graphql
```

### Content-Type
```
Content-Type: application/json
```

### Request Format
```json
{
  "query": "GraphQL query or mutation string",
  "variables": {
    "variable1": "value1"
  }
}
```

### Response Format
```json
{
  "data": {
    // Requested data
  },
  "errors": [
    // Optional errors array
  ]
}
```

---

## Authentication

### Register User

**Mutation:** `register`

**Description:** Create a new user account and receive authentication tokens.

**Input:**
```graphql
input RegisterInput {
  email: String!      # Valid email address
  username: String!   # Unique username
  password: String!   # Minimum 6 characters
}
```

**Response:**
```graphql
type AuthResponseType {
  accessToken: String!   # JWT access token (15 min expiry)
  refreshToken: String!  # JWT refresh token (7 days expiry)
  user: UserType!        # User profile
}
```

**Example:**
```graphql
mutation Register($input: RegisterInput!) {
  register(input: $input) {
    accessToken
    refreshToken
    user {
      id
      email
      username
      createdAt
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "email": "user@example.com",
    "username": "john_doe",
    "password": "SecurePass123!"
  }
}
```

**Success Response:**
```json
{
  "data": {
    "register": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "clx1234567890",
        "email": "user@example.com",
        "username": "john_doe",
        "createdAt": "2025-11-14T10:30:00.000Z"
      }
    }
  }
}
```

---

### Login User

**Mutation:** `login`

**Description:** Authenticate user and receive tokens.

**Example:**
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
      isAway
      awayUntil
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "email": "user@example.com",
    "password": "SecurePass123!"
  }
}
```

---

### Refresh Token

**Mutation:** `refreshToken`

**Description:** Get a new access token using refresh token. Implements token rotation (old refresh token becomes invalid).

**Example:**
```graphql
mutation RefreshToken($input: RefreshTokenInput!) {
  refreshToken(input: $input) {
    accessToken
    refreshToken
    user {
      id
      email
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Important Notes:**
- Old refresh token becomes invalid after rotation
- New refresh token is issued with each refresh
- Access token expires in 15 minutes
- Refresh token expires in 7 days

---

### Logout

**Mutation:** `logout`

**Description:** Revoke a specific refresh token (single device logout).

**Example:**
```graphql
mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
```

**Variables:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### Logout All Devices

**Mutation:** `logoutAll`

**Description:** Revoke all refresh tokens for current user (all devices logout).

**Requires:** Authentication (Bearer token)

**Example:**
```graphql
mutation LogoutAll {
  logoutAll
}
```

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** Number of tokens revoked

---

### Get Current User

**Query:** `me`

**Description:** Get authenticated user's profile.

**Requires:** Authentication

**Example:**
```graphql
query Me {
  me {
    id
    email
    username
    avatarUrl
    isAway
    awayUntil
    createdAt
    updatedAt
  }
}
```

---

### Change Password

**Mutation:** `changePassword`

**Description:** Update user password (requires current password).

**Example:**
```graphql
mutation ChangePassword($input: ChangePasswordInput!) {
  changePassword(input: $input)
}
```

**Variables:**
```json
{
  "input": {
    "oldPassword": "OldPass123!",
    "newPassword": "NewSecurePass456!"
  }
}
```

---

### Update User Profile

**Mutation:** `updateUser`

**Description:** Update username and/or avatar URL.

**Requires:** Authentication

**Example:**
```graphql
mutation UpdateUser($input: UpdateUserInput!) {
  updateUser(input: $input) {
    id
    username
    avatarUrl
    updatedAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "username": "newUsername",
    "avatarUrl": "https://example.com/avatar.jpg"
  }
}
```

**Validation:**
- `username`: 3-30 characters, alphanumeric + underscore only
- `avatarUrl`: Must be valid URL format
- Username must be unique (returns `CONFLICT` error if taken)

**Error Example:**
```json
{
  "errors": [
    {
      "message": "Username already taken",
      "extensions": {
        "code": "CONFLICT",
        "statusCode": 409
      }
    }
  ]
}
```

---

### Set Away Status

**Mutation:** `setUserAwayStatus`

**Description:** Set or clear "away" status to be excluded from task rotation.

**Requires:** Authentication

**Example (Set Away):**
```graphql
mutation SetAwayStatus($input: SetAwayStatusInput!) {
  setUserAwayStatus(input: $input) {
    id
    username
    isAway
    awayUntil
    updatedAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "isAway": true,
    "awayUntil": "2025-12-25T00:00:00.000Z"
  }
}
```

**Example (Clear Away Status):**
```json
{
  "input": {
    "isAway": false
  }
}
```

**Business Rules:**
- Users with `isAway = true` are automatically skipped in task rotation
- `awayUntil` must be a future date (if provided)
- If `isAway = false`, `awayUntil` must be null/omitted
- Backend cron job automatically clears status when `awayUntil` date passes

**Error Example:**
```json
{
  "errors": [
    {
      "message": "awayUntil must be in the future",
      "extensions": {
        "code": "BAD_REQUEST"
      }
    }
  ]
}
```

---

## Error Handling

### Common Error Responses

**Unauthorized (401):**
```json
{
  "errors": [
    {
      "message": "Требуется авторизация",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

**Forbidden (403):**
```json
{
  "errors": [
    {
      "message": "Только администраторы группы могут выполнять это действие",
      "extensions": {
        "code": "FORBIDDEN"
      }
    }
  ]
}
```

**Validation Error:**
```json
{
  "errors": [
    {
      "message": "Validation failed",
      "extensions": {
        "code": "BAD_USER_INPUT",
        "validationErrors": [
          "email must be a valid email"
        ]
      }
    }
  ]
}
```

**Not Found:**
```json
{
  "errors": [
    {
      "message": "Группа не найдена",
      "extensions": {
        "code": "NOT_FOUND"
      }
    }
  ]
}
```

---

## User Management

### User Statistics

**Query:** `myStatistics`

**Description:** Get statistics for current user (overall or group-specific).

**Example:**
```graphql
query MyStatistics($groupId: String) {
  myStatistics(groupId: $groupId) {
    userId
    currentPointBalance
    totalPointsEarned
    totalPointsSpent
    tasksCompleted
    tasksAssigned
    completionRate
    tasksCompletedOnTime
    onTimePercentage
    leaderboardPosition
    groupId
  }
}
```

**Variables:**
```json
{
  "groupId": "clx1234567890"  // Optional: null for overall stats
}
```

**Response:**
```json
{
  "data": {
    "myStatistics": {
      "userId": "clx9876543210",
      "currentPointBalance": 450,
      "totalPointsEarned": 500,
      "totalPointsSpent": 50,
      "tasksCompleted": 12,
      "tasksAssigned": 15,
      "completionRate": 80.0,
      "tasksCompletedOnTime": 10,
      "onTimePercentage": 83.33,
      "leaderboardPosition": 2,
      "groupId": "clx1234567890"
    }
  }
}
```

---

**Query:** `userStatistics`

**Description:** Get statistics for a specific user (requires user ID).

**Example:**
```graphql
query UserStats($userId: String!, $groupId: String) {
  userStatistics(userId: $userId, groupId: $groupId) {
    userId
    currentPointBalance
    totalPointsEarned
    tasksCompleted
    completionRate
    leaderboardPosition
  }
}
```

---

## Group Management

### Create Group

**Mutation:** `createGroup`

**Description:** Create a new group (creator becomes admin automatically).

**Input:**
```graphql
input CreateGroupInput {
  name: String!                      # Group name
  description: String                # Optional description
  requiresApproval: Boolean          # Default: true
  rotationType: String               # ROUND_ROBIN | RANDOM | LOAD_BALANCING | DISABLED
  gamificationEnabled: Boolean       # Default: true
}
```

**Example:**
```graphql
mutation CreateGroup($input: CreateGroupInput!) {
  createGroup(input: $input) {
    id
    name
    description
    inviteToken
    requiresApproval
    rotationType
    gamificationEnabled
    createdAt
    createdById
  }
}
```

**Variables:**
```json
{
  "input": {
    "name": "Family Chores",
    "description": "Weekly household tasks rotation",
    "requiresApproval": true,
    "rotationType": "ROUND_ROBIN",
    "gamificationEnabled": true
  }
}
```

**Response:**
```json
{
  "data": {
    "createGroup": {
      "id": "clx1234567890",
      "name": "Family Chores",
      "description": "Weekly household tasks rotation",
      "inviteToken": "abc123def456",
      "requiresApproval": true,
      "rotationType": "ROUND_ROBIN",
      "gamificationEnabled": true,
      "createdAt": "2025-11-14T10:30:00.000Z",
      "createdById": "clx9876543210"
    }
  }
}
```

---

### Get Group

**Query:** `getGroup`

**Description:** Get group details (must be a member).

**Example:**
```graphql
query GetGroup($groupId: String!) {
  getGroup(groupId: $groupId) {
    id
    name
    description
    inviteToken
    requiresApproval
    rotationType
    gamificationEnabled
    createdAt
    updatedAt
    createdById
  }
}
```

**Error if not a member:**
```json
{
  "errors": [
    {
      "message": "Вы не являетесь членом этой группы"
    }
  ]
}
```

---

### Get User Groups

**Query:** `getUserGroups`

**Description:** Get all groups current user is a member of.

**Example:**
```graphql
query GetUserGroups {
  getUserGroups {
    id
    name
    description
    requiresApproval
    rotationType
    gamificationEnabled
    createdAt
  }
}
```

---

### Update Group

**Mutation:** `updateGroup`

**Description:** Update group settings (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation UpdateGroup($groupId: String!, $input: UpdateGroupInput!) {
  updateGroup(groupId: $groupId, input: $input) {
    id
    name
    description
    requiresApproval
    rotationType
    gamificationEnabled
  }
}
```

**Variables:**
```json
{
  "groupId": "clx1234567890",
  "input": {
    "name": "Updated Family Chores",
    "description": "New description",
    "requiresApproval": false
  }
}
```

---

### Delete Group

**Mutation:** `deleteGroup`

**Description:** Delete a group permanently (creator only).

**Permissions:** Group Creator only (not just admin)

**Example:**
```graphql
mutation DeleteGroup($groupId: String!) {
  deleteGroup(groupId: $groupId)
}
```

**Error if not creator:**
```json
{
  "errors": [
    {
      "message": "Только создатель группы может её удалить"
    }
  ]
}
```

---

### Join Group

**Mutation:** `joinGroup`

**Description:** Join a group using invite token.

**Example:**
```graphql
mutation JoinGroup($input: JoinGroupInput!) {
  joinGroup(input: $input) {
    id
    name
    description
  }
}
```

**Variables:**
```json
{
  "input": {
    "inviteToken": "abc123def456"
  }
}
```

**Error if already a member:**
```json
{
  "errors": [
    {
      "message": "Вы уже являетесь членом этой группы"
    }
  ]
}
```

---

### Leave Group

**Mutation:** `leaveGroup`

**Description:** Leave a group (creator cannot leave).

**Example:**
```graphql
mutation LeaveGroup($groupId: String!) {
  leaveGroup(groupId: $groupId)
}
```

---

### Get Group Members

**Query:** `getGroupMembers`

**Description:** Get all members of a group with their roles.

**Example:**
```graphql
query GetGroupMembers($groupId: String!) {
  getGroupMembers(groupId: $groupId) {
    id
    userId
    groupId
    role
    joinedAt
    roleChangedAt
    user {
      id
      username
      avatarUrl
      isAway
      awayUntil
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "getGroupMembers": [
      {
        "id": "clxmem1234",
        "userId": "clxuser123",
        "groupId": "clxgroup456",
        "role": "ADMIN",
        "joinedAt": "2025-11-01T10:00:00.000Z",
        "roleChangedAt": "2025-11-01T10:00:00.000Z",
        "user": {
          "id": "clxuser123",
          "username": "john_doe",
          "avatarUrl": null,
          "isAway": false,
          "awayUntil": null
        }
      },
      {
        "id": "clxmem5678",
        "userId": "clxuser789",
        "groupId": "clxgroup456",
        "role": "MEMBER",
        "joinedAt": "2025-11-05T14:30:00.000Z",
        "roleChangedAt": "2025-11-05T14:30:00.000Z",
        "user": {
          "id": "clxuser789",
          "username": "jane_smith",
          "avatarUrl": "https://example.com/avatar.jpg",
          "isAway": true,
          "awayUntil": "2025-11-20T00:00:00.000Z"
        }
      }
    ]
  }
}
```

---

### Update Member Role

**Mutation:** `updateMemberRole`

**Description:** Change member's role (admin only).

**Permissions:** Group Administrator only

**Roles:** `ADMIN` | `MEMBER`

**Example:**
```graphql
mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
  updateMemberRole(groupId: $groupId, input: $input) {
    id
    userId
    role
    roleChangedAt
  }
}
```

**Variables:**
```json
{
  "groupId": "clx1234567890",
  "input": {
    "userId": "clxuser789",
    "role": "ADMIN"
  }
}
```

---

### Remove Member

**Mutation:** `removeMember`

**Description:** Remove a member from group (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation RemoveMember($groupId: String!, $userId: String!) {
  removeMember(groupId: $groupId, userId: $userId)
}
```

---

### Regenerate Invite Token

**Mutation:** `regenerateInviteToken`

**Description:** Generate a new invite token (invalidates old one).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation RegenerateInviteToken($groupId: String!) {
  regenerateInviteToken(groupId: $groupId)
}
```

**Response:** New invite token string

---

## Task Management

### Task Priorities
- `LOW` - Low priority
- `MEDIUM` - Medium priority (default)
- `HIGH` - High priority

### Task Status States
- `PENDING` - Assigned, not started
- `AWAITING_APPROVAL` - Completed, pending admin review
- `COMPLETED` - Approved and points awarded
- `OVERDUE` - Deadline passed

### Rotation Types
- `ROUND_ROBIN` - Cyclic rotation (oldest completion first)
- `RANDOM` - Random assignment
- `LOAD_BALANCING` - Weight-based balancing (imbalance >= 2x triggers redistribution)
- `DISABLED` - Manual assignment only (Up-for-Grabs pool)

---

### Create Task

**Mutation:** `createTask`

**Description:** Create a new task (admin only for group tasks).

**Permissions:** 
- Group Administrator: Can create group tasks
- Any Member: Can create personal tasks (not implemented in current phase)

**Input:**
```graphql
input CreateTaskInput {
  title: String!                     # Task title
  description: String                # Optional description
  deadline: String!                  # ISO 8601 datetime
  priority: String!                  # LOW | MEDIUM | HIGH
  points: Int!                       # Point reward (1-1000)
  requiresApproval: Boolean = true   # Default: true
  isRecurring: Boolean = false       # Recurring task flag
  recurrenceRule: String             # RFC 5545 RRULE format
  rotationType: String               # Override group rotation
  weight: Int = 1                    # Load balancing weight (1-10)
  groupId: String!                   # Group ID
  assigneeId: String                 # Optional: specific user assignment
}
```

**Example:**
```graphql
mutation CreateTask($input: CreateTaskInput!) {
  createTask(input: $input) {
    id
    title
    description
    deadline
    priority
    status
    points
    requiresApproval
    isRecurring
    recurrenceRule
    rotationType
    weight
    wasClaimedFromPool
    createdAt
    groupId
    createdById
    assigneeId
    assignee {
      id
      username
      avatarUrl
    }
    createdBy {
      id
      username
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "title": "Clean Kitchen",
    "description": "Deep clean kitchen including counters, appliances, and floor",
    "deadline": "2025-11-20T18:00:00.000Z",
    "priority": "HIGH",
    "points": 150,
    "requiresApproval": true,
    "isRecurring": false,
    "rotationType": "ROUND_ROBIN",
    "weight": 5,
    "groupId": "clx1234567890",
    "assigneeId": "clxuser789"
  }
}
```

**Auto-Assignment (Round Robin):**
```json
{
  "input": {
    "title": "Take Out Trash",
    "deadline": "2025-11-15T20:00:00.000Z",
    "priority": "MEDIUM",
    "points": 50,
    "groupId": "clx1234567890"
    // No assigneeId - will auto-assign via Round Robin
  }
}
```

**Up-for-Grabs Task (Unassigned):**
```json
{
  "input": {
    "title": "Organize Garage",
    "deadline": "2025-11-25T18:00:00.000Z",
    "priority": "LOW",
    "points": 200,
    "groupId": "clx1234567890",
    "rotationType": "DISABLED"
    // rotationType: DISABLED keeps task unassigned for claiming
  }
}
```

---

### Get Task

**Query:** `getTask`

**Description:** Get task details by ID.

**Example:**
```graphql
query GetTask($taskId: String!) {
  getTask(taskId: $taskId) {
    id
    title
    description
    deadline
    priority
    status
    points
    requiresApproval
    wasClaimedFromPool
    rejectionReason
    completedAt
    assignee {
      id
      username
      isAway
    }
    createdBy {
      id
      username
    }
  }
}
```

---

### Get Group Tasks

**Query:** `getGroupTasks`

**Description:** Get all tasks for a group (optional status filter).

**Example:**
```graphql
query GetGroupTasks($groupId: String!, $status: String) {
  getGroupTasks(groupId: $groupId, status: $status) {
    id
    title
    deadline
    priority
    status
    points
    assignee {
      id
      username
    }
  }
}
```

**Variables (with filter):**
```json
{
  "groupId": "clx1234567890",
  "status": "PENDING"  // Optional: PENDING | AWAITING_APPROVAL | COMPLETED | OVERDUE
}
```

---

### Get User Tasks

**Query:** `getUserTasks`

**Description:** Get all tasks assigned to current user (optional status filter).

**Example:**
```graphql
query GetUserTasks($status: String) {
  getUserTasks(status: $status) {
    id
    title
    description
    deadline
    priority
    status
    points
    requiresApproval
    groupId
  }
}
```

---

### Update Task

**Mutation:** `updateTask`

**Description:** Update task details (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation UpdateTask($taskId: String!, $input: UpdateTaskInput!) {
  updateTask(taskId: $taskId, input: $input) {
    id
    title
    description
    deadline
    priority
    points
  }
}
```

**Variables:**
```json
{
  "taskId": "clxtask123",
  "input": {
    "title": "Updated Task Title",
    "description": "Updated description",
    "priority": "HIGH",
    "points": 200
  }
}
```

---

### Delete Task

**Mutation:** `deleteTask`

**Description:** Delete a task permanently (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation DeleteTask($taskId: String!) {
  deleteTask(taskId: $taskId)
}
```

---

### Complete Task

**Mutation:** `completeTask`

**Description:** Mark task as completed (assignee only).

**Permissions:** Task assignee only

**State Transitions:**
- If `requiresApproval = true`: `PENDING` → `AWAITING_APPROVAL`
- If `requiresApproval = false`: `PENDING` → `COMPLETED` (auto-awards points)

**Example:**
```graphql
mutation CompleteTask($input: CompleteTaskInput!) {
  completeTask(input: $input) {
    id
    status
    completedAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "taskId": "clxtask123"
  }
}
```

**Error if not assignee:**
```json
{
  "errors": [
    {
      "message": "Только исполнитель задачи может её завершить"
    }
  ]
}
```

---

### Approve Task

**Mutation:** `approveTask`

**Description:** Approve or reject a completed task (admin only).

**Permissions:** Group Administrator only

**State Transitions:**
- If `approved = true`: `AWAITING_APPROVAL` → `COMPLETED` (awards points)
- If `approved = false`: `AWAITING_APPROVAL` → `PENDING` (no points, rejection reason stored)

**Example:**
```graphql
mutation ApproveTask($input: ApproveTaskInput!) {
  approveTask(input: $input) {
    id
    status
    completedAt
    rejectionReason
  }
}
```

**Variables (Approve):**
```json
{
  "input": {
    "taskId": "clxtask123",
    "approved": true
  }
}
```

**Variables (Reject):**
```json
{
  "input": {
    "taskId": "clxtask123",
    "approved": false,
    "rejectionReason": "Incomplete - please clean windows too"
  }
}
```

---

### Claim Task (Up-for-Grabs)

**Mutation:** `claimTask`

**Description:** Claim an unassigned task from the Up-for-Grabs pool.

**Point Multiplier:** 1.5x (bonus for claiming tasks)

**Example:**
```graphql
mutation ClaimTask($input: ClaimTaskInput!) {
  claimTask(input: $input) {
    id
    title
    status
    points
    wasClaimedFromPool
    assignee {
      id
      username
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "taskId": "clxtask456"
  }
}
```

**Response:**
```json
{
  "data": {
    "claimTask": {
      "id": "clxtask456",
      "title": "Organize Garage",
      "status": "PENDING",
      "points": 200,
      "wasClaimedFromPool": true,
      "assignee": {
        "id": "clxuser789",
        "username": "jane_smith"
      }
    }
  }
}
```

**Error if already assigned:**
```json
{
  "errors": [
    {
      "message": "Задача уже назначена исполнителю"
    }
  ]
}
```

---

### Point Calculation Formulas (PRD 3.5.1)

**Base Formula:**
```
Points Awarded = Base Points × Multiplier
```

**Multipliers:**
- **On-time completion:** 1.0x (deadline not passed)
- **Late completion:** 0.5x (deadline passed)
- **Up-for-Grabs claim:** 1.5x (bonus for claiming unassigned tasks)
- **Rejected task:** 0.0x (no points awarded)
- **Overdue task:** 0.0x (automatically failed)

**Examples:**
- Task with 100 points, completed on-time: 100 × 1.0 = **100 points**
- Task with 100 points, completed late: 100 × 0.5 = **50 points**
- Task with 100 points, claimed from pool: 100 × 1.5 = **150 points**
- Task with 100 points, rejected: 100 × 0.0 = **0 points**

---

### Get Rotation Schedule

**Query:** `getRotationSchedule`

**Description:** Get upcoming task assignments through rotation system (next 30 days).

**Requires:** Authentication + Group membership

**Note:** Currently returns empty array until recurring task scheduler is implemented (Phase 9).

**Example:**
```graphql
query GetRotationSchedule($groupId: ID!) {
  getRotationSchedule(groupId: $groupId) {
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

**Variables:**
```json
{
  "groupId": "clxgroup123"
}
```

**Response (when Phase 9 scheduler is implemented):**
```json
{
  "data": {
    "getRotationSchedule": [
      {
        "taskId": "clxtask789",
        "taskTitle": "Wash dishes",
        "userId": "clxuser456",
        "username": "john_doe",
        "avatarUrl": "https://example.com/avatar.jpg",
        "scheduledDate": "2025-11-18T09:00:00.000Z",
        "rotationType": "ROUND_ROBIN",
        "priority": "MEDIUM",
        "points": 100
      }
    ]
  }
}
```

**Current Response:**
```json
{
  "data": {
    "getRotationSchedule": []
  }
}
```

---

### Get Rotation History

**Query:** `getRotationHistory`

**Description:** Get paginated history of past task assignments through rotation.

**Requires:** Authentication + Group membership

**Example:**
```graphql
query GetRotationHistory($groupId: ID!, $limit: Int, $offset: Int) {
  getRotationHistory(groupId: $groupId, limit: $limit, offset: $offset) {
    items {
      taskId
      taskTitle
      userId
      username
      avatarUrl
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

**Variables:**
```json
{
  "groupId": "clxgroup123",
  "limit": 20,
  "offset": 0
}
```

**Response:**
```json
{
  "data": {
    "getRotationHistory": {
      "items": [
        {
          "taskId": "clxtask123",
          "taskTitle": "Wash dishes",
          "userId": "clxuser456",
          "username": "john_doe",
          "avatarUrl": "https://example.com/avatar.jpg",
          "assignedAt": "2025-11-10T09:00:00.000Z",
          "completedAt": "2025-11-10T14:30:00.000Z",
          "status": "COMPLETED",
          "rotationType": "ROUND_ROBIN",
          "pointsEarned": 100
        }
      ],
      "total": 45
    }
  }
}
```

**Notes:**
- Returns only tasks assigned through rotation (not manual assignments)
- Sorted by `assignedAt` descending (newest first)
- Supports pagination with `limit` and `offset`

---

### Get Rotation Pattern

**Query:** `getRotationPattern`

**Description:** Get current rotation configuration and cycle state for a group.

**Requires:** Authentication + Group membership

**Example:**
```graphql
query GetRotationPattern($groupId: ID!) {
  getRotationPattern(groupId: $groupId) {
    rotationType
    currentCycle
    currentCycleIndex
    lastRotationAt
    nextRotationAt
    activeMembers {
      id
      username
      avatarUrl
      isAway
      awayUntil
    }
    awayMembers {
      id
      username
      avatarUrl
      isAway
      awayUntil
    }
  }
}
```

**Variables:**
```json
{
  "groupId": "clxgroup123"
}
```

**Response:**
```json
{
  "data": {
    "getRotationPattern": {
      "rotationType": "ROUND_ROBIN",
      "currentCycle": ["clxuser123", "clxuser456", "clxuser789"],
      "currentCycleIndex": 1,
      "lastRotationAt": "2025-11-15T10:00:00.000Z",
      "nextRotationAt": "2025-11-18T09:00:00.000Z",
      "activeMembers": [
        {
          "id": "clxuser123",
          "username": "alice",
          "avatarUrl": "https://example.com/alice.jpg",
          "isAway": false,
          "awayUntil": null
        },
        {
          "id": "clxuser456",
          "username": "bob",
          "avatarUrl": null,
          "isAway": false,
          "awayUntil": null
        }
      ],
      "awayMembers": [
        {
          "id": "clxuser789",
          "username": "charlie",
          "avatarUrl": null,
          "isAway": true,
          "awayUntil": "2025-12-25T00:00:00.000Z"
        }
      ]
    }
  }
}
```

**Notes:**
- `currentCycle`: Array of user IDs in rotation order (for ROUND_ROBIN)
- `currentCycleIndex`: Next user to receive assignment (0-based index)
- `activeMembers`: Users available for task assignment (not away)
- `awayMembers`: Users currently marked as away

---

## Notifications

### Notification Types

```graphql
enum NotificationTypeEnum {
  TASK_ASSIGNED       # Task assigned to user
  TASK_COMPLETED      # Task marked as completed
  TASK_APPROVED       # Task approved by admin
  TASK_REJECTED       # Task rejected by admin
  REWARD_REQUESTED    # User requested reward
  REWARD_APPROVED     # Reward request approved
  REWARD_REJECTED     # Reward request rejected
  POINT_AWARDED       # Points awarded for task
  INVITATION          # Group invitation
  SYSTEM              # System notification
}
```

---

### Get My Notifications

**Query:** `myNotifications`

**Description:** Get notifications for current user with filtering and pagination.

**Example:**
```graphql
query MyNotifications($input: ListNotificationsInput) {
  myNotifications(input: $input) {
    total
    items {
      id
      title
      message
      type
      isRead
      relatedEntityType
      relatedEntityId
      createdAt
    }
  }
}
```

**Variables (All notifications):**
```json
{
  "input": {
    "limit": 20,
    "offset": 0
  }
}
```

**Variables (Unread only):**
```json
{
  "input": {
    "isRead": false,
    "limit": 50
  }
}
```

**Variables (Specific type):**
```json
{
  "input": {
    "type": "TASK_ASSIGNED",
    "limit": 10
  }
}
```

**Response:**
```json
{
  "data": {
    "myNotifications": {
      "total": 15,
      "items": [
        {
          "id": "clxnotif123",
          "title": "New Task Assigned",
          "message": "You have been assigned task: Clean Kitchen",
          "type": "TASK_ASSIGNED",
          "isRead": false,
          "relatedEntityType": "Task",
          "relatedEntityId": "clxtask789",
          "createdAt": "2025-11-14T10:30:00.000Z"
        },
        {
          "id": "clxnotif456",
          "title": "Points Awarded",
          "message": "You earned 150 points for completing 'Take Out Trash' (Up-for-Grabs bonus)",
          "type": "POINT_AWARDED",
          "isRead": false,
          "relatedEntityType": "Task",
          "relatedEntityId": "clxtask123",
          "createdAt": "2025-11-14T09:15:00.000Z"
        }
      ]
    }
  }
}
```

---

### Mark Notifications as Read

**Mutation:** `markNotificationsRead`

**Description:** Mark specific notifications as read.

**Example:**
```graphql
mutation MarkNotificationsRead($input: MarkNotificationsReadInput!) {
  markNotificationsRead(input: $input)
}
```

**Variables:**
```json
{
  "input": {
    "ids": ["clxnotif123", "clxnotif456", "clxnotif789"]
  }
}
```

---

### Mark All Notifications as Read

**Mutation:** `markAllNotificationsRead`

**Description:** Mark all notifications for current user as read.

**Example:**
```graphql
mutation MarkAllNotificationsRead {
  markAllNotificationsRead
}
```

---

### Push Notifications (Phase 8)

#### Register Device Token

**Mutation:** `registerDeviceToken`

**Description:** Register a device for push notifications.

**Example:**
```graphql
mutation RegisterDeviceToken($input: RegisterDeviceTokenInput!) {
  registerDeviceToken(input: $input) {
    id
    token
    provider
    platform
    createdAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "token": "fcm_token_here...",
    "provider": "FCM",
    "platform": "Android"
  }
}
```

---

#### Remove Device Token

**Mutation:** `removeDeviceToken`

**Example:**
```graphql
mutation RemoveDeviceToken($input: RemoveDeviceTokenInput!) {
  removeDeviceToken(input: $input)
}
```

---

#### Get My Device Tokens

**Query:** `myDeviceTokens`

**Example:**
```graphql
query MyDeviceTokens {
  myDeviceTokens {
    id
    token
    provider
    platform
    createdAt
    updatedAt
  }
}
```

---

#### Send Test Push Notification

**Mutation:** `sendTestPush`

**Description:** Send a test push notification to all registered devices.

**Example:**
```graphql
mutation SendTestPush($input: TestPushInput!) {
  sendTestPush(input: $input) {
    success
    messageId
    error
  }
}
```

**Variables:**
```json
{
  "input": {
    "title": "Test Notification",
    "body": "This is a test push notification",
    "data": {
      "type": "test",
      "timestamp": "2025-11-14T10:30:00Z"
    }
  }
}
```

---

### Notification Preferences

#### Get My Notification Preference

**Query:** `myNotificationPreference`

**Example:**
```graphql
query MyNotificationPreference {
  myNotificationPreference {
    id
    enablePush
    quietHoursStart
    quietHoursEnd
    mutedTypes
    batchingEnabled
    createdAt
    updatedAt
  }
}
```

---

#### Update Notification Preference

**Mutation:** `upsertNotificationPreference`

**Example:**
```graphql
mutation UpsertNotificationPreference($input: UpsertNotificationPreferenceInput!) {
  upsertNotificationPreference(input: $input) {
    id
    enablePush
    quietHoursStart
    quietHoursEnd
    mutedTypes
    batchingEnabled
  }
}
```

**Variables:**
```json
{
  "input": {
    "enablePush": true,
    "quietHoursStart": "22:00",
    "quietHoursEnd": "07:00",
    "mutedTypes": ["SYSTEM"],
    "batchingEnabled": false
  }
}
```

---

## Rewards & Gamification

### Get Point Transaction History

**Query:** `getPointTransactionHistory`

**Description:** Get detailed paginated history of point earnings and spendings.

**Requires:** Authentication (user sees only their own transactions)

**Example:**
```graphql
query GetPointTransactionHistory($groupId: String, $limit: Int, $offset: Int) {
  getPointTransactionHistory(groupId: $groupId, limit: $limit, offset: $offset) {
    items {
      id
      type
      amount
      description
      relatedTaskId
      relatedTaskTitle
      relatedRewardId
      relatedRewardName
      createdAt
    }
    total
  }
}
```

**Variables (All transactions):**
```json
{
  "limit": 20,
  "offset": 0
}
```

**Variables (Filtered by group):**
```json
{
  "groupId": "clxgroup123",
  "limit": 20,
  "offset": 0
}
```

**Response:**
```json
{
  "data": {
    "getPointTransactionHistory": {
      "items": [
        {
          "id": "clxtx123",
          "type": "EARNED",
          "amount": 150,
          "description": "Выполнение задачи: Wash dishes (+50% бонус)",
          "relatedTaskId": "clxtask456",
          "relatedTaskTitle": "Wash dishes",
          "relatedRewardId": null,
          "relatedRewardName": null,
          "createdAt": "2025-11-15T14:30:00.000Z"
        },
        {
          "id": "clxtx124",
          "type": "SPENT",
          "amount": -100,
          "description": "Награда: Movie Night",
          "relatedTaskId": null,
          "relatedTaskTitle": null,
          "relatedRewardId": "clxreward789",
          "relatedRewardName": "Movie Night",
          "createdAt": "2025-11-14T10:00:00.000Z"
        },
        {
          "id": "clxtx125",
          "type": "RESERVED",
          "amount": -50,
          "description": "Резерв для награды: Ice Cream",
          "relatedTaskId": null,
          "relatedTaskTitle": null,
          "relatedRewardId": "clxreward456",
          "relatedRewardName": "Ice Cream",
          "createdAt": "2025-11-13T16:00:00.000Z"
        }
      ],
      "total": 127
    }
  }
}
```

**Transaction Types:**
- `EARNED`: Points awarded from task completion
- `SPENT`: Points spent on approved reward
- `RESERVED`: Points reserved for pending reward request
- `REFUNDED`: Points refunded from rejected reward request

**Description Formats:**
- EARNED: `"Выполнение задачи: {taskTitle}"` or `"Выполнение задачи: {taskTitle} (+50% бонус)"`
- SPENT: `"Награда: {rewardName}"`
- RESERVED: `"Резерв для награды: {rewardName}"`
- REFUNDED: `"Возврат за отклоненную награду: {rewardName}"`

**Notes:**
- Sorted by `createdAt` descending (newest first)
- If `groupId` is null/omitted, returns transactions from all groups
- Supports pagination with `limit` (default: 50) and `offset` (default: 0)

---

### Create Reward

**Mutation:** `createReward`

**Description:** Create a reward item (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation CreateReward($input: CreateRewardInput!) {
  createReward(input: $input) {
    id
    name
    description
    cost
    isActive
    imageUrl
    groupId
    createdById
    createdAt
  }
}
```

**Variables:**
```json
{
  "input": {
    "groupId": "clx1234567890",
    "name": "Ice Cream Treat",
    "description": "Choose your favorite flavor",
    "cost": 100,
    "imageUrl": "https://example.com/ice-cream.jpg",
    "isActive": true
  }
}
```

---

### Update Reward

**Mutation:** `updateReward`

**Description:** Update reward details (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation UpdateReward($input: UpdateRewardInput!) {
  updateReward(input: $input) {
    id
    name
    cost
    description
    isActive
  }
}
```

**Variables:**
```json
{
  "input": {
    "rewardId": "clxreward123",
    "groupId": "clx1234567890",
    "name": "Premium Ice Cream",
    "cost": 150,
    "isActive": true
  }
}
```

---

### Delete Reward

**Mutation:** `deleteReward`

**Description:** Delete a reward (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
mutation DeleteReward($rewardId: String!, $groupId: String!) {
  deleteReward(rewardId: $rewardId, groupId: $groupId)
}
```

---

### Get Group Rewards

**Query:** `getGroupRewards`

**Description:** List all active rewards for a group.

**Example:**
```graphql
query GetGroupRewards($groupId: String!) {
  getGroupRewards(groupId: $groupId) {
    id
    name
    description
    cost
    isActive
    imageUrl
    createdAt
  }
}
```

---

### Request Reward

**Mutation:** `requestReward`

**Description:** Request to redeem a reward using points.

**Business Rules:**
1. User must have sufficient earned points
2. Points are moved to "Reserved" status immediately
3. Admin approval required before final point deduction
4. If rejected, reserved points are refunded

**Example:**
```graphql
mutation RequestReward($input: RequestRewardInput!) {
  requestReward(input: $input) {
    id
    pointsSpent
    status
    requestedAt
    userId
    rewardId
  }
}
```

**Variables:**
```json
{
  "input": {
    "rewardId": "clxreward123"
  }
}
```

**Response:**
```json
{
  "data": {
    "requestReward": {
      "id": "clxreqtx123",
      "pointsSpent": 100,
      "status": "RESERVED",
      "requestedAt": "2025-11-14T10:30:00.000Z",
      "userId": "clxuser789",
      "rewardId": "clxreward123"
    }
  }
}
```

**Error if insufficient points:**
```json
{
  "errors": [
    {
      "message": "Недостаточно очков для обмена (доступно: 50, требуется: 100)"
    }
  ]
}
```

---

### Approve Reward Request

**Mutation:** `approveRewardRequest`

**Description:** Approve or reject a reward request (admin only).

**Permissions:** Group Administrator only

**State Transitions:**
- If `approved = true`: `RESERVED` → `APPROVED` (points deducted permanently)
- If `approved = false`: `RESERVED` → `REJECTED` (points refunded)

**Example (Approve):**
```graphql
mutation ApproveRewardRequest($input: ApproveRewardRequestInput!) {
  approveRewardRequest(input: $input) {
    id
    status
    approvedAt
    rejectedAt
    rejectionReason
    approvedById
  }
}
```

**Variables (Approve):**
```json
{
  "input": {
    "requestId": "clxreqtx123",
    "approved": true
  }
}
```

**Variables (Reject):**
```json
{
  "input": {
    "requestId": "clxreqtx123",
    "approved": false,
    "reason": "Reward temporarily unavailable"
  }
}
```

---

### Get My Reward Requests

**Query:** `getMyRewardRequests`

**Description:** Get all reward requests for current user (optional group filter).

**Example:**
```graphql
query GetMyRewardRequests($groupId: String) {
  getMyRewardRequests(groupId: $groupId) {
    id
    pointsSpent
    status
    requestedAt
    approvedAt
    rejectedAt
    rejectionReason
    rewardId
    userId
    approvedById
  }
}
```

---

### Get Group Reward Requests

**Query:** `getGroupRewardRequests`

**Description:** Get all reward requests for a group (admin only).

**Permissions:** Group Administrator only

**Example:**
```graphql
query GetGroupRewardRequests($groupId: String!) {
  getGroupRewardRequests(groupId: $groupId) {
    id
    pointsSpent
    status
    requestedAt
    userId
    rewardId
  }
}
```

---

### Get Point Balance

**Query:** `getPointBalance`

**Description:** Get detailed point balance breakdown for current user.

**Example:**
```graphql
query GetPointBalance($groupId: String) {
  getPointBalance(groupId: $groupId) {
    totalEarned
    totalSpentApproved
    totalReservedPending
    currentBalance
    availableBalance
  }
}
```

**Response:**
```json
{
  "data": {
    "getPointBalance": {
      "totalEarned": 500,
      "totalSpentApproved": 100,
      "totalReservedPending": 50,
      "currentBalance": 400,
      "availableBalance": 350
    }
  }
}
```

**Calculations:**
- `currentBalance = totalEarned - totalSpentApproved`
- `availableBalance = totalEarned - totalSpentApproved - totalReservedPending`

---

## Statistics & Leaderboards

### Get Group Leaderboard

**Query:** `getGroupLeaderboard`

**Description:** Get leaderboard ranked by total earned points (descending).

**Example:**
```graphql
query GetGroupLeaderboard($groupId: String!) {
  getGroupLeaderboard(groupId: $groupId) {
    userId
    points
    rank
  }
}
```

**Response:**
```json
{
  "data": {
    "getGroupLeaderboard": [
      {
        "userId": "clxuser123",
        "points": 750,
        "rank": 1
      },
      {
        "userId": "clxuser456",
        "points": 500,
        "rank": 2
      },
      {
        "userId": "clxuser789",
        "points": 250,
        "rank": 3
      }
    ]
  }
}
```

---

## Audit Logs

### Get Audit Logs

**Query:** `getAuditLogs`

**Description:** Get audit logs with filtering and pagination (admin only).

**Permissions:** System Administrator (future implementation)

**Example:**
```graphql
query GetAuditLogs($input: GetAuditLogsInput) {
  getAuditLogs(input: $input) {
    total
    limit
    offset
    logs {
      id
      action
      entityType
      entityId
      oldValues
      newValues
      performedAt
      ipAddress
      userId
      user {
        id
        username
        email
      }
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "entityType": "Task",
    "action": "CREATE",
    "startDate": "2025-11-01T00:00:00Z",
    "endDate": "2025-11-14T23:59:59Z",
    "limit": 50,
    "offset": 0
  }
}
```

---

### Get Task Audit Log

**Query:** `getTaskAuditLog`

**Description:** Get all audit entries for a specific task.

**Example:**
```graphql
query GetTaskAuditLog($taskId: String!) {
  getTaskAuditLog(taskId: $taskId) {
    id
    action
    entityType
    entityId
    oldValues
    newValues
    performedAt
    user {
      id
      username
    }
  }
}
```

---

### Get Group Audit Log

**Query:** `getGroupAuditLog`

**Description:** Get all audit entries for a specific group.

**Example:**
```graphql
query GetGroupAuditLog($groupId: String!) {
  getGroupAuditLog(groupId: $groupId) {
    id
    action
    entityType
    performedAt
    user {
      username
    }
  }
}
```

---

### Get My Audit Logs

**Query:** `getMyAuditLogs`

**Description:** Get audit logs for current user's actions.

**Example:**
```graphql
query GetMyAuditLogs($limit: Float) {
  getMyAuditLogs(limit: $limit) {
    id
    action
    entityType
    entityId
    performedAt
  }
}
```

---

## Common Patterns

### Pagination Pattern

Most list queries support pagination:

```graphql
input ListInput {
  limit: Int      # Number of items per page
  offset: Int     # Number of items to skip
}
```

**Example:**
```json
{
  "limit": 20,
  "offset": 40  // Page 3 (0-19, 20-39, 40-59)
}
```

---

### Error Handling Pattern

Always check for `errors` array in response:

```typescript
const response = await graphqlClient.query({
  query: GET_TASKS,
  variables: { groupId }
});

if (response.errors) {
  // Handle errors
  console.error(response.errors[0].message);
} else {
  // Use data
  const tasks = response.data.getGroupTasks;
}
```

---

### Authentication Pattern

Include JWT token in Authorization header:

```typescript
const headers = {
  'Authorization': `Bearer ${accessToken}`,
  'Content-Type': 'application/json'
};
```

---

### Refresh Token Pattern

Implement token refresh before expiration:

```typescript
// Access token expires in 15 minutes
// Refresh proactively at 14 minutes

let accessToken = localStorage.getItem('accessToken');
let refreshToken = localStorage.getItem('refreshToken');

// Periodically check and refresh
setInterval(async () => {
  if (shouldRefresh(accessToken)) {
    const response = await refreshTokenMutation(refreshToken);
    accessToken = response.data.refreshToken.accessToken;
    refreshToken = response.data.refreshToken.refreshToken; // New token!
    
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
  }
}, 60000); // Check every minute
```

---

## Complete Examples

### Example 1: User Registration and First Task Completion

```graphql
# Step 1: Register user
mutation Register {
  register(input: {
    email: "alice@example.com"
    username: "alice"
    password: "SecurePass123!"
  }) {
    accessToken
    refreshToken
    user {
      id
      username
    }
  }
}

# Step 2: Create a group
mutation CreateGroup {
  createGroup(input: {
    name: "Family Tasks"
    requiresApproval: true
    rotationType: "ROUND_ROBIN"
    gamificationEnabled: true
  }) {
    id
    inviteToken
  }
}

# Step 3: Get invite token and share with family

# Step 4: Bob joins group
mutation JoinGroup {
  joinGroup(input: {
    inviteToken: "abc123def456"
  }) {
    id
    name
  }
}

# Step 5: Alice creates task (auto-assigned to Bob via Round Robin)
mutation CreateTask {
  createTask(input: {
    title: "Wash Dishes"
    deadline: "2025-11-15T20:00:00Z"
    priority: "MEDIUM"
    points: 50
    groupId: "clxgroup123"
  }) {
    id
    assignee {
      username
    }
  }
}

# Step 6: Bob completes task
mutation CompleteTask {
  completeTask(input: {
    taskId: "clxtask456"
  }) {
    id
    status  # AWAITING_APPROVAL
  }
}

# Step 7: Alice approves task
mutation ApproveTask {
  approveTask(input: {
    taskId: "clxtask456"
    approved: true
  }) {
    id
    status  # COMPLETED
  }
}

# Step 8: Bob checks points
query MyStatistics {
  myStatistics(groupId: "clxgroup123") {
    currentPointBalance  # 50 points
    totalPointsEarned    # 50 points
    tasksCompleted       # 1
  }
}
```

---

### Example 2: Up-for-Grabs Task with Bonus Points

```graphql
# Step 1: Admin creates unassigned task
mutation CreateUpForGrabsTask {
  createTask(input: {
    title: "Deep Clean Basement"
    description: "Requires 3-4 hours of work"
    deadline: "2025-11-20T18:00:00Z"
    priority: "HIGH"
    points: 300
    requiresApproval: false
    rotationType: "DISABLED"
    groupId: "clxgroup123"
  }) {
    id
    assignee  # null - unassigned
  }
}

# Step 2: Member claims task
mutation ClaimTask {
  claimTask(input: {
    taskId: "clxtask789"
  }) {
    id
    assignee {
      username
    }
    wasClaimedFromPool  # true
  }
}

# Step 3: Member completes task (auto-complete, no approval)
mutation CompleteTask {
  completeTask(input: {
    taskId: "clxtask789"
  }) {
    id
    status  # COMPLETED immediately
  }
}

# Step 4: Check points awarded
query MyStatistics {
  myStatistics(groupId: "clxgroup123") {
    totalPointsEarned  # 450 points (300 × 1.5 bonus)
  }
}
```

---

### Example 3: Reward Redemption Flow

```graphql
# Step 1: Admin creates reward
mutation CreateReward {
  createReward(input: {
    groupId: "clxgroup123"
    name: "Movie Night"
    description: "Choose any movie on streaming service"
    cost: 200
  }) {
    id
  }
}

# Step 2: Member earns points (from completing tasks)
# ... tasks completed ...

# Step 3: Member checks available balance
query GetPointBalance {
  getPointBalance(groupId: "clxgroup123") {
    availableBalance  # 350 points
  }
}

# Step 4: Member requests reward
mutation RequestReward {
  requestReward(input: {
    rewardId: "clxreward123"
  }) {
    id
    status  # RESERVED
    pointsSpent  # 200
  }
}

# Step 5: Check updated balance
query GetPointBalance {
  getPointBalance(groupId: "clxgroup123") {
    availableBalance  # 150 (350 - 200 reserved)
    totalReservedPending  # 200
  }
}

# Step 6: Admin approves request
mutation ApproveRewardRequest {
  approveRewardRequest(input: {
    requestId: "clxreqtx123"
    approved: true
  }) {
    id
    status  # APPROVED
  }
}

# Step 7: Final balance
query GetPointBalance {
  getPointBalance(groupId: "clxgroup123") {
    currentBalance  # 150 (350 - 200 spent)
    totalSpentApproved  # 200
    totalReservedPending  # 0
  }
}
```

---

### Example 4: Load Balancing Rotation

```graphql
# Scenario: Alice has completed many heavy tasks, Bob has done light tasks
# Next task should preferably go to Bob to balance workload

# Step 1: Check current load (via completion history)
query GroupMembers {
  getGroupMembers(groupId: "clxgroup123") {
    user {
      username
    }
  }
}

# Alice's history: 3 tasks, weight 10 each = 30 total
# Bob's history: 2 tasks, weight 5 each = 10 total
# Imbalance ratio: 30/10 = 3.0x (>= 2x threshold)

# Step 2: Create heavy task without assignee
mutation CreateTask {
  createTask(input: {
    title: "Organize Attic"
    deadline: "2025-11-18T18:00:00Z"
    priority: "HIGH"
    points: 200
    weight: 8  # Heavy task
    rotationType: "LOAD_BALANCING"
    groupId: "clxgroup123"
  }) {
    id
    assignee {
      username  # "Bob" - assigned to lowest load
    }
  }
}

# If imbalance was < 2x, would fall back to Round Robin
```

---

### Example 5: Handling Late Task Completion

```graphql
# Scenario: Task deadline is 2025-11-15 20:00, completed on 2025-11-16 10:00

# Step 1: Task created
mutation CreateTask {
  createTask(input: {
    title: "Water Plants"
    deadline: "2025-11-15T20:00:00Z"
    priority: "MEDIUM"
    points: 50
    requiresApproval: false
    groupId: "clxgroup123"
    assigneeId: "clxuser123"
  }) {
    id
  }
}

# Step 2: User completes task late (after deadline)
mutation CompleteTask {
  completeTask(input: {
    taskId: "clxtask999"
  }) {
    id
    status  # COMPLETED
  }
}

# Step 3: Check completion history
query GetTaskAuditLog {
  getTaskAuditLog(taskId: "clxtask999") {
    id
    action
    newValues  # Check wasOnTime field
  }
}

# Points awarded: 50 × 0.5 (late multiplier) = 25 points

# Step 4: Verify points
query MyStatistics {
  myStatistics(groupId: "clxgroup123") {
    totalPointsEarned  # Includes 25 points (not 50)
    onTimePercentage   # Decreased
  }
}
```

---

### Example 6: Notification Flow

```graphql
# Step 1: Admin assigns task to member
mutation CreateTask {
  createTask(input: {
    title: "Mow Lawn"
    deadline: "2025-11-16T18:00:00Z"
    priority: "HIGH"
    points: 150
    groupId: "clxgroup123"
    assigneeId: "clxuser789"
  }) {
    id
  }
}
# System automatically creates TASK_ASSIGNED notification

# Step 2: Member checks notifications
query MyNotifications {
  myNotifications(input: { isRead: false, limit: 10 }) {
    total
    items {
      id
      title
      message
      type  # TASK_ASSIGNED
      relatedEntityId  # clxtask123
    }
  }
}

# Step 3: Member marks notification as read
mutation MarkNotificationsRead {
  markNotificationsRead(input: {
    ids: ["clxnotif123"]
  })
}

# Step 4: Member completes task
mutation CompleteTask {
  completeTask(input: { taskId: "clxtask123" }) {
    id
  }
}
# System creates TASK_COMPLETED notification for admin

# Step 5: Admin approves
mutation ApproveTask {
  approveTask(input: { taskId: "clxtask123", approved: true }) {
    id
  }
}
# System creates:
# - TASK_APPROVED notification for member
# - POINT_AWARDED notification for member

# Step 6: Member sees new notifications
query MyNotifications {
  myNotifications(input: { isRead: false }) {
    items {
      type  # TASK_APPROVED, POINT_AWARDED
      message
    }
  }
}
```

---

## Best Practices

### 1. Always Use Variables

❌ **Bad:**
```graphql
mutation {
  createTask(input: {
    title: "Task"
    deadline: "2025-11-15"
    priority: "MEDIUM"
    points: 50
    groupId: "clx123"
  }) {
    id
  }
}
```

✅ **Good:**
```graphql
mutation CreateTask($input: CreateTaskInput!) {
  createTask(input: $input) {
    id
  }
}
```

### 2. Request Only Needed Fields

❌ **Bad:**
```graphql
query {
  getUserTasks {
    id
    title
    description
    deadline
    priority
    status
    points
    requiresApproval
    isRecurring
    recurrenceRule
    rotationType
    weight
    # ... all fields
  }
}
```

✅ **Good:**
```graphql
query {
  getUserTasks {
    id
    title
    deadline
    status
    points
  }
}
```

### 3. Handle Errors Gracefully

```typescript
async function executeQuery(query, variables) {
  try {
    const response = await fetch('/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      },
      body: JSON.stringify({ query, variables })
    });
    
    const result = await response.json();
    
    if (result.errors) {
      // Handle GraphQL errors
      const errorMessage = result.errors[0].message;
      
      if (errorMessage.includes('Требуется авторизация')) {
        // Redirect to login
      } else if (errorMessage.includes('администраторы')) {
        // Show permission error
      } else {
        // Generic error
      }
      
      throw new Error(errorMessage);
    }
    
    return result.data;
  } catch (error) {
    // Handle network errors
    console.error('GraphQL request failed:', error);
    throw error;
  }
}
```

### 4. Implement Token Refresh

```typescript
let tokenRefreshPromise = null;

async function getValidAccessToken() {
  const token = localStorage.getItem('accessToken');
  const expiresAt = localStorage.getItem('tokenExpiresAt');
  
  // Refresh 1 minute before expiry
  if (Date.now() >= expiresAt - 60000) {
    if (!tokenRefreshPromise) {
      tokenRefreshPromise = refreshAccessToken();
    }
    return await tokenRefreshPromise;
  }
  
  return token;
}

async function refreshAccessToken() {
  const refreshToken = localStorage.getItem('refreshToken');
  
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query: `
        mutation RefreshToken($input: RefreshTokenInput!) {
          refreshToken(input: $input) {
            accessToken
            refreshToken
          }
        }
      `,
      variables: {
        input: { refreshToken }
      }
    })
  });
  
  const result = await response.json();
  
  if (result.errors) {
    // Refresh token invalid - redirect to login
    localStorage.clear();
    window.location.href = '/login';
    throw new Error('Session expired');
  }
  
  const { accessToken, refreshToken: newRefreshToken } = result.data.refreshToken;
  
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', newRefreshToken);
  localStorage.setItem('tokenExpiresAt', Date.now() + 15 * 60 * 1000);
  
  tokenRefreshPromise = null;
  return accessToken;
}
```

### 5. Optimize with Batching

Use GraphQL batching for multiple queries:

```graphql
query DashboardData($groupId: String!) {
  myStatistics(groupId: $groupId) {
    currentPointBalance
    tasksCompleted
    leaderboardPosition
  }
  
  getUserTasks(status: "PENDING") {
    id
    title
    deadline
    points
  }
  
  myNotifications(input: { isRead: false, limit: 5 }) {
    total
    items {
      id
      title
      type
    }
  }
  
  getGroupRewards(groupId: $groupId) {
    id
    name
    cost
  }
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Authentication endpoints:** 5 requests per minute per IP
- **GraphQL queries:** 100 requests per minute per user
- **GraphQL mutations:** 50 requests per minute per user

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1699876543
```

**Rate Limit Exceeded Response:**
```json
{
  "errors": [
    {
      "message": "Rate limit exceeded. Please try again in 30 seconds.",
      "extensions": {
        "code": "RATE_LIMIT_EXCEEDED"
      }
    }
  ]
}
```

---

## Changelog

### Version 1.0 (2025-11-14)
- Initial release
- Complete authentication flow with JWT refresh tokens
- Group management (CRUD, members, roles)
- Task management (CRUD, state machine, rotation algorithms)
- Notification system (in-app + push)
- Rewards & gamification (point system, leaderboard)
- Statistics & audit logs
- All examples verified against e2e tests

---

## Support

For issues or questions:
- **Repository:** TaskFlow Backend
- **Documentation:** `.docs/` directory
- **PRD Reference:** `.docs/PRD.md`
- **Development Roadmap:** `.docs/DEVELOPMENT_ROADMAP.md`

---

**End of Documentation**
