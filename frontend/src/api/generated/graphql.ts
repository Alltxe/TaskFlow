import gql from 'graphql-tag';
import * as Urql from 'urql';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
export type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  DateTime: { input: any; output: any; }
  JSON: { input: any; output: any; }
};

export type ApproveRewardRequestInput = {
  approved: Scalars['Boolean']['input'];
  reason?: InputMaybe<Scalars['String']['input']>;
  requestId: Scalars['ID']['input'];
};

export type ApproveTaskInput = {
  approved: Scalars['Boolean']['input'];
  rejectionReason?: InputMaybe<Scalars['String']['input']>;
  taskId: Scalars['String']['input'];
};

export type AuditLogListType = {
  __typename?: 'AuditLogListType';
  limit: Scalars['Int']['output'];
  logs: Array<AuditLogType>;
  offset: Scalars['Int']['output'];
  total: Scalars['Int']['output'];
};

export type AuditLogType = {
  __typename?: 'AuditLogType';
  action: Scalars['String']['output'];
  entityId?: Maybe<Scalars['String']['output']>;
  entityType: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  ipAddress?: Maybe<Scalars['String']['output']>;
  newValues?: Maybe<Scalars['JSON']['output']>;
  oldValues?: Maybe<Scalars['JSON']['output']>;
  performedAt: Scalars['DateTime']['output'];
  performedBy?: Maybe<AuditLogUserType>;
  user?: Maybe<AuditLogUserType>;
  userId?: Maybe<Scalars['String']['output']>;
};

export type AuditLogUserType = {
  __typename?: 'AuditLogUserType';
  email: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  username: Scalars['String']['output'];
};

export type AuthResponseType = {
  __typename?: 'AuthResponseType';
  accessToken: Scalars['String']['output'];
  refreshToken: Scalars['String']['output'];
  user: UserType;
};

export type ChangePasswordInput = {
  newPassword: Scalars['String']['input'];
  oldPassword: Scalars['String']['input'];
};

export type ClaimTaskInput = {
  taskId: Scalars['String']['input'];
};

export type CompleteTaskInput = {
  taskId: Scalars['String']['input'];
};

export type CreateGroupInput = {
  description?: InputMaybe<Scalars['String']['input']>;
  gamificationEnabled?: InputMaybe<Scalars['Boolean']['input']>;
  name: Scalars['String']['input'];
  requiresApproval?: InputMaybe<Scalars['Boolean']['input']>;
  rotationType?: InputMaybe<Scalars['String']['input']>;
};

export type CreateRewardInput = {
  cost: Scalars['Int']['input'];
  description?: InputMaybe<Scalars['String']['input']>;
  groupId: Scalars['ID']['input'];
  imageUrl?: InputMaybe<Scalars['String']['input']>;
  isActive?: InputMaybe<Scalars['Boolean']['input']>;
  name: Scalars['String']['input'];
};

export type CreateTaskInput = {
  assigneeId?: InputMaybe<Scalars['String']['input']>;
  deadline: Scalars['String']['input'];
  description?: InputMaybe<Scalars['String']['input']>;
  groupId: Scalars['String']['input'];
  isRecurring?: InputMaybe<Scalars['Boolean']['input']>;
  points: Scalars['Int']['input'];
  priority: Scalars['String']['input'];
  recurrenceRule?: InputMaybe<Scalars['String']['input']>;
  requiresApproval?: InputMaybe<Scalars['Boolean']['input']>;
  rotationType?: InputMaybe<Scalars['String']['input']>;
  title: Scalars['String']['input'];
  weight?: InputMaybe<Scalars['Int']['input']>;
};

export type DeviceTokenType = {
  __typename?: 'DeviceTokenType';
  createdAt: Scalars['DateTime']['output'];
  id: Scalars['ID']['output'];
  platform?: Maybe<Scalars['String']['output']>;
  provider?: Maybe<Scalars['String']['output']>;
  token: Scalars['String']['output'];
  updatedAt: Scalars['DateTime']['output'];
};

export type GetAuditLogsInput = {
  action?: InputMaybe<Scalars['String']['input']>;
  endDate?: InputMaybe<Scalars['String']['input']>;
  entityType?: InputMaybe<Scalars['String']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  startDate?: InputMaybe<Scalars['String']['input']>;
  userId?: InputMaybe<Scalars['String']['input']>;
};

export type GroupMemberType = {
  __typename?: 'GroupMemberType';
  groupId: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  joinedAt: Scalars['DateTime']['output'];
  role: Scalars['String']['output'];
  roleChangedAt: Scalars['DateTime']['output'];
  user: GroupMemberUserType;
  userId: Scalars['String']['output'];
};

export type GroupMemberUserType = {
  __typename?: 'GroupMemberUserType';
  avatarUrl?: Maybe<Scalars['String']['output']>;
  awayUntil?: Maybe<Scalars['DateTime']['output']>;
  id: Scalars['ID']['output'];
  isAway: Scalars['Boolean']['output'];
  username: Scalars['String']['output'];
};

export type GroupType = {
  __typename?: 'GroupType';
  createdAt: Scalars['DateTime']['output'];
  createdById: Scalars['String']['output'];
  description?: Maybe<Scalars['String']['output']>;
  gamificationEnabled: Scalars['Boolean']['output'];
  id: Scalars['ID']['output'];
  inviteToken?: Maybe<Scalars['String']['output']>;
  name: Scalars['String']['output'];
  requiresApproval: Scalars['Boolean']['output'];
  rotationType: Scalars['String']['output'];
  updatedAt: Scalars['DateTime']['output'];
};

export type JoinGroupInput = {
  inviteToken: Scalars['String']['input'];
};

export type LeaderboardEntryType = {
  __typename?: 'LeaderboardEntryType';
  pointsEarned: Scalars['Int']['output'];
  rank: Scalars['Int']['output'];
  user: UserType;
};

export type ListNotificationsInput = {
  isRead?: InputMaybe<Scalars['Boolean']['input']>;
  limit?: InputMaybe<Scalars['Float']['input']>;
  offset?: InputMaybe<Scalars['Float']['input']>;
  type?: InputMaybe<NotificationTypeEnum>;
};

export type LoginInput = {
  email: Scalars['String']['input'];
  password: Scalars['String']['input'];
};

export type MarkNotificationsReadInput = {
  ids: Array<Scalars['String']['input']>;
};

export type Mutation = {
  __typename?: 'Mutation';
  /** Approve or reject reward request (PRD 3.5.4) - admin only */
  approveRewardRequest: RewardTransactionType;
  approveTask: TaskType;
  /** Сменить пароль текущего пользователя */
  changePassword: Scalars['Boolean']['output'];
  /** Claim an unassigned task from the Up-for-Grabs pool. User receives bonus points (1.5x multiplier). */
  claimTask: TaskType;
  completeTask: TaskType;
  createGroup: GroupType;
  /** Create reward (PRD 3.5.3) - admin only */
  createReward: RewardType;
  createTask: TaskType;
  deleteGroup: Scalars['Boolean']['output'];
  /** Delete reward (PRD 3.5.3) - admin only */
  deleteReward: Scalars['Boolean']['output'];
  deleteTask: Scalars['Boolean']['output'];
  /** Manually generate next task from recurring template (admin only) */
  generateNextRecurringTask: TaskType;
  joinGroup: GroupType;
  leaveGroup: Scalars['Boolean']['output'];
  /** Вход пользователя */
  login: AuthResponseType;
  /** Выход из системы (отзыв refresh token) */
  logout: Scalars['Boolean']['output'];
  /** Выход из всех устройств */
  logoutAll: Scalars['Float']['output'];
  /** Mark all my notifications as read (PRD 3.6.3) */
  markAllNotificationsRead: Scalars['Boolean']['output'];
  /** Mark notifications as read (PRD 3.6.3) */
  markNotificationsRead: Scalars['Boolean']['output'];
  /** Обновить access token с помощью refresh token */
  refreshToken: AuthResponseType;
  regenerateInviteToken: Scalars['String']['output'];
  /** Регистрация нового пользователя */
  register: AuthResponseType;
  /** Register a device token for push notifications */
  registerDeviceToken: DeviceTokenType;
  /** Remove a device token */
  removeDeviceToken: Scalars['Boolean']['output'];
  removeMember: Scalars['Boolean']['output'];
  /** Request reward (PRD 3.5.4) */
  requestReward: RewardTransactionType;
  /** Отправить тестовое push-уведомление на все мои устройства (Phase 8) */
  sendTestPush: Array<PushNotificationResultType>;
  /** Set "Away" status for current user (affects task rotation) */
  setUserAwayStatus: UserType;
  updateGroup: GroupType;
  updateMemberRole: GroupMemberType;
  /** Update reward (PRD 3.5.3) - admin only */
  updateReward: RewardType;
  updateTask: TaskType;
  /** Update current user profile (username, avatarUrl) */
  updateUser: UserType;
  /** Upsert my notification preferences */
  upsertNotificationPreference: NotificationPreferenceType;
};


export type MutationApproveRewardRequestArgs = {
  input: ApproveRewardRequestInput;
};


export type MutationApproveTaskArgs = {
  input: ApproveTaskInput;
};


export type MutationChangePasswordArgs = {
  input: ChangePasswordInput;
};


export type MutationClaimTaskArgs = {
  input: ClaimTaskInput;
};


export type MutationCompleteTaskArgs = {
  input: CompleteTaskInput;
};


export type MutationCreateGroupArgs = {
  input: CreateGroupInput;
};


export type MutationCreateRewardArgs = {
  input: CreateRewardInput;
};


export type MutationCreateTaskArgs = {
  input: CreateTaskInput;
};


export type MutationDeleteGroupArgs = {
  groupId: Scalars['String']['input'];
};


export type MutationDeleteRewardArgs = {
  groupId: Scalars['String']['input'];
  rewardId: Scalars['String']['input'];
};


export type MutationDeleteTaskArgs = {
  taskId: Scalars['String']['input'];
};


export type MutationGenerateNextRecurringTaskArgs = {
  taskId: Scalars['String']['input'];
};


export type MutationJoinGroupArgs = {
  input: JoinGroupInput;
};


export type MutationLeaveGroupArgs = {
  groupId: Scalars['String']['input'];
};


export type MutationLoginArgs = {
  input: LoginInput;
};


export type MutationLogoutArgs = {
  refreshToken: Scalars['String']['input'];
};


export type MutationMarkNotificationsReadArgs = {
  input: MarkNotificationsReadInput;
};


export type MutationRefreshTokenArgs = {
  input: RefreshTokenInput;
};


export type MutationRegenerateInviteTokenArgs = {
  groupId: Scalars['String']['input'];
};


export type MutationRegisterArgs = {
  input: RegisterInput;
};


export type MutationRegisterDeviceTokenArgs = {
  input: RegisterDeviceTokenInput;
};


export type MutationRemoveDeviceTokenArgs = {
  input: RemoveDeviceTokenInput;
};


export type MutationRemoveMemberArgs = {
  groupId: Scalars['String']['input'];
  userId: Scalars['String']['input'];
};


export type MutationRequestRewardArgs = {
  input: RequestRewardInput;
};


export type MutationSendTestPushArgs = {
  input: TestPushInput;
};


export type MutationSetUserAwayStatusArgs = {
  input: SetAwayStatusInput;
};


export type MutationUpdateGroupArgs = {
  groupId: Scalars['String']['input'];
  input: UpdateGroupInput;
};


export type MutationUpdateMemberRoleArgs = {
  groupId: Scalars['String']['input'];
  input: UpdateMemberRoleInput;
};


export type MutationUpdateRewardArgs = {
  input: UpdateRewardInput;
};


export type MutationUpdateTaskArgs = {
  input: UpdateTaskInput;
  taskId: Scalars['String']['input'];
};


export type MutationUpdateUserArgs = {
  input: UpdateUserInput;
};


export type MutationUpsertNotificationPreferenceArgs = {
  input: UpsertNotificationPreferenceInput;
};

export type NotificationListResult = {
  __typename?: 'NotificationListResult';
  items: Array<NotificationType>;
  total: Scalars['Float']['output'];
};

export type NotificationPreferenceType = {
  __typename?: 'NotificationPreferenceType';
  batchingEnabled: Scalars['Boolean']['output'];
  createdAt: Scalars['DateTime']['output'];
  enablePush: Scalars['Boolean']['output'];
  id: Scalars['ID']['output'];
  mutedTypes?: Maybe<Array<Scalars['String']['output']>>;
  quietHoursEnd?: Maybe<Scalars['String']['output']>;
  quietHoursStart?: Maybe<Scalars['String']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

export type NotificationType = {
  __typename?: 'NotificationType';
  createdAt: Scalars['DateTime']['output'];
  id: Scalars['ID']['output'];
  isRead: Scalars['Boolean']['output'];
  message: Scalars['String']['output'];
  relatedEntityId?: Maybe<Scalars['String']['output']>;
  relatedEntityType?: Maybe<Scalars['String']['output']>;
  title: Scalars['String']['output'];
  type: NotificationTypeEnum;
};

export type NotificationTypeEnum =
  | 'INVITATION'
  | 'POINT_AWARDED'
  | 'REWARD_APPROVED'
  | 'REWARD_REJECTED'
  | 'REWARD_REQUESTED'
  | 'SYSTEM'
  | 'TASK_APPROVED'
  | 'TASK_ASSIGNED'
  | 'TASK_COMPLETED'
  | 'TASK_REJECTED';

export type PointBalanceType = {
  __typename?: 'PointBalanceType';
  availableBalance: Scalars['Int']['output'];
  currentBalance: Scalars['Int']['output'];
  totalEarned: Scalars['Int']['output'];
  totalReservedPending: Scalars['Int']['output'];
  totalSpentApproved: Scalars['Int']['output'];
};

export type PointTransactionHistoryResult = {
  __typename?: 'PointTransactionHistoryResult';
  items: Array<PointTransactionType>;
  total: Scalars['Int']['output'];
};

export type PointTransactionType = {
  __typename?: 'PointTransactionType';
  amount: Scalars['Int']['output'];
  createdAt: Scalars['DateTime']['output'];
  description: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  relatedRewardId?: Maybe<Scalars['ID']['output']>;
  relatedRewardName?: Maybe<Scalars['String']['output']>;
  relatedTaskId?: Maybe<Scalars['ID']['output']>;
  relatedTaskTitle?: Maybe<Scalars['String']['output']>;
  type: PointTransactionTypeEnum;
};

/** Тип транзакции поинтов */
export type PointTransactionTypeEnum =
  | 'EARNED'
  | 'REFUNDED'
  | 'RESERVED'
  | 'SPENT';

/** Result of a push notification send attempt (Phase 8) */
export type PushNotificationResultType = {
  __typename?: 'PushNotificationResultType';
  error?: Maybe<Scalars['String']['output']>;
  messageId?: Maybe<Scalars['String']['output']>;
  success: Scalars['Boolean']['output'];
};

export type Query = {
  __typename?: 'Query';
  /** Get audit logs with filtering and pagination (admin only) */
  getAuditLogs: AuditLogListType;
  getGroup: GroupType;
  /** Get audit logs for a specific group */
  getGroupAuditLog: Array<AuditLogType>;
  /** Group leaderboard by earned points (PRD 3.5.5) */
  getGroupLeaderboard: Array<LeaderboardEntryType>;
  getGroupMembers: Array<GroupMemberType>;
  /** List all group reward requests (admin only) (PRD 3.5.4) */
  getGroupRewardRequests: Array<RewardTransactionType>;
  /** List active rewards for group (PRD 3.5.3) */
  getGroupRewards: Array<RewardType>;
  getGroupTasks: Array<TaskType>;
  /** Get audit logs for current user actions */
  getMyAuditLogs: Array<AuditLogType>;
  /** List my reward requests (PRD 3.5.4) */
  getMyRewardRequests: Array<RewardTransactionType>;
  /** Get point balance summary (PRD 3.5.1-3.5.4) */
  getPointBalance: PointBalanceType;
  /** Get point transaction history for current user (BACKEND_API_REQUIREMENTS.md - Critical Phase 6.4) */
  getPointTransactionHistory: PointTransactionHistoryResult;
  /** Get history of tasks assigned through rotation system */
  getRotationHistory: RotationHistoryResult;
  /** Get current rotation configuration and cycle state */
  getRotationPattern: RotationPatternType;
  /** Get planned rotation schedule for next 30 days (requires recurring task scheduler - Phase 9) */
  getRotationSchedule: Array<RotationScheduleEntry>;
  getTask: TaskType;
  /** Get audit logs for a specific task */
  getTaskAuditLog: Array<AuditLogType>;
  getUserGroups: Array<GroupType>;
  getUserTasks: Array<TaskType>;
  hello: Scalars['String']['output'];
  /** Получить информацию о текущем пользователе */
  me: UserType;
  /** List my registered device tokens */
  myDeviceTokens: Array<DeviceTokenType>;
  /** Get my notification preferences */
  myNotificationPreference: NotificationPreferenceType;
  /** List my notifications (PRD 3.6.3) */
  myNotifications: NotificationListResult;
  /** Get statistics for the current authenticated user */
  myStatistics: UserStatistics;
  /** Get statistics for a specific user by ID */
  userStatistics: UserStatistics;
};


export type QueryGetAuditLogsArgs = {
  input?: InputMaybe<GetAuditLogsInput>;
};


export type QueryGetGroupArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupAuditLogArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupLeaderboardArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupMembersArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupRewardRequestsArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupRewardsArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetGroupTasksArgs = {
  groupId: Scalars['String']['input'];
  status?: InputMaybe<Scalars['String']['input']>;
};


export type QueryGetMyAuditLogsArgs = {
  limit?: InputMaybe<Scalars['Float']['input']>;
};


export type QueryGetMyRewardRequestsArgs = {
  groupId?: InputMaybe<Scalars['String']['input']>;
};


export type QueryGetPointBalanceArgs = {
  groupId?: InputMaybe<Scalars['String']['input']>;
};


export type QueryGetPointTransactionHistoryArgs = {
  groupId?: InputMaybe<Scalars['String']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type QueryGetRotationHistoryArgs = {
  groupId: Scalars['String']['input'];
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type QueryGetRotationPatternArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetRotationScheduleArgs = {
  groupId: Scalars['String']['input'];
};


export type QueryGetTaskArgs = {
  taskId: Scalars['String']['input'];
};


export type QueryGetTaskAuditLogArgs = {
  taskId: Scalars['String']['input'];
};


export type QueryGetUserTasksArgs = {
  status?: InputMaybe<Scalars['String']['input']>;
};


export type QueryMyNotificationsArgs = {
  input?: InputMaybe<ListNotificationsInput>;
};


export type QueryMyStatisticsArgs = {
  groupId?: InputMaybe<Scalars['String']['input']>;
};


export type QueryUserStatisticsArgs = {
  groupId?: InputMaybe<Scalars['String']['input']>;
  userId: Scalars['String']['input'];
};

export type RefreshTokenInput = {
  refreshToken: Scalars['String']['input'];
};

export type RegisterDeviceTokenInput = {
  platform?: InputMaybe<Scalars['String']['input']>;
  provider?: InputMaybe<Scalars['String']['input']>;
  token: Scalars['String']['input'];
};

export type RegisterInput = {
  email: Scalars['String']['input'];
  password: Scalars['String']['input'];
  username: Scalars['String']['input'];
};

export type RemoveDeviceTokenInput = {
  token: Scalars['String']['input'];
};

export type RequestRewardInput = {
  rewardId: Scalars['ID']['input'];
};

export type RewardTransactionType = {
  __typename?: 'RewardTransactionType';
  approvedAt?: Maybe<Scalars['DateTime']['output']>;
  approvedById?: Maybe<Scalars['ID']['output']>;
  id: Scalars['ID']['output'];
  pointsSpent: Scalars['Int']['output'];
  rejectedAt?: Maybe<Scalars['DateTime']['output']>;
  rejectionReason?: Maybe<Scalars['String']['output']>;
  requestedAt: Scalars['DateTime']['output'];
  rewardId: Scalars['ID']['output'];
  status: Scalars['String']['output'];
  userId: Scalars['ID']['output'];
};

export type RewardType = {
  __typename?: 'RewardType';
  cost: Scalars['Int']['output'];
  createdAt: Scalars['DateTime']['output'];
  createdById: Scalars['ID']['output'];
  description?: Maybe<Scalars['String']['output']>;
  groupId: Scalars['ID']['output'];
  id: Scalars['ID']['output'];
  imageUrl?: Maybe<Scalars['String']['output']>;
  isActive: Scalars['Boolean']['output'];
  name: Scalars['String']['output'];
};

export type RotationHistoryEntry = {
  __typename?: 'RotationHistoryEntry';
  /** Date and time when task was assigned */
  assignedAt: Scalars['DateTime']['output'];
  /** Avatar URL of assignee */
  avatarUrl?: Maybe<Scalars['String']['output']>;
  /** Date and time when task was completed (null if not completed) */
  completedAt?: Maybe<Scalars['DateTime']['output']>;
  /** Points earned for completion (0 if not completed) */
  pointsEarned: Scalars['Int']['output'];
  /** Rotation type used for assignment */
  rotationType: Scalars['String']['output'];
  /** Current task status */
  status: Scalars['String']['output'];
  /** Task ID */
  taskId: Scalars['ID']['output'];
  /** Task title */
  taskTitle: Scalars['String']['output'];
  /** User ID who was assigned the task */
  userId: Scalars['ID']['output'];
  /** Username of assignee */
  username: Scalars['String']['output'];
};

export type RotationHistoryResult = {
  __typename?: 'RotationHistoryResult';
  /** List of rotation history entries */
  items: Array<RotationHistoryEntry>;
  /** Total number of entries */
  total: Scalars['Int']['output'];
};

export type RotationPatternType = {
  __typename?: 'RotationPatternType';
  /** Active members (not away) */
  activeMembers: Array<GroupMemberUserType>;
  /** Members currently away */
  awayMembers: Array<GroupMemberUserType>;
  /** Array of user IDs in rotation order (CYCLIC only) */
  currentCycle: Array<Scalars['String']['output']>;
  /** Current index in cycle (CYCLIC only, 0-based) */
  currentCycleIndex?: Maybe<Scalars['Int']['output']>;
  /** Date of last rotation assignment */
  lastRotationAt?: Maybe<Scalars['DateTime']['output']>;
  /** Date of next planned rotation assignment */
  nextRotationAt?: Maybe<Scalars['DateTime']['output']>;
  /** Rotation type of the group */
  rotationType: Scalars['String']['output'];
};

export type RotationScheduleEntry = {
  __typename?: 'RotationScheduleEntry';
  /** Avatar URL of assignee */
  avatarUrl?: Maybe<Scalars['String']['output']>;
  /** Base points for task completion */
  points: Scalars['Int']['output'];
  /** Task priority level */
  priority: Scalars['String']['output'];
  /** Rotation type for this task */
  rotationType: Scalars['String']['output'];
  /** Scheduled assignment date and time */
  scheduledDate: Scalars['DateTime']['output'];
  /** Task ID (for recurring tasks - template ID) */
  taskId: Scalars['ID']['output'];
  /** Task title */
  taskTitle: Scalars['String']['output'];
  /** User ID who will be assigned the task */
  userId: Scalars['ID']['output'];
  /** Username of assignee */
  username: Scalars['String']['output'];
};

export type SetAwayStatusInput = {
  /** Date when user will return (null for indefinite) */
  awayUntil?: InputMaybe<Scalars['String']['input']>;
  /** Flag indicating if user is away */
  isAway: Scalars['Boolean']['input'];
};

export type TaskType = {
  __typename?: 'TaskType';
  approvedById?: Maybe<Scalars['String']['output']>;
  assignee?: Maybe<GroupMemberUserType>;
  assigneeId?: Maybe<Scalars['String']['output']>;
  childTasks?: Maybe<Array<TaskType>>;
  completedAt?: Maybe<Scalars['DateTime']['output']>;
  createdAt: Scalars['DateTime']['output'];
  createdBy: GroupMemberUserType;
  createdById: Scalars['String']['output'];
  deadline: Scalars['DateTime']['output'];
  description?: Maybe<Scalars['String']['output']>;
  groupId: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  isRecurring: Scalars['Boolean']['output'];
  parentTask?: Maybe<TaskType>;
  parentTaskId?: Maybe<Scalars['String']['output']>;
  points: Scalars['Int']['output'];
  priority: Scalars['String']['output'];
  recurrenceRule?: Maybe<Scalars['String']['output']>;
  rejectionReason?: Maybe<Scalars['String']['output']>;
  requiresApproval: Scalars['Boolean']['output'];
  rotationType?: Maybe<Scalars['String']['output']>;
  status: Scalars['String']['output'];
  title: Scalars['String']['output'];
  wasClaimedFromPool: Scalars['Boolean']['output'];
  weight: Scalars['Int']['output'];
};

export type TestPushInput = {
  body: Scalars['String']['input'];
  data?: InputMaybe<Scalars['JSON']['input']>;
  title: Scalars['String']['input'];
};

export type UpdateGroupInput = {
  description?: InputMaybe<Scalars['String']['input']>;
  gamificationEnabled?: InputMaybe<Scalars['Boolean']['input']>;
  name?: InputMaybe<Scalars['String']['input']>;
  requiresApproval?: InputMaybe<Scalars['Boolean']['input']>;
  rotationType?: InputMaybe<Scalars['String']['input']>;
};

export type UpdateMemberRoleInput = {
  role: Scalars['String']['input'];
  userId: Scalars['String']['input'];
};

export type UpdateRewardInput = {
  cost?: InputMaybe<Scalars['Int']['input']>;
  description?: InputMaybe<Scalars['String']['input']>;
  groupId: Scalars['ID']['input'];
  imageUrl?: InputMaybe<Scalars['String']['input']>;
  isActive?: InputMaybe<Scalars['Boolean']['input']>;
  name?: InputMaybe<Scalars['String']['input']>;
  rewardId: Scalars['ID']['input'];
};

export type UpdateTaskInput = {
  assigneeId?: InputMaybe<Scalars['String']['input']>;
  deadline?: InputMaybe<Scalars['String']['input']>;
  description?: InputMaybe<Scalars['String']['input']>;
  points?: InputMaybe<Scalars['Int']['input']>;
  priority?: InputMaybe<Scalars['String']['input']>;
  requiresApproval?: InputMaybe<Scalars['Boolean']['input']>;
  title?: InputMaybe<Scalars['String']['input']>;
};

export type UpdateUserInput = {
  /** URL of user avatar image */
  avatarUrl?: InputMaybe<Scalars['String']['input']>;
  /** New username (3-30 characters, alphanumeric and underscore only) */
  username?: InputMaybe<Scalars['String']['input']>;
};

export type UpsertNotificationPreferenceInput = {
  batchingEnabled?: InputMaybe<Scalars['Boolean']['input']>;
  enablePush?: InputMaybe<Scalars['Boolean']['input']>;
  mutedTypes?: InputMaybe<Array<Scalars['String']['input']>>;
  quietHoursEnd?: InputMaybe<Scalars['String']['input']>;
  quietHoursStart?: InputMaybe<Scalars['String']['input']>;
};

export type UserStatistics = {
  __typename?: 'UserStatistics';
  /** Task completion rate (completed / assigned) as percentage */
  completionRate: Scalars['Float']['output'];
  /** Current point balance (total earned - total spent) */
  currentPointBalance: Scalars['Int']['output'];
  /** Group ID for group-specific statistics (null for overall stats) */
  groupId?: Maybe<Scalars['ID']['output']>;
  /** Leaderboard position (1-based, null if no completions) */
  leaderboardPosition?: Maybe<Scalars['Int']['output']>;
  /** On-time completion percentage */
  onTimePercentage: Scalars['Float']['output'];
  /** Total number of tasks assigned to user */
  tasksAssigned: Scalars['Int']['output'];
  /** Total number of tasks completed */
  tasksCompleted: Scalars['Int']['output'];
  /** Number of tasks completed on time */
  tasksCompletedOnTime: Scalars['Int']['output'];
  /** Total points earned from completed tasks */
  totalPointsEarned: Scalars['Int']['output'];
  /** Total points spent on rewards */
  totalPointsSpent: Scalars['Int']['output'];
  /** User ID */
  userId: Scalars['ID']['output'];
};

export type UserType = {
  __typename?: 'UserType';
  avatarUrl?: Maybe<Scalars['String']['output']>;
  awayUntil?: Maybe<Scalars['DateTime']['output']>;
  createdAt: Scalars['DateTime']['output'];
  email: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  isAway: Scalars['Boolean']['output'];
  updatedAt: Scalars['DateTime']['output'];
  username: Scalars['String']['output'];
};

export type LoginMutationVariables = Exact<{
  input: LoginInput;
}>;


export type LoginMutation = { __typename?: 'Mutation', login: { __typename?: 'AuthResponseType', accessToken: string, refreshToken: string, user: { __typename?: 'UserType', id: string, email: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null, createdAt: any, updatedAt: any } } };

export type RegisterMutationVariables = Exact<{
  input: RegisterInput;
}>;


export type RegisterMutation = { __typename?: 'Mutation', register: { __typename?: 'AuthResponseType', accessToken: string, refreshToken: string, user: { __typename?: 'UserType', id: string, email: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null, createdAt: any, updatedAt: any } } };

export type LogoutMutationVariables = Exact<{
  refreshToken: Scalars['String']['input'];
}>;


export type LogoutMutation = { __typename?: 'Mutation', logout: boolean };

export type RefreshTokenMutationVariables = Exact<{
  input: RefreshTokenInput;
}>;


export type RefreshTokenMutation = { __typename?: 'Mutation', refreshToken: { __typename?: 'AuthResponseType', accessToken: string, refreshToken: string, user: { __typename?: 'UserType', id: string, email: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null } } };

export type MeQueryVariables = Exact<{ [key: string]: never; }>;


export type MeQuery = { __typename?: 'Query', me: { __typename?: 'UserType', id: string, email: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null, createdAt: any, updatedAt: any } };

export type ChangePasswordMutationVariables = Exact<{
  input: ChangePasswordInput;
}>;


export type ChangePasswordMutation = { __typename?: 'Mutation', changePassword: boolean };

export type GetUserGroupsQueryVariables = Exact<{ [key: string]: never; }>;


export type GetUserGroupsQuery = { __typename?: 'Query', getUserGroups: Array<{ __typename?: 'GroupType', id: string, name: string, description?: string | null, inviteToken?: string | null, requiresApproval: boolean, rotationType: string, gamificationEnabled: boolean, createdAt: any, updatedAt: any, createdById: string }> };

export type GetGroupQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetGroupQuery = { __typename?: 'Query', getGroup: { __typename?: 'GroupType', id: string, name: string, description?: string | null, inviteToken?: string | null, requiresApproval: boolean, rotationType: string, gamificationEnabled: boolean, createdAt: any, updatedAt: any, createdById: string } };

export type GetGroupMembersQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetGroupMembersQuery = { __typename?: 'Query', getGroupMembers: Array<{ __typename?: 'GroupMemberType', id: string, userId: string, groupId: string, role: string, joinedAt: any, roleChangedAt: any, user: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null } }> };

export type CreateGroupMutationVariables = Exact<{
  input: CreateGroupInput;
}>;


export type CreateGroupMutation = { __typename?: 'Mutation', createGroup: { __typename?: 'GroupType', id: string, name: string, description?: string | null, inviteToken?: string | null, requiresApproval: boolean, rotationType: string, gamificationEnabled: boolean, createdAt: any, updatedAt: any, createdById: string } };

export type UpdateGroupMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
  input: UpdateGroupInput;
}>;


export type UpdateGroupMutation = { __typename?: 'Mutation', updateGroup: { __typename?: 'GroupType', id: string, name: string, description?: string | null, requiresApproval: boolean, rotationType: string, gamificationEnabled: boolean, updatedAt: any } };

export type DeleteGroupMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type DeleteGroupMutation = { __typename?: 'Mutation', deleteGroup: boolean };

export type JoinGroupMutationVariables = Exact<{
  input: JoinGroupInput;
}>;


export type JoinGroupMutation = { __typename?: 'Mutation', joinGroup: { __typename?: 'GroupType', id: string, name: string, description?: string | null } };

export type LeaveGroupMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type LeaveGroupMutation = { __typename?: 'Mutation', leaveGroup: boolean };

export type RemoveMemberMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
  userId: Scalars['String']['input'];
}>;


export type RemoveMemberMutation = { __typename?: 'Mutation', removeMember: boolean };

export type UpdateMemberRoleMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
  input: UpdateMemberRoleInput;
}>;


export type UpdateMemberRoleMutation = { __typename?: 'Mutation', updateMemberRole: { __typename?: 'GroupMemberType', id: string, userId: string, role: string, roleChangedAt: any } };

export type RegenerateInviteTokenMutationVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type RegenerateInviteTokenMutation = { __typename?: 'Mutation', regenerateInviteToken: string };

export type GetGroupTasksQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
  status?: InputMaybe<Scalars['String']['input']>;
}>;


export type GetGroupTasksQuery = { __typename?: 'Query', getGroupTasks: Array<{ __typename?: 'TaskType', id: string, title: string, description?: string | null, deadline: any, priority: string, status: string, points: number, requiresApproval: boolean, isRecurring: boolean, recurrenceRule?: string | null, rotationType?: string | null, weight: number, wasClaimedFromPool: boolean, createdAt: any, completedAt?: any | null, groupId: string, createdById: string, assigneeId?: string | null, approvedById?: string | null, parentTaskId?: string | null, assignee?: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null } | null, createdBy: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null } }> };

export type GetUserTasksQueryVariables = Exact<{
  status?: InputMaybe<Scalars['String']['input']>;
}>;


export type GetUserTasksQuery = { __typename?: 'Query', getUserTasks: Array<{ __typename?: 'TaskType', id: string, title: string, description?: string | null, deadline: any, priority: string, status: string, points: number, requiresApproval: boolean, isRecurring: boolean, recurrenceRule?: string | null, wasClaimedFromPool: boolean, groupId: string, createdAt: any, completedAt?: any | null, assigneeId?: string | null, createdBy: { __typename?: 'GroupMemberUserType', id: string, username: string } }> };

export type GetTaskQueryVariables = Exact<{
  taskId: Scalars['String']['input'];
}>;


export type GetTaskQuery = { __typename?: 'Query', getTask: { __typename?: 'TaskType', id: string, title: string, description?: string | null, deadline: any, priority: string, status: string, points: number, requiresApproval: boolean, isRecurring: boolean, recurrenceRule?: string | null, rotationType?: string | null, weight: number, wasClaimedFromPool: boolean, createdAt: any, completedAt?: any | null, groupId: string, createdById: string, assigneeId?: string | null, approvedById?: string | null, parentTaskId?: string | null, assignee?: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null } | null, createdBy: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null } } };

export type CreateTaskMutationVariables = Exact<{
  input: CreateTaskInput;
}>;


export type CreateTaskMutation = { __typename?: 'Mutation', createTask: { __typename?: 'TaskType', id: string, title: string, description?: string | null, deadline: any, priority: string, status: string, points: number, requiresApproval: boolean, isRecurring: boolean, recurrenceRule?: string | null, groupId: string, createdAt: any, assigneeId?: string | null } };

export type UpdateTaskMutationVariables = Exact<{
  taskId: Scalars['String']['input'];
  input: UpdateTaskInput;
}>;


export type UpdateTaskMutation = { __typename?: 'Mutation', updateTask: { __typename?: 'TaskType', id: string, title: string, description?: string | null, deadline: any, priority: string, points: number, requiresApproval: boolean, assigneeId?: string | null } };

export type DeleteTaskMutationVariables = Exact<{
  taskId: Scalars['String']['input'];
}>;


export type DeleteTaskMutation = { __typename?: 'Mutation', deleteTask: boolean };

export type CompleteTaskMutationVariables = Exact<{
  input: CompleteTaskInput;
}>;


export type CompleteTaskMutation = { __typename?: 'Mutation', completeTask: { __typename?: 'TaskType', id: string, status: string, completedAt?: any | null } };

export type ApproveTaskMutationVariables = Exact<{
  input: ApproveTaskInput;
}>;


export type ApproveTaskMutation = { __typename?: 'Mutation', approveTask: { __typename?: 'TaskType', id: string, status: string, approvedById?: string | null } };

export type ClaimTaskMutationVariables = Exact<{
  input: ClaimTaskInput;
}>;


export type ClaimTaskMutation = { __typename?: 'Mutation', claimTask: { __typename?: 'TaskType', id: string, status: string, assigneeId?: string | null, wasClaimedFromPool: boolean, assignee?: { __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null } | null } };

export type MyStatisticsQueryVariables = Exact<{
  groupId?: InputMaybe<Scalars['String']['input']>;
}>;


export type MyStatisticsQuery = { __typename?: 'Query', myStatistics: { __typename?: 'UserStatistics', userId: string, currentPointBalance: number, totalPointsEarned: number, totalPointsSpent: number, tasksCompleted: number, tasksAssigned: number, completionRate: number, tasksCompletedOnTime: number, onTimePercentage: number, leaderboardPosition?: number | null, groupId?: string | null } };

export type UserStatisticsQueryVariables = Exact<{
  userId: Scalars['String']['input'];
  groupId?: InputMaybe<Scalars['String']['input']>;
}>;


export type UserStatisticsQuery = { __typename?: 'Query', userStatistics: { __typename?: 'UserStatistics', userId: string, currentPointBalance: number, totalPointsEarned: number, totalPointsSpent: number, tasksCompleted: number, tasksAssigned: number, completionRate: number, tasksCompletedOnTime: number, onTimePercentage: number, leaderboardPosition?: number | null, groupId?: string | null } };

export type UpdateUserMutationVariables = Exact<{
  input: UpdateUserInput;
}>;


export type UpdateUserMutation = { __typename?: 'Mutation', updateUser: { __typename?: 'UserType', id: string, username: string, avatarUrl?: string | null, updatedAt: any } };

export type SetAwayStatusMutationVariables = Exact<{
  input: SetAwayStatusInput;
}>;


export type SetAwayStatusMutation = { __typename?: 'Mutation', setUserAwayStatus: { __typename?: 'UserType', id: string, isAway: boolean, awayUntil?: any | null, updatedAt: any } };

export type GetRotationScheduleQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetRotationScheduleQuery = { __typename?: 'Query', getRotationSchedule: Array<{ __typename?: 'RotationScheduleEntry', taskId: string, taskTitle: string, userId: string, username: string, avatarUrl?: string | null, scheduledDate: any, rotationType: string, priority: string, points: number }> };

export type GetRotationHistoryQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
}>;


export type GetRotationHistoryQuery = { __typename?: 'Query', getRotationHistory: { __typename?: 'RotationHistoryResult', total: number, items: Array<{ __typename?: 'RotationHistoryEntry', taskId: string, taskTitle: string, userId: string, username: string, avatarUrl?: string | null, assignedAt: any, completedAt?: any | null, status: string, rotationType: string, pointsEarned: number }> } };

export type GetRotationPatternQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetRotationPatternQuery = { __typename?: 'Query', getRotationPattern: { __typename?: 'RotationPatternType', rotationType: string, currentCycle: Array<string>, currentCycleIndex?: number | null, lastRotationAt?: any | null, nextRotationAt?: any | null, activeMembers: Array<{ __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null }>, awayMembers: Array<{ __typename?: 'GroupMemberUserType', id: string, username: string, avatarUrl?: string | null, isAway: boolean, awayUntil?: any | null }> } };

export type GetGroupRewardsQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetGroupRewardsQuery = { __typename?: 'Query', getGroupRewards: Array<{ __typename?: 'RewardType', id: string, name: string, description?: string | null, cost: number, isActive: boolean, imageUrl?: string | null, createdAt: any, groupId: string, createdById: string }> };

export type GetMyRewardRequestsQueryVariables = Exact<{
  groupId?: InputMaybe<Scalars['String']['input']>;
}>;


export type GetMyRewardRequestsQuery = { __typename?: 'Query', getMyRewardRequests: Array<{ __typename?: 'RewardTransactionType', id: string, userId: string, rewardId: string, status: string, pointsSpent: number, requestedAt: any, approvedAt?: any | null, rejectedAt?: any | null, rejectionReason?: string | null, approvedById?: string | null }> };

export type GetGroupRewardRequestsQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetGroupRewardRequestsQuery = { __typename?: 'Query', getGroupRewardRequests: Array<{ __typename?: 'RewardTransactionType', id: string, userId: string, rewardId: string, status: string, pointsSpent: number, requestedAt: any, approvedAt?: any | null, rejectedAt?: any | null, rejectionReason?: string | null, approvedById?: string | null }> };

export type CreateRewardMutationVariables = Exact<{
  input: CreateRewardInput;
}>;


export type CreateRewardMutation = { __typename?: 'Mutation', createReward: { __typename?: 'RewardType', id: string, name: string, description?: string | null, cost: number, isActive: boolean, imageUrl?: string | null, createdAt: any, groupId: string, createdById: string } };

export type UpdateRewardMutationVariables = Exact<{
  input: UpdateRewardInput;
}>;


export type UpdateRewardMutation = { __typename?: 'Mutation', updateReward: { __typename?: 'RewardType', id: string, name: string, description?: string | null, cost: number, isActive: boolean, imageUrl?: string | null, groupId: string } };

export type DeleteRewardMutationVariables = Exact<{
  rewardId: Scalars['String']['input'];
  groupId: Scalars['String']['input'];
}>;


export type DeleteRewardMutation = { __typename?: 'Mutation', deleteReward: boolean };

export type RequestRewardMutationVariables = Exact<{
  input: RequestRewardInput;
}>;


export type RequestRewardMutation = { __typename?: 'Mutation', requestReward: { __typename?: 'RewardTransactionType', id: string, userId: string, rewardId: string, status: string, pointsSpent: number, requestedAt: any } };

export type ApproveRewardRequestMutationVariables = Exact<{
  input: ApproveRewardRequestInput;
}>;


export type ApproveRewardRequestMutation = { __typename?: 'Mutation', approveRewardRequest: { __typename?: 'RewardTransactionType', id: string, status: string, approvedAt?: any | null, rejectedAt?: any | null, rejectionReason?: string | null, approvedById?: string | null } };

export type GetPointBalanceQueryVariables = Exact<{
  groupId?: InputMaybe<Scalars['String']['input']>;
}>;


export type GetPointBalanceQuery = { __typename?: 'Query', getPointBalance: { __typename?: 'PointBalanceType', totalEarned: number, totalSpentApproved: number, totalReservedPending: number, currentBalance: number, availableBalance: number } };

export type GetPointTransactionHistoryQueryVariables = Exact<{
  groupId?: InputMaybe<Scalars['String']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
}>;


export type GetPointTransactionHistoryQuery = { __typename?: 'Query', getPointTransactionHistory: { __typename?: 'PointTransactionHistoryResult', total: number, items: Array<{ __typename?: 'PointTransactionType', id: string, type: PointTransactionTypeEnum, amount: number, description: string, relatedTaskId?: string | null, relatedTaskTitle?: string | null, relatedRewardId?: string | null, relatedRewardName?: string | null, createdAt: any }> } };

export type GetGroupLeaderboardQueryVariables = Exact<{
  groupId: Scalars['String']['input'];
}>;


export type GetGroupLeaderboardQuery = { __typename?: 'Query', getGroupLeaderboard: Array<{ __typename?: 'LeaderboardEntryType', pointsEarned: number, rank: number, user: { __typename?: 'UserType', id: string, username: string, avatarUrl?: string | null, email: string } }> };


export const LoginDocument = gql`
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
    `;

export function useLoginMutation() {
  return Urql.useMutation<LoginMutation, LoginMutationVariables>(LoginDocument);
};
export const RegisterDocument = gql`
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
    `;

export function useRegisterMutation() {
  return Urql.useMutation<RegisterMutation, RegisterMutationVariables>(RegisterDocument);
};
export const LogoutDocument = gql`
    mutation Logout($refreshToken: String!) {
  logout(refreshToken: $refreshToken)
}
    `;

export function useLogoutMutation() {
  return Urql.useMutation<LogoutMutation, LogoutMutationVariables>(LogoutDocument);
};
export const RefreshTokenDocument = gql`
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
    `;

export function useRefreshTokenMutation() {
  return Urql.useMutation<RefreshTokenMutation, RefreshTokenMutationVariables>(RefreshTokenDocument);
};
export const MeDocument = gql`
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
    `;

export function useMeQuery(options?: Omit<Urql.UseQueryArgs<MeQueryVariables>, 'query'>) {
  return Urql.useQuery<MeQuery, MeQueryVariables>({ query: MeDocument, ...options });
};
export const ChangePasswordDocument = gql`
    mutation ChangePassword($input: ChangePasswordInput!) {
  changePassword(input: $input)
}
    `;

export function useChangePasswordMutation() {
  return Urql.useMutation<ChangePasswordMutation, ChangePasswordMutationVariables>(ChangePasswordDocument);
};
export const GetUserGroupsDocument = gql`
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
    `;

export function useGetUserGroupsQuery(options?: Omit<Urql.UseQueryArgs<GetUserGroupsQueryVariables>, 'query'>) {
  return Urql.useQuery<GetUserGroupsQuery, GetUserGroupsQueryVariables>({ query: GetUserGroupsDocument, ...options });
};
export const GetGroupDocument = gql`
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
    `;

export function useGetGroupQuery(options: Omit<Urql.UseQueryArgs<GetGroupQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupQuery, GetGroupQueryVariables>({ query: GetGroupDocument, ...options });
};
export const GetGroupMembersDocument = gql`
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
    `;

export function useGetGroupMembersQuery(options: Omit<Urql.UseQueryArgs<GetGroupMembersQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupMembersQuery, GetGroupMembersQueryVariables>({ query: GetGroupMembersDocument, ...options });
};
export const CreateGroupDocument = gql`
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
    `;

export function useCreateGroupMutation() {
  return Urql.useMutation<CreateGroupMutation, CreateGroupMutationVariables>(CreateGroupDocument);
};
export const UpdateGroupDocument = gql`
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
    `;

export function useUpdateGroupMutation() {
  return Urql.useMutation<UpdateGroupMutation, UpdateGroupMutationVariables>(UpdateGroupDocument);
};
export const DeleteGroupDocument = gql`
    mutation DeleteGroup($groupId: String!) {
  deleteGroup(groupId: $groupId)
}
    `;

export function useDeleteGroupMutation() {
  return Urql.useMutation<DeleteGroupMutation, DeleteGroupMutationVariables>(DeleteGroupDocument);
};
export const JoinGroupDocument = gql`
    mutation JoinGroup($input: JoinGroupInput!) {
  joinGroup(input: $input) {
    id
    name
    description
  }
}
    `;

export function useJoinGroupMutation() {
  return Urql.useMutation<JoinGroupMutation, JoinGroupMutationVariables>(JoinGroupDocument);
};
export const LeaveGroupDocument = gql`
    mutation LeaveGroup($groupId: String!) {
  leaveGroup(groupId: $groupId)
}
    `;

export function useLeaveGroupMutation() {
  return Urql.useMutation<LeaveGroupMutation, LeaveGroupMutationVariables>(LeaveGroupDocument);
};
export const RemoveMemberDocument = gql`
    mutation RemoveMember($groupId: String!, $userId: String!) {
  removeMember(groupId: $groupId, userId: $userId)
}
    `;

export function useRemoveMemberMutation() {
  return Urql.useMutation<RemoveMemberMutation, RemoveMemberMutationVariables>(RemoveMemberDocument);
};
export const UpdateMemberRoleDocument = gql`
    mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
  updateMemberRole(groupId: $groupId, input: $input) {
    id
    userId
    role
    roleChangedAt
  }
}
    `;

export function useUpdateMemberRoleMutation() {
  return Urql.useMutation<UpdateMemberRoleMutation, UpdateMemberRoleMutationVariables>(UpdateMemberRoleDocument);
};
export const RegenerateInviteTokenDocument = gql`
    mutation RegenerateInviteToken($groupId: String!) {
  regenerateInviteToken(groupId: $groupId)
}
    `;

export function useRegenerateInviteTokenMutation() {
  return Urql.useMutation<RegenerateInviteTokenMutation, RegenerateInviteTokenMutationVariables>(RegenerateInviteTokenDocument);
};
export const GetGroupTasksDocument = gql`
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
    `;

export function useGetGroupTasksQuery(options: Omit<Urql.UseQueryArgs<GetGroupTasksQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupTasksQuery, GetGroupTasksQueryVariables>({ query: GetGroupTasksDocument, ...options });
};
export const GetUserTasksDocument = gql`
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
    `;

export function useGetUserTasksQuery(options?: Omit<Urql.UseQueryArgs<GetUserTasksQueryVariables>, 'query'>) {
  return Urql.useQuery<GetUserTasksQuery, GetUserTasksQueryVariables>({ query: GetUserTasksDocument, ...options });
};
export const GetTaskDocument = gql`
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
    `;

export function useGetTaskQuery(options: Omit<Urql.UseQueryArgs<GetTaskQueryVariables>, 'query'>) {
  return Urql.useQuery<GetTaskQuery, GetTaskQueryVariables>({ query: GetTaskDocument, ...options });
};
export const CreateTaskDocument = gql`
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
    `;

export function useCreateTaskMutation() {
  return Urql.useMutation<CreateTaskMutation, CreateTaskMutationVariables>(CreateTaskDocument);
};
export const UpdateTaskDocument = gql`
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
    `;

export function useUpdateTaskMutation() {
  return Urql.useMutation<UpdateTaskMutation, UpdateTaskMutationVariables>(UpdateTaskDocument);
};
export const DeleteTaskDocument = gql`
    mutation DeleteTask($taskId: String!) {
  deleteTask(taskId: $taskId)
}
    `;

export function useDeleteTaskMutation() {
  return Urql.useMutation<DeleteTaskMutation, DeleteTaskMutationVariables>(DeleteTaskDocument);
};
export const CompleteTaskDocument = gql`
    mutation CompleteTask($input: CompleteTaskInput!) {
  completeTask(input: $input) {
    id
    status
    completedAt
  }
}
    `;

export function useCompleteTaskMutation() {
  return Urql.useMutation<CompleteTaskMutation, CompleteTaskMutationVariables>(CompleteTaskDocument);
};
export const ApproveTaskDocument = gql`
    mutation ApproveTask($input: ApproveTaskInput!) {
  approveTask(input: $input) {
    id
    status
    approvedById
  }
}
    `;

export function useApproveTaskMutation() {
  return Urql.useMutation<ApproveTaskMutation, ApproveTaskMutationVariables>(ApproveTaskDocument);
};
export const ClaimTaskDocument = gql`
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
    `;

export function useClaimTaskMutation() {
  return Urql.useMutation<ClaimTaskMutation, ClaimTaskMutationVariables>(ClaimTaskDocument);
};
export const MyStatisticsDocument = gql`
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
    `;

export function useMyStatisticsQuery(options?: Omit<Urql.UseQueryArgs<MyStatisticsQueryVariables>, 'query'>) {
  return Urql.useQuery<MyStatisticsQuery, MyStatisticsQueryVariables>({ query: MyStatisticsDocument, ...options });
};
export const UserStatisticsDocument = gql`
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
    `;

export function useUserStatisticsQuery(options: Omit<Urql.UseQueryArgs<UserStatisticsQueryVariables>, 'query'>) {
  return Urql.useQuery<UserStatisticsQuery, UserStatisticsQueryVariables>({ query: UserStatisticsDocument, ...options });
};
export const UpdateUserDocument = gql`
    mutation UpdateUser($input: UpdateUserInput!) {
  updateUser(input: $input) {
    id
    username
    avatarUrl
    updatedAt
  }
}
    `;

export function useUpdateUserMutation() {
  return Urql.useMutation<UpdateUserMutation, UpdateUserMutationVariables>(UpdateUserDocument);
};
export const SetAwayStatusDocument = gql`
    mutation SetAwayStatus($input: SetAwayStatusInput!) {
  setUserAwayStatus(input: $input) {
    id
    isAway
    awayUntil
    updatedAt
  }
}
    `;

export function useSetAwayStatusMutation() {
  return Urql.useMutation<SetAwayStatusMutation, SetAwayStatusMutationVariables>(SetAwayStatusDocument);
};
export const GetRotationScheduleDocument = gql`
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
    `;

export function useGetRotationScheduleQuery(options: Omit<Urql.UseQueryArgs<GetRotationScheduleQueryVariables>, 'query'>) {
  return Urql.useQuery<GetRotationScheduleQuery, GetRotationScheduleQueryVariables>({ query: GetRotationScheduleDocument, ...options });
};
export const GetRotationHistoryDocument = gql`
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
    `;

export function useGetRotationHistoryQuery(options: Omit<Urql.UseQueryArgs<GetRotationHistoryQueryVariables>, 'query'>) {
  return Urql.useQuery<GetRotationHistoryQuery, GetRotationHistoryQueryVariables>({ query: GetRotationHistoryDocument, ...options });
};
export const GetRotationPatternDocument = gql`
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
    `;

export function useGetRotationPatternQuery(options: Omit<Urql.UseQueryArgs<GetRotationPatternQueryVariables>, 'query'>) {
  return Urql.useQuery<GetRotationPatternQuery, GetRotationPatternQueryVariables>({ query: GetRotationPatternDocument, ...options });
};
export const GetGroupRewardsDocument = gql`
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
    `;

export function useGetGroupRewardsQuery(options: Omit<Urql.UseQueryArgs<GetGroupRewardsQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupRewardsQuery, GetGroupRewardsQueryVariables>({ query: GetGroupRewardsDocument, ...options });
};
export const GetMyRewardRequestsDocument = gql`
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
    `;

export function useGetMyRewardRequestsQuery(options?: Omit<Urql.UseQueryArgs<GetMyRewardRequestsQueryVariables>, 'query'>) {
  return Urql.useQuery<GetMyRewardRequestsQuery, GetMyRewardRequestsQueryVariables>({ query: GetMyRewardRequestsDocument, ...options });
};
export const GetGroupRewardRequestsDocument = gql`
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
    `;

export function useGetGroupRewardRequestsQuery(options: Omit<Urql.UseQueryArgs<GetGroupRewardRequestsQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupRewardRequestsQuery, GetGroupRewardRequestsQueryVariables>({ query: GetGroupRewardRequestsDocument, ...options });
};
export const CreateRewardDocument = gql`
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
    `;

export function useCreateRewardMutation() {
  return Urql.useMutation<CreateRewardMutation, CreateRewardMutationVariables>(CreateRewardDocument);
};
export const UpdateRewardDocument = gql`
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
    `;

export function useUpdateRewardMutation() {
  return Urql.useMutation<UpdateRewardMutation, UpdateRewardMutationVariables>(UpdateRewardDocument);
};
export const DeleteRewardDocument = gql`
    mutation DeleteReward($rewardId: String!, $groupId: String!) {
  deleteReward(rewardId: $rewardId, groupId: $groupId)
}
    `;

export function useDeleteRewardMutation() {
  return Urql.useMutation<DeleteRewardMutation, DeleteRewardMutationVariables>(DeleteRewardDocument);
};
export const RequestRewardDocument = gql`
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
    `;

export function useRequestRewardMutation() {
  return Urql.useMutation<RequestRewardMutation, RequestRewardMutationVariables>(RequestRewardDocument);
};
export const ApproveRewardRequestDocument = gql`
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
    `;

export function useApproveRewardRequestMutation() {
  return Urql.useMutation<ApproveRewardRequestMutation, ApproveRewardRequestMutationVariables>(ApproveRewardRequestDocument);
};
export const GetPointBalanceDocument = gql`
    query GetPointBalance($groupId: String) {
  getPointBalance(groupId: $groupId) {
    totalEarned
    totalSpentApproved
    totalReservedPending
    currentBalance
    availableBalance
  }
}
    `;

export function useGetPointBalanceQuery(options?: Omit<Urql.UseQueryArgs<GetPointBalanceQueryVariables>, 'query'>) {
  return Urql.useQuery<GetPointBalanceQuery, GetPointBalanceQueryVariables>({ query: GetPointBalanceDocument, ...options });
};
export const GetPointTransactionHistoryDocument = gql`
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
    `;

export function useGetPointTransactionHistoryQuery(options?: Omit<Urql.UseQueryArgs<GetPointTransactionHistoryQueryVariables>, 'query'>) {
  return Urql.useQuery<GetPointTransactionHistoryQuery, GetPointTransactionHistoryQueryVariables>({ query: GetPointTransactionHistoryDocument, ...options });
};
export const GetGroupLeaderboardDocument = gql`
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
    `;

export function useGetGroupLeaderboardQuery(options: Omit<Urql.UseQueryArgs<GetGroupLeaderboardQueryVariables>, 'query'>) {
  return Urql.useQuery<GetGroupLeaderboardQuery, GetGroupLeaderboardQueryVariables>({ query: GetGroupLeaderboardDocument, ...options });
};