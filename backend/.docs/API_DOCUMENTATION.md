# TaskFlow Backend - GraphQL API Documentation

## Overview

TaskFlow backend provides a GraphQL API for managing household tasks with automated distribution, gamification, and rotation systems. This document describes all available queries, mutations, and types.

**Base URL**: `http://localhost:3000/graphql`  
**Authentication**: JWT Bearer token in `Authorization` header

---

## Table of Contents

1. [Authentication](#authentication)
2. [User Management](#user-management)
3. [Group Management](#group-management)
4. [Task Management](#task-management)
5. [Reward System](#reward-system)
6. [Notifications](#notifications)
7. [Audit Logs](#audit-logs)
8. [Health Checks](#health-checks)
9. [Error Handling](#error-handling)
10. [Rate Limiting](#rate-limiting)

---

## Authentication

### Register

Create a new user account.

```graphql
mutation Register {
  register(input: {
    email: "user@example.com"
    username: "johndoe"
    passwordHash: "SecureP@ssw0rd"
  }) {
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

**Input**:
- `email` (String, required): Valid email address
- `username` (String, required): Unique username (3-30 chars)
- `passwordHash` (String, required): Password (min 8 chars, must include uppercase, lowercase, number, special char)

**Rate Limit**: 5 requests/minute

---

### Login

Authenticate existing user.

```graphql
mutation Login {
  login(input: {
    email: "user@example.com"
    passwordHash: "SecureP@ssw0rd"
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

**Input**:
- `email` (String, required): User email
- `passwordHash` (String, required): User password

**Rate Limit**: 5 requests/minute

**Errors**:
- `UNAUTHORIZED`: Invalid credentials
- `NOT_FOUND`: User does not exist

---

### Refresh Token

Obtain new access token using refresh token.

```graphql
mutation RefreshToken {
  refreshToken(refreshToken: "your-refresh-token-here") {
    accessToken
    refreshToken
  }
}
```

**Token Rotation**: Each refresh generates a new refresh token and invalidates the old one (security best practice).

**Rate Limit**: 5 requests/minute

---

### Logout

Invalidate current refresh token.

```graphql
mutation Logout {
  logout(refreshToken: "your-refresh-token-here")
}
```

**Rate Limit**: 5 requests/minute

---

### Logout All Devices

Invalidate all refresh tokens for the user.

```graphql
mutation LogoutAll {
  logoutAll
}
```

**Requires**: JWT authentication

---

## User Management

### Get Current User

Retrieve authenticated user profile.

```graphql
query Me {
  me {
    id
    email
    username
    isAway
    awayUntil
    createdAt
  }
}
```

**Requires**: JWT authentication

---

### Update User Profile

Change user password.

```graphql
mutation ChangePassword {
  changePassword(input: {
    oldPassword: "OldP@ssw0rd"
    newPassword: "NewP@ssw0rd"
  }) {
    id
    email
  }
}
```

**Requires**: JWT authentication

**Errors**:
- `UNAUTHORIZED`: Incorrect old password
- `BAD_REQUEST`: New password doesn't meet requirements

---

### Get User Statistics

Retrieve user's task completion statistics and point balance.

```graphql
query UserStatistics {
  getUserStatistics(userId: "user-id", groupId: "group-id") {
    userId
    groupId
    currentPoints
    pointsEarned
    pointsSpent
    pointsReserved
    tasksCompleted
    tasksAssigned
    completionRate
    onTimePercentage
    upForGrabsCount
    leaderboardPosition
  }
}
```

**Parameters**:
- `userId` (ID, required): User ID
- `groupId` (ID, optional): Filter by specific group (null for all groups)

**Requires**: JWT authentication

**Caching**: Results cached for 5 minutes

---

## Group Management

### Create Group

Create a new task group (creator becomes admin).

```graphql
mutation CreateGroup {
  createGroup(input: {
    name: "Family Chores"
    description: "Our household task rotation"
    rotationType: ROUND_ROBIN
    requiresApproval: true
    gamificationEnabled: true
  }) {
    id
    name
    description
    rotationType
    requiresApproval
    gamificationEnabled
    inviteToken
    createdAt
    members {
      userId
      role
      joinedAt
    }
  }
}
```

**Input**:
- `name` (String, required): Group name
- `description` (String, optional): Group description
- `rotationType` (RotationType, optional): Task distribution algorithm
  - `ROUND_ROBIN` (default): Cyclical assignment
  - `WEIGHTED_RANDOM`: Random with inverse task count weights
  - `LOAD_BALANCING`: Balance accumulated task weight
  - `DISABLED`: Manual assignment or Up-for-Grabs
- `requiresApproval` (Boolean, default: false): Require admin approval for task completion
- `gamificationEnabled` (Boolean, default: true): Enable point system

**Requires**: JWT authentication

---

### Get Group

Retrieve group details (members only).

```graphql
query GetGroup {
  getGroup(id: "group-id") {
    id
    name
    description
    rotationType
    requiresApproval
    gamificationEnabled
    inviteToken
    createdAt
    members {
      userId
      role
      user {
        id
        username
        email
      }
      joinedAt
    }
  }
}
```

**Requires**: JWT authentication + group membership

---

### List User Groups

Get all groups the user is a member of.

```graphql
query MyGroups {
  getUserGroups {
    id
    name
    description
    memberCount
    role  # User's role in this group
    createdAt
  }
}
```

**Requires**: JWT authentication

---

### Update Group Settings

Modify group configuration (admin only).

```graphql
mutation UpdateGroup {
  updateGroup(input: {
    groupId: "group-id"
    name: "Updated Name"
    rotationType: LOAD_BALANCING
    requiresApproval: false
  }) {
    id
    name
    rotationType
    requiresApproval
  }
}
```

**Requires**: JWT authentication + group admin role

---

### Delete Group

Permanently delete group and all associated data (admin only).

```graphql
mutation DeleteGroup {
  deleteGroup(id: "group-id")
}
```

**Cascade Deletes**:
- All tasks
- All task completion history
- All rewards and reward transactions
- All notifications
- All audit logs
- All group memberships

**Requires**: JWT authentication + group admin role

---

### Join Group

Join a group using invitation token.

```graphql
mutation JoinGroup {
  joinGroup(inviteToken: "abc123def456") {
    id
    name
    members {
      userId
      role
    }
  }
}
```

**Requires**: JWT authentication

**Errors**:
- `NOT_FOUND`: Invalid invite token
- `BAD_REQUEST`: Already a member

---

### Leave Group

Leave a group (participants only, admins must transfer ownership first).

```graphql
mutation LeaveGroup {
  leaveGroup(groupId: "group-id")
}
```

**Requires**: JWT authentication + group membership (non-admin)

---

### Remove Member

Remove a user from the group (admin only).

```graphql
mutation RemoveMember {
  removeMember(input: {
    groupId: "group-id"
    userId: "user-id"
  })
}
```

**Requires**: JWT authentication + group admin role

---

### Update Member Role

Change user's role in the group (admin only).

```graphql
mutation UpdateMemberRole {
  updateMemberRole(input: {
    groupId: "group-id"
    userId: "user-id"
    role: ADMIN
  }) {
    userId
    role
    updatedAt
  }
}
```

**Roles**:
- `ADMIN`: Full control (create/edit/delete tasks, approve completions, manage members)
- `MEMBER`: Limited control (complete assigned tasks, claim Up-for-Grabs)

**Requires**: JWT authentication + group admin role

**Audit**: Logged to audit trail

---

### Regenerate Invite Token

Generate new invitation token (admin only).

```graphql
mutation RegenerateInvite {
  regenerateInviteToken(groupId: "group-id") {
    inviteToken
  }
}
```

**Requires**: JWT authentication + group admin role

---

## Task Management

### Create Task

Create a new task with optional assignee.

```graphql
mutation CreateTask {
  createTask(input: {
    groupId: "group-id"
    title: "Wash dishes"
    description: "Clean all dishes in the sink"
    priority: HIGH
    deadline: "2025-12-25"
    points: 150
    assigneeId: "user-id"  # Optional - omit for rotation or Up-for-Grabs
    requiresApproval: true
  }) {
    id
    title
    description
    priority
    deadline
    points
    status
    assigneeId
    creatorId
    wasClaimedFromPool
    createdAt
  }
}
```

**Input**:
- `groupId` (ID, required): Group ID
- `title` (String, required): Task title
- `description` (String, optional): Detailed description
- `priority` (TaskPriority, default: MEDIUM): Task priority
  - `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`
- `deadline` (String, optional): ISO date string
- `points` (Int, default: 100): Base points for completion
- `assigneeId` (ID, optional): 
  - If provided: assign to specific user
  - If omitted: use group rotation algorithm or create Up-for-Grabs
- `requiresApproval` (Boolean, optional): Override group default

**Rotation Behavior**:
- `ROUND_ROBIN`: Assigns to next member in rotation
- `WEIGHTED_RANDOM`: Assigns based on task count weights
- `LOAD_BALANCING`: Assigns to member with lowest accumulated weight
- `DISABLED`: Creates unassigned task (Up-for-Grabs)

**Requires**: JWT authentication + group membership (admin to create group tasks)

---

### Get Task

Retrieve task details.

```graphql
query GetTask {
  getTask(id: "task-id") {
    id
    title
    description
    priority
    deadline
    points
    status
    requiresApproval
    wasClaimedFromPool
    rejectionReason
    assignee {
      id
      username
    }
    creator {
      id
      username
    }
    createdAt
    completedAt
  }
}
```

**Requires**: JWT authentication + group membership

---

### List Group Tasks

Get all tasks in a group with optional filtering.

```graphql
query GroupTasks {
  getGroupTasks(groupId: "group-id", filters: {
    status: PENDING
    assigneeId: "user-id"
    priority: HIGH
  }) {
    id
    title
    status
    priority
    deadline
    points
    assignee {
      username
    }
  }
}
```

**Filters**:
- `status` (TaskStatus, optional): `PENDING`, `IN_PROGRESS`, `AWAITING_APPROVAL`, `COMPLETED`, `OVERDUE`
- `assigneeId` (ID, optional): Filter by assignee
- `priority` (TaskPriority, optional): Filter by priority

**Requires**: JWT authentication + group membership

---

### List User Tasks

Get all tasks assigned to a user.

```graphql
query MyTasks {
  getUserTasks(userId: "user-id", filters: {
    status: IN_PROGRESS
  }) {
    id
    title
    status
    deadline
    points
    group {
      name
    }
  }
}
```

**Requires**: JWT authentication

---

### Update Task

Modify task details (admin or creator only).

```graphql
mutation UpdateTask {
  updateTask(input: {
    taskId: "task-id"
    title: "Updated title"
    priority: CRITICAL
    points: 200
  }) {
    id
    title
    priority
    points
    updatedAt
  }
}
```

**Requires**: JWT authentication + (group admin OR task creator)

---

### Delete Task

Remove a task (admin or creator only).

```graphql
mutation DeleteTask {
  deleteTask(id: "task-id")
}
```

**Requires**: JWT authentication + (group admin OR task creator)

---

### Complete Task

Mark a task as completed (assignee only).

```graphql
mutation CompleteTask {
  completeTask(input: {
    taskId: "task-id"
  }) {
    id
    status  # COMPLETED or AWAITING_APPROVAL
    completedAt
  }
}
```

**Behavior**:
- If `requiresApproval = false`: Moves to `COMPLETED`, awards points immediately
- If `requiresApproval = true`: Moves to `AWAITING_APPROVAL`, awaits admin approval

**Point Calculation** (for auto-complete):
- On-time: `points × 1.0`
- Late: `points × 0.5`
- Up-for-Grabs: `points × 1.5`

**Requires**: JWT authentication + task assignee

**Notifications**: Sent to group admins (if approval required)

---

### Approve/Reject Task

Approve or reject a task completion (admin only).

```graphql
mutation ApproveTask {
  approveTask(input: {
    taskId: "task-id"
    approved: true
    rejectionReason: "Incomplete work"  # Required if approved = false
  }) {
    id
    status  # COMPLETED or PENDING
    rejectionReason
    completedAt
  }
}
```

**Point Calculation** (on approval):
- On-time: `points × 1.0`
- Late: `points × 0.5`
- Up-for-Grabs: `points × 1.5`
- Rejected: `points × 0.0`

**Behavior**:
- `approved = true`: Moves to `COMPLETED`, awards calculated points
- `approved = false`: Moves to `PENDING`, requires `rejectionReason`

**Requires**: JWT authentication + group admin role

**Audit**: Logged to audit trail with reason

**Notifications**: Sent to assignee (approval/rejection + point award)

---

### Claim Task (Up-for-Grabs)

Claim an unassigned task for bonus points.

```graphql
mutation ClaimTask {
  claimTask(input: {
    taskId: "task-id"
  }) {
    id
    assigneeId  # Now assigned to claiming user
    wasClaimedFromPool
  }
}
```

**Requirements**:
- Task must have `assigneeId = null`
- User must be group member
- Task must not be `COMPLETED` or `OVERDUE`

**Bonus**: Claiming user receives 1.5× points on completion

**Requires**: JWT authentication + group membership

---

## Reward System

### Create Reward

Create a reward item (admin only).

```graphql
mutation CreateReward {
  createReward(input: {
    groupId: "group-id"
    name: "Movie Night"
    description: "Choose a movie for family night"
    pointCost: 500
  }) {
    id
    name
    description
    pointCost
    createdAt
  }
}
```

**Requires**: JWT authentication + group admin role

---

### List Group Rewards

Get all rewards in a group.

```graphql
query GroupRewards {
  getGroupRewards(groupId: "group-id") {
    id
    name
    description
    pointCost
  }
}
```

**Requires**: JWT authentication + group membership

---

### Request Reward

Request a reward using points.

```graphql
mutation RequestReward {
  requestReward(input: {
    rewardId: "reward-id"
  }) {
    id
    status  # RESERVED
    pointsSpent
    requestedAt
    reward {
      name
      pointCost
    }
  }
}
```

**Process**:
1. Checks user has sufficient available points
2. Creates `PointTransaction` with type `RESERVED`
3. Creates `RewardTransaction` with status `RESERVED`
4. Awaits admin approval

**Errors**:
- `BAD_REQUEST`: Insufficient points

**Requires**: JWT authentication + group membership

**Notifications**: Sent to group admins

---

### Approve/Reject Reward Request

Approve or deny a reward redemption (admin only).

```graphql
mutation ApproveRewardRequest {
  approveRewardRequest(input: {
    requestId: "request-id"
    approved: true
    rejectionReason: "Out of stock"  # Required if approved = false
  }) {
    id
    status  # APPROVED or REJECTED
    approvedAt
    approvedBy {
      username
    }
  }
}
```

**Behavior**:
- `approved = true`: 
  - Updates status to `APPROVED`
  - Converts `RESERVED` → `SPENT` in PointTransaction
- `approved = false`:
  - Updates status to `REJECTED`
  - Creates `REFUNDED` PointTransaction (returns points)

**Requires**: JWT authentication + group admin role

**Audit**: Logged to audit trail

**Notifications**: Sent to requester

---

### Get User Reward Requests

List user's reward redemption history.

```graphql
query MyRewardRequests {
  getUserRewardRequests(userId: "user-id", groupId: "group-id") {
    id
    status
    pointsSpent
    requestedAt
    approvedAt
    rejectionReason
    reward {
      name
      pointCost
    }
  }
}
```

**Requires**: JWT authentication

---

### Get Group Leaderboard

Retrieve point rankings for a group.

```graphql
query Leaderboard {
  getGroupLeaderboard(groupId: "group-id") {
    userId
    user {
      username
    }
    pointsEarned
    rank
  }
}
```

**Sorting**: By `pointsEarned` (descending)

**Requires**: JWT authentication + group membership

---

## Notifications

### List My Notifications

Get user's notifications with filters.

```graphql
query MyNotifications {
  myNotifications(filters: {
    isRead: false
    type: TASK_ASSIGNED
    groupId: "group-id"
  }) {
    id
    title
    message
    type
    isRead
    createdAt
    task {
      id
      title
    }
    reward {
      id
      name
    }
  }
}
```

**Filters**:
- `isRead` (Boolean, optional): Filter by read status
- `type` (NotificationType, optional): Filter by notification type
- `groupId` (ID, optional): Filter by group

**Notification Types**:
- `TASK_ASSIGNED`: Task assigned to you
- `TASK_SUBMITTED_FOR_REVIEW`: Task awaits approval
- `TASK_APPROVED`: Task completion approved
- `TASK_REJECTED`: Task completion rejected
- `POINT_AWARDED`: Points earned
- `REWARD_REQUESTED`: Reward redemption requested
- `REWARD_APPROVED`: Reward request approved
- `REWARD_REJECTED`: Reward request rejected
- `DEADLINE_REMINDER`: Task deadline approaching
- `SYSTEM`: System notifications

**Requires**: JWT authentication

---

### Mark Notifications as Read

Mark specific notifications as read.

```graphql
mutation MarkRead {
  markNotificationsRead(notificationIds: ["id1", "id2", "id3"])
}
```

**Requires**: JWT authentication

---

### Mark All Notifications as Read

Mark all user notifications as read.

```graphql
mutation MarkAllRead {
  markAllNotificationsRead
}
```

**Requires**: JWT authentication

---

### Notification Preferences

Get or update notification preferences.

```graphql
query MyPreferences {
  myNotificationPreferences {
    enablePush
    quietHoursStart  # "22:00"
    quietHoursEnd    # "08:00"
    mutedTypes       # [SYSTEM, DEADLINE_REMINDER]
    enableBatching
  }
}

mutation UpdatePreferences {
  upsertNotificationPreference(input: {
    enablePush: true
    quietHoursStart: "22:00"
    quietHoursEnd: "08:00"
    mutedTypes: [SYSTEM]
    enableBatching: false
  }) {
    enablePush
    quietHoursStart
    quietHoursEnd
  }
}
```

**Requires**: JWT authentication

---

### Register Device Token

Register a device for push notifications.

```graphql
mutation RegisterDevice {
  registerDeviceToken(input: {
    token: "fcm-device-token-here"
    provider: FCM
    platform: ANDROID
  }) {
    id
    token
    provider
    platform
  }
}
```

**Providers**: `FCM` (Firebase Cloud Messaging), `APNS` (future)

**Platforms**: `ANDROID`, `IOS`, `WEB`

**Requires**: JWT authentication

---

## Audit Logs

### Get Audit Logs

Retrieve audit trail with filters (admin or own actions).

```graphql
query AuditLogs {
  getAuditLogs(filters: {
    userId: "user-id"
    groupId: "group-id"
    action: TASK_APPROVAL
    startDate: "2025-01-01"
    endDate: "2025-12-31"
  }) {
    id
    userId
    groupId
    action
    entityType
    entityId
    changes
    metadata
    createdAt
    user {
      username
    }
  }
}
```

**Filters**:
- `userId` (ID, optional): Filter by user
- `groupId` (ID, optional): Filter by group
- `action` (AuditAction, optional): Filter by action type
- `startDate` (String, optional): ISO date
- `endDate` (String, optional): ISO date
- `take` (Int, default: 50): Pagination limit
- `skip` (Int, default: 0): Pagination offset

**Audit Actions**:
- `TASK_CREATED`, `TASK_UPDATED`, `TASK_DELETED`, `TASK_COMPLETED`, `TASK_APPROVAL`
- `ROLE_CHANGED`, `MEMBER_REMOVED`, `GROUP_UPDATED`, `GROUP_DELETED`
- `REWARD_CREATED`, `REWARD_UPDATED`, `REWARD_DELETED`, `REWARD_REQUESTED`, `REWARD_APPROVAL`
- `POINT_TRANSACTION`

**Requires**: JWT authentication + (group admin OR own userId)

---

### Get Task Audit Log

Retrieve complete history of a specific task.

```graphql
query TaskHistory {
  getTaskAuditLog(taskId: "task-id") {
    id
    action
    changes
    createdAt
    user {
      username
    }
  }
}
```

**Requires**: JWT authentication + group membership

---

## Health Checks

### Liveness Probe

Check if application is running (Kubernetes health check).

```
GET /health/live
```

**Response**: `200 OK` if memory heap usage < 90%

**No authentication required**

---

### Readiness Probe

Check if application is ready to accept traffic.

```
GET /health/ready
```

**Checks**:
- Database connection
- Memory heap usage < 90%
- Disk usage < 90%

**Response**: `200 OK` if all checks pass

**No authentication required**

---

### Combined Health Check

Get detailed health status.

```
GET /health
```

**Response**:
```json
{
  "status": "ok",
  "info": {
    "database": { "status": "up" },
    "memory_heap": { "status": "up" },
    "disk": { "status": "up" }
  }
}
```

**No authentication required**

---

## Error Handling

### Error Response Format

All errors follow standard GraphQL error format:

```json
{
  "errors": [
    {
      "message": "Forbidden resource",
      "extensions": {
        "code": "FORBIDDEN",
        "statusCode": 403
      }
    }
  ],
  "data": null
}
```

### Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHENTICATED` | 401 | Missing or invalid JWT token |
| `UNAUTHORIZED` | 401 | Invalid credentials |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource does not exist |
| `BAD_REQUEST` | 400 | Invalid input or state |
| `TOO_MANY_REQUESTS` | 429 | Rate limit exceeded |
| `INTERNAL_SERVER_ERROR` | 500 | Server error (logged) |

### Validation Errors

Input validation failures return `BAD_REQUEST` with detailed messages:

```json
{
  "errors": [
    {
      "message": "Validation failed",
      "extensions": {
        "code": "BAD_REQUEST",
        "validationErrors": [
          {
            "field": "email",
            "message": "email must be a valid email"
          },
          {
            "field": "passwordHash",
            "message": "password is too weak"
          }
        ]
      }
    }
  ]
}
```

---

## Rate Limiting

### Limits by Endpoint Type

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Authentication (register, login, refresh, logout) | 5 requests | 1 minute |
| General API (queries, mutations) | 100 requests | 1 minute |

### Rate Limit Headers

Responses include rate limit information:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1699564800
```

### Rate Limit Exceeded Response

```json
{
  "errors": [
    {
      "message": "Rate limit exceeded. Try again in 45 seconds.",
      "extensions": {
        "code": "TOO_MANY_REQUESTS",
        "statusCode": 429,
        "retryAfter": 45
      }
    }
  ]
}
```

---

## GraphQL Playground

**Development Only**: GraphQL Playground is available at `http://localhost:3000/graphql` in development mode.

**Production**: Playground and introspection are disabled in production for security.

---

## Best Practices

1. **Always use HTTPS** in production
2. **Store JWT tokens securely** (HttpOnly cookies recommended for web)
3. **Refresh tokens before expiration** (access token: 15 min, refresh: 7 days)
4. **Handle rate limits gracefully** (exponential backoff)
5. **Validate input client-side** before sending to API
6. **Use fragments** for reusable query parts
7. **Request only needed fields** to minimize response size
8. **Monitor audit logs** for security incidents
9. **Use batch queries** where possible (GraphQL supports multiple operations)
10. **Implement retry logic** for network failures (but not for validation errors)

---

## Example: Complete Task Workflow

```graphql
# 1. Register and login
mutation {
  register(input: {
    email: "john@example.com"
    username: "john"
    passwordHash: "SecureP@ss123"
  }) {
    accessToken
    refreshToken
  }
}

# 2. Create a group
mutation {
  createGroup(input: {
    name: "Family Chores"
    rotationType: ROUND_ROBIN
    requiresApproval: true
  }) {
    id
    inviteToken
  }
}

# 3. Invite member (share inviteToken with them)
mutation {
  joinGroup(inviteToken: "abc123") {
    id
    name
  }
}

# 4. Create a task (admin)
mutation {
  createTask(input: {
    groupId: "group-id"
    title: "Wash dishes"
    priority: HIGH
    points: 150
    deadline: "2025-12-25"
  }) {
    id
    assignee {
      username
    }
  }
}

# 5. Complete task (assignee)
mutation {
  completeTask(input: {
    taskId: "task-id"
  }) {
    status  # AWAITING_APPROVAL
  }
}

# 6. Approve task (admin)
mutation {
  approveTask(input: {
    taskId: "task-id"
    approved: true
  }) {
    status  # COMPLETED
  }
}

# 7. Check points and leaderboard
query {
  getUserStatistics(userId: "user-id", groupId: "group-id") {
    currentPoints
    pointsEarned
    tasksCompleted
    leaderboardPosition
  }
  
  getGroupLeaderboard(groupId: "group-id") {
    user {
      username
    }
    pointsEarned
    rank
  }
}

# 8. Redeem reward
mutation {
  requestReward(input: {
    rewardId: "reward-id"
  }) {
    status  # RESERVED
  }
}
```

---

**Version**: 1.0.0  
**Last Updated**: November 10, 2025  
**Contact**: TaskFlow Development Team
