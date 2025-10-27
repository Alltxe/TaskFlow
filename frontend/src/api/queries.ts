// GraphQL queries and mutations for the TaskFlow application
// Auto-generated types will be created by GraphQL Code Generator

import { gql } from 'urql'

// ============================================
// AUTH MUTATIONS & QUERIES
// ============================================

export const LOGIN_MUTATION = gql`
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
        createdAt
        updatedAt
      }
    }
  }
`

export const REGISTER_MUTATION = gql`
  mutation Register($input: RegisterInput!) {
    register(input: $input) {
      accessToken
      refreshToken
      user {
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
  }
`

export const LOGOUT_MUTATION = gql`
  mutation Logout($refreshToken: String!) {
    logout(refreshToken: $refreshToken)
  }
`

export const REFRESH_TOKEN_MUTATION = gql`
  mutation RefreshToken($input: RefreshTokenInput!) {
    refreshToken(input: $input) {
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
`

export const ME_QUERY = gql`
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
`

export const CHANGE_PASSWORD_MUTATION = gql`
  mutation ChangePassword($input: ChangePasswordInput!) {
    changePassword(input: $input)
  }
`

// ============================================
// GROUP QUERIES & MUTATIONS
// ============================================

export const GET_USER_GROUPS_QUERY = gql`
  query GetUserGroups {
    getUserGroups {
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
`

export const GET_GROUP_QUERY = gql`
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
`

export const GET_GROUP_MEMBERS_QUERY = gql`
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
`

export const CREATE_GROUP_MUTATION = gql`
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
      updatedAt
      createdById
    }
  }
`

export const UPDATE_GROUP_MUTATION = gql`
  mutation UpdateGroup($groupId: String!, $input: UpdateGroupInput!) {
    updateGroup(groupId: $groupId, input: $input) {
      id
      name
      description
      requiresApproval
      rotationType
      gamificationEnabled
      updatedAt
    }
  }
`

export const DELETE_GROUP_MUTATION = gql`
  mutation DeleteGroup($groupId: String!) {
    deleteGroup(groupId: $groupId)
  }
`

export const JOIN_GROUP_MUTATION = gql`
  mutation JoinGroup($input: JoinGroupInput!) {
    joinGroup(input: $input) {
      id
      name
      description
    }
  }
`

export const LEAVE_GROUP_MUTATION = gql`
  mutation LeaveGroup($groupId: String!) {
    leaveGroup(groupId: $groupId)
  }
`

export const REMOVE_MEMBER_MUTATION = gql`
  mutation RemoveMember($groupId: String!, $userId: String!) {
    removeMember(groupId: $groupId, userId: $userId)
  }
`

export const UPDATE_MEMBER_ROLE_MUTATION = gql`
  mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
    updateMemberRole(groupId: $groupId, input: $input) {
      id
      userId
      role
      roleChangedAt
    }
  }
`

export const REGENERATE_INVITE_TOKEN_MUTATION = gql`
  mutation RegenerateInviteToken($groupId: String!) {
    regenerateInviteToken(groupId: $groupId)
  }
`

// ============================================
// TASK QUERIES & MUTATIONS
// ============================================

export const GET_GROUP_TASKS_QUERY = gql`
  query GetGroupTasks($groupId: String!, $status: String) {
    getGroupTasks(groupId: $groupId, status: $status) {
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
      createdAt
      completedAt
      groupId
      createdById
      assigneeId
      approvedById
      parentTaskId
      assignee {
        id
        username
        avatarUrl
      }
      createdBy {
        id
        username
        avatarUrl
      }
    }
  }
`

export const GET_USER_TASKS_QUERY = gql`
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
      isRecurring
      recurrenceRule
      groupId
      createdAt
      completedAt
      assigneeId
      createdBy {
        id
        username
      }
    }
  }
`

export const GET_TASK_QUERY = gql`
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
      isRecurring
      recurrenceRule
      rotationType
      weight
      createdAt
      completedAt
      groupId
      createdById
      assigneeId
      approvedById
      parentTaskId
      assignee {
        id
        username
        avatarUrl
      }
      createdBy {
        id
        username
        avatarUrl
      }
    }
  }
`

export const CREATE_TASK_MUTATION = gql`
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
      groupId
      createdAt
      assigneeId
    }
  }
`

export const UPDATE_TASK_MUTATION = gql`
  mutation UpdateTask($taskId: String!, $input: UpdateTaskInput!) {
    updateTask(taskId: $taskId, input: $input) {
      id
      title
      description
      deadline
      priority
      points
      requiresApproval
      assigneeId
    }
  }
`

export const DELETE_TASK_MUTATION = gql`
  mutation DeleteTask($taskId: String!) {
    deleteTask(taskId: $taskId)
  }
`

export const COMPLETE_TASK_MUTATION = gql`
  mutation CompleteTask($input: CompleteTaskInput!) {
    completeTask(input: $input) {
      id
      status
      completedAt
    }
  }
`

export const APPROVE_TASK_MUTATION = gql`
  mutation ApproveTask($input: ApproveTaskInput!) {
    approveTask(input: $input) {
      id
      status
      approvedById
    }
  }
`

// ============================================
// USER STATISTICS QUERIES
// ============================================

export const MY_STATISTICS_QUERY = gql`
  query MyStatistics($groupId: String) {
    myStatistics(groupId: $groupId) {
      totalPoints
      pointsEarned
      pointsSpent
      tasksCompleted
      tasksAssigned
      completionRate
      tasksCompletedOnTime
      onTimePercentage
      leaderboardPosition
      groupId
    }
  }
`

export const USER_STATISTICS_QUERY = gql`
  query UserStatistics($userId: String!, $groupId: String) {
    userStatistics(userId: $userId, groupId: $groupId) {
      totalPoints
      pointsEarned
      pointsSpent
      tasksCompleted
      tasksAssigned
      completionRate
      tasksCompletedOnTime
      onTimePercentage
      leaderboardPosition
      groupId
    }
  }
`

