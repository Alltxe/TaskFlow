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
      wasClaimedFromPool
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
      wasClaimedFromPool
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
      wasClaimedFromPool
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

export const CLAIM_TASK_MUTATION = gql`
  mutation ClaimTask($input: ClaimTaskInput!) {
    claimTask(input: $input) {
      id
      status
      assigneeId
      wasClaimedFromPool
      assignee {
        id
        username
        avatarUrl
      }
    }
  }
`

// ============================================
// USER STATISTICS QUERIES
// ============================================

export const MY_STATISTICS_QUERY = gql`
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
`

export const USER_STATISTICS_QUERY = gql`
  query UserStatistics($userId: String!, $groupId: String) {
    userStatistics(userId: $userId, groupId: $groupId) {
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
`

// ============================================
// USER PROFILE MUTATIONS
// ============================================

export const UPDATE_USER_MUTATION = gql`
  mutation UpdateUser($input: UpdateUserInput!) {
    updateUser(input: $input) {
      id
      username
      avatarUrl
      updatedAt
    }
  }
`

export const SET_AWAY_STATUS_MUTATION = gql`
  mutation SetAwayStatus($input: SetAwayStatusInput!) {
    setUserAwayStatus(input: $input) {
      id
      isAway
      awayUntil
      updatedAt
    }
  }
`

// ============================================
// ROTATION QUERIES
// ============================================

export const GET_ROTATION_SCHEDULE_QUERY = gql`
  query GetRotationSchedule($groupId: String!) {
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
`

export const GET_ROTATION_HISTORY_QUERY = gql`
  query GetRotationHistory($groupId: String!, $limit: Int, $offset: Int) {
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
`

export const GET_ROTATION_PATTERN_QUERY = gql`
  query GetRotationPattern($groupId: String!) {
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
`

// ============================================
// GAMIFICATION QUERIES & MUTATIONS
// ============================================

export const GET_GROUP_REWARDS_QUERY = gql`
  query GetGroupRewards($groupId: String!) {
    getGroupRewards(groupId: $groupId) {
      id
      name
      description
      cost
      isActive
      imageUrl
      createdAt
      groupId
      createdById
    }
  }
`

export const GET_MY_REWARD_REQUESTS_QUERY = gql`
  query GetMyRewardRequests($groupId: String) {
    getMyRewardRequests(groupId: $groupId) {
      id
      userId
      rewardId
      status
      pointsSpent
      requestedAt
      approvedAt
      rejectedAt
      rejectionReason
      approvedById
    }
  }
`

export const GET_GROUP_REWARD_REQUESTS_QUERY = gql`
  query GetGroupRewardRequests($groupId: String!) {
    getGroupRewardRequests(groupId: $groupId) {
      id
      userId
      rewardId
      status
      pointsSpent
      requestedAt
      approvedAt
      rejectedAt
      rejectionReason
      approvedById
    }
  }
`

export const CREATE_REWARD_MUTATION = gql`
  mutation CreateReward($input: CreateRewardInput!) {
    createReward(input: $input) {
      id
      name
      description
      cost
      isActive
      imageUrl
      createdAt
      groupId
      createdById
    }
  }
`

export const UPDATE_REWARD_MUTATION = gql`
  mutation UpdateReward($input: UpdateRewardInput!) {
    updateReward(input: $input) {
      id
      name
      description
      cost
      isActive
      imageUrl
      groupId
    }
  }
`

export const DELETE_REWARD_MUTATION = gql`
  mutation DeleteReward($rewardId: String!, $groupId: String!) {
    deleteReward(rewardId: $rewardId, groupId: $groupId)
  }
`

export const REQUEST_REWARD_MUTATION = gql`
  mutation RequestReward($input: RequestRewardInput!) {
    requestReward(input: $input) {
      id
      userId
      rewardId
      status
      pointsSpent
      requestedAt
    }
  }
`

export const APPROVE_REWARD_REQUEST_MUTATION = gql`
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
`

export const GET_POINT_BALANCE_QUERY = gql`
  query GetPointBalance($groupId: String) {
    getPointBalance(groupId: $groupId) {
      totalEarned
      totalSpentApproved
      totalReservedPending
      currentBalance
      availableBalance
    }
  }
`

export const GET_POINT_TRANSACTION_HISTORY_QUERY = gql`
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
`

export const GET_GROUP_LEADERBOARD_QUERY = gql`
  query GetGroupLeaderboard($groupId: String!) {
    getGroupLeaderboard(groupId: $groupId) {
      user {
        id
        username
        avatarUrl
        email
      }
      pointsEarned
      rank
    }
  }
`
