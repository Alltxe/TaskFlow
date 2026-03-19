// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TaskFlow';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get myTasks => 'My tasks';

  @override
  String get noTasks => 'No tasks';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# items',
      few: '# items',
      one: '# item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get navigationProfileLabel => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get points => 'Points';

  @override
  String get completed => 'Completed';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get onTimeRate => 'On-Time Rate';

  @override
  String get myGroups => 'My Groups';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get joinOrCreateGroup => 'Join or create a group to get started';

  @override
  String get noDescription => 'No description';

  @override
  String get today => 'today';

  @override
  String get tomorrow => 'tomorrow';

  @override
  String inDays(Object count) {
    return 'in $count days';
  }

  @override
  String get away => 'Away';

  @override
  String awayUntil(Object date) {
    return 'Away until $date';
  }

  @override
  String get account => 'Account';

  @override
  String get username => 'Username';

  @override
  String get emailLabel => 'Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System default';

  @override
  String get aboutTaskFlow => 'About TaskFlow';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get logoutConfirmationTitle => 'Logout';

  @override
  String get logoutConfirmationText => 'Are you sure you want to logout?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get password => 'Password';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get fillDetails => 'Fill in the details below to get started';

  @override
  String get chooseUsername => 'Choose a username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get createPassword => 'Create a password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Groups';

  @override
  String get rewards => 'Rewards';

  @override
  String welcomeUser(Object username) {
    return 'Welcome, $username!';
  }

  @override
  String get homePlaceholder => 'Home Screen Placeholder';

  @override
  String get dashboard => 'Dashboard';

  @override
  String pageNotFound(Object uri) {
    return 'Page not found: $uri';
  }

  @override
  String get editProfileComingSoon => 'Edit profile — coming soon';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String get inviteLinkCopied => 'Invite link copied to clipboard';

  @override
  String get failedToLoadGroup => 'Failed to load group';

  @override
  String get retry => 'Retry';

  @override
  String invitePeopleToGroup(Object groupName) {
    return 'Invite people to $groupName';
  }

  @override
  String get inviteLink => 'Invite Link';

  @override
  String get inviteToken => 'Invite Token';

  @override
  String get tokenCopied => 'Token copied to clipboard';

  @override
  String get shareInviteLink => 'Share Invite Link';

  @override
  String get copyInviteLink => 'Copy Invite Link';

  @override
  String get inviteLinkNeverExpires =>
      'This invite link never expires. You can regenerate it from group settings if needed.';

  @override
  String get taskApproval => 'Task Approval';

  @override
  String get youLabel => 'You';

  @override
  String groupMembersCount(Object count) {
    return 'Group Members ($count)';
  }

  @override
  String joinedAt(Object date) {
    return 'Joined $date';
  }

  @override
  String get makeMember => 'Make Member';

  @override
  String get makeAdmin => 'Make Admin';

  @override
  String get removeFromGroup => 'Remove from group';

  @override
  String get useSettingsIconInAppBar => 'Use the Settings icon in the app bar';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get removeMemberTitle => 'Remove Member';

  @override
  String removeMemberConfirm(Object username) {
    return 'Are you sure you want to remove $username from this group?';
  }

  @override
  String get memberRemovedSuccess => 'Member removed successfully';

  @override
  String get changeRoleTitle => 'Change Role';

  @override
  String changeRoleConfirm(Object newRole, Object username) {
    return 'Change $username\'s role to $newRole?';
  }

  @override
  String get change => 'Change';

  @override
  String roleChangedTo(Object newRole) {
    return 'Role changed to $newRole';
  }

  @override
  String joinedSuccessfully(Object groupName) {
    return 'Joined \"$groupName\" successfully!';
  }

  @override
  String get joinGroupTitle => 'Join Group';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get pleaseLoginToJoinGroup =>
      'Please login or register to join this group';

  @override
  String get joiningGroup => 'Joining group...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get failedToJoinGroup => 'Failed to join group';

  @override
  String get goToGroups => 'Go to Groups';

  @override
  String get successfullyJoined => 'Successfully joined!';

  @override
  String get redirectingToGroup => 'Redirecting to group...';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get members => 'Members';

  @override
  String get approval => 'Approval';

  @override
  String get removeLabel => 'Remove';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String invitePeopleToGroup_short(Object groupName) {
    return 'Invite $groupName';
  }

  @override
  String get regenerateInviteToken => 'Regenerate Invite Token';

  @override
  String get regenerateInviteTokenConfirm =>
      'This will invalidate the current invite link. Are you sure?';

  @override
  String get inviteTokenRegenerated => 'Invite token regenerated';

  @override
  String get groupSettingsTitle => 'Group Settings';

  @override
  String get failedToLoadGroupSettings => 'Failed to load group settings';

  @override
  String get save => 'Save';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get groupName => 'Group Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get configuration => 'Configuration';

  @override
  String get rotationType => 'Rotation Type';

  @override
  String get gamification => 'Gamification';

  @override
  String get enablePointsAndRewards => 'Enable points and rewards';

  @override
  String get requireApproval => 'Require Approval';

  @override
  String get memberManagement => 'Member Management';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get deleteGroupConfirm =>
      'This action cannot be undone. All tasks and data will be permanently deleted.';

  @override
  String get deleteGroupSuccess => 'Group deleted';

  @override
  String get groupNameRequired => 'Group name is required';

  @override
  String get adminMustApproveTasks => 'Admin must approve tasks';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get createGroup => 'Create Group';

  @override
  String get groupDetailsTitle => 'Group Details';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leave => 'Leave';

  @override
  String get invite => 'Invite';

  @override
  String get request => 'Request';

  @override
  String get claimTask => 'Claim Task';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get complete => 'Complete';

  @override
  String get filterByPriority => 'Filter by Priority';

  @override
  String get allPriorities => 'All Priorities';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get gamified => 'Gamified';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String taskPoints(Object points) {
    return '$points pts';
  }

  @override
  String get taskClaimedSuccessfully => 'Task claimed successfully';

  @override
  String markTaskCompleteConfirm(Object taskTitle) {
    return 'Mark \"$taskTitle\" as complete?';
  }

  @override
  String get taskCompletedAwaitingApproval =>
      'Task completed! Awaiting approval';

  @override
  String get description => 'Description';

  @override
  String get details => 'Details';

  @override
  String get noRewardsAvailable => 'No Rewards Available';

  @override
  String get rewardRequestComingSoon => 'Reward request feature coming soon!';

  @override
  String get noDataYet => 'No Data Yet';

  @override
  String get you => 'You';

  @override
  String pointsLabel(Object points) {
    return '$points pts';
  }

  @override
  String get pointsWord => 'points';

  @override
  String get leftGroupSuccessfully => 'Left group successfully';

  @override
  String get gamificationLabel => 'Gamification';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your filters or create a new task';

  @override
  String get checkBackLaterRewards => 'Check back later for new rewards';

  @override
  String get completeTasksLeaderboard =>
      'Complete tasks to appear on the leaderboard';

  @override
  String get requiresApproval => 'Requires Approval';

  @override
  String joinedDate(Object date) {
    return 'Joined $date';
  }

  @override
  String get groupCreatedSuccessfully => 'Group created successfully';

  @override
  String get enablePointsAndRewardsSystem => 'Enable points and rewards system';

  @override
  String get requireApprovalTitle => 'Require Approval';

  @override
  String get adminMustApproveCompletedTasks =>
      'Admin must approve completed tasks';

  @override
  String get allTab => 'All';

  @override
  String get myTasksTab => 'My Tasks';

  @override
  String get availableTab => 'Available';

  @override
  String get reviewTab => 'Review';

  @override
  String get searchTasks => 'Search tasks...';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusAwaitingApproval => 'Awaiting Approval';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusPending => 'Pending';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get statusLabel => 'Status';

  @override
  String get pointsLabelDetail => 'Points';

  @override
  String get deadlineLabel => 'Deadline';

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get requiresApprovalLabel => 'Requires Approval';

  @override
  String get taskDetailsTitle => 'Task Details';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskConfirmTitle => 'Delete Task';

  @override
  String get deleteTaskConfirmMessage =>
      'Are you sure you want to delete this task?';

  @override
  String get executor => 'Executor';

  @override
  String get upForGrabs => 'Up-for-Grabs';

  @override
  String get reward => 'Reward';

  @override
  String get pts => 'pts';

  @override
  String get bonusPoints => '+50% bonus';

  @override
  String get requestRewardTitle => 'Request Reward';

  @override
  String requestRewardMessage(Object rewardName, Object points) {
    return 'Would you like to request \"$rewardName\" for $points points?';
  }

  @override
  String get rewardRequestedSuccess =>
      'Reward requested successfully! Awaiting approval.';

  @override
  String insufficientPoints(Object required, Object available) {
    return 'Insufficient points. You need $required points but only have $available.';
  }

  @override
  String get availableBalance => 'Available Balance';

  @override
  String yourBalance(Object points) {
    return 'Your balance: $points pts';
  }

  @override
  String get createdBy => 'Created By';

  @override
  String get rejectionReason => 'Rejection Reason';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get rejectTaskTitle => 'Reject Task';

  @override
  String get rejectionReasonHint => 'Enter reason for rejection';

  @override
  String get errorLoadingTask => 'Error loading task';

  @override
  String get createTask => 'Create Task';

  @override
  String get updateTask => 'Update Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get enterTaskTitle => 'Enter task title';

  @override
  String get enterTitleValidation => 'Please enter a task title';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get enterTaskDescription => 'Enter task description';

  @override
  String get tapToSelectDeadline => 'Tap to select deadline';

  @override
  String get priority => 'Priority';

  @override
  String get enterPointValue => 'Enter point value';

  @override
  String get enterPointValueValidation => 'Please enter point value';

  @override
  String get pointsRangeValidation => 'Points must be between 1 and 1000';

  @override
  String get requiresApprovalTitle => 'Requires Approval';

  @override
  String get requiresApprovalSubtitle =>
      'Task must be approved by admin after completion';

  @override
  String get taskCreatedSuccessfully => 'Task created successfully';

  @override
  String get groupTasksTab => 'Group Tasks';

  @override
  String get upForGrabsTab => 'Up-for-Grabs';

  @override
  String get pendingApprovalTab => 'Pending Approval';

  @override
  String get noTasksAssigned => 'No tasks assigned to you';

  @override
  String get tasksWillAppearHere => 'Tasks will appear here';

  @override
  String get selectGroup => 'Select a group';

  @override
  String get viewGroupTasksFromGroupsTab =>
      'View group tasks from the Groups tab';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String get noTasksPendingApproval => 'No tasks pending approval';

  @override
  String get errorLoadingTasks => 'Error loading tasks';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPendingReview => 'Pending Review';

  @override
  String daysLeft(Object count) {
    return '${count}d left';
  }

  @override
  String hoursLeft(Object count) {
    return '${count}h left';
  }

  @override
  String minutesLeft(Object count) {
    return '${count}m left';
  }

  @override
  String daysOverdue(Object count) {
    return '${count}d overdue';
  }

  @override
  String hoursOverdue(Object count) {
    return '${count}h overdue';
  }

  @override
  String minutesOverdue(Object count) {
    return '${count}m overdue';
  }

  @override
  String get tasksAssigned => 'Tasks Assigned';

  @override
  String get tasksCompletedLabel => 'Tasks Completed';

  @override
  String get pointsBalance => 'Points Balance';

  @override
  String get completionRateLabel => 'Completion Rate';

  @override
  String get upcomingTasks => 'Upcoming Tasks';

  @override
  String get dueTasks => 'Due Tasks';

  @override
  String get overdueTasks => 'Overdue Tasks';

  @override
  String get pendingApprovalTasks => 'Pending Approval';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get allGroups => 'All Groups';

  @override
  String get filterByGroup => 'Filter by Group';

  @override
  String get tasksDueToday => 'Tasks Due Today';

  @override
  String get noTasksDueToday => 'No tasks due today';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get nextWeek => 'Next Week';

  @override
  String get selectDate => 'Select Date';

  @override
  String tasksForDate(Object date) {
    return 'Tasks for $date';
  }

  @override
  String get rotationTypeLabel => 'Rotation Type';

  @override
  String get rotationTypeRoundRobin => 'Round Robin';

  @override
  String get rotationTypeRandom => 'Random';

  @override
  String get rotationTypeLoadBalancing => 'Load Balancing';

  @override
  String get rotationTypeDisabled => 'Disabled (Manual)';

  @override
  String get pleaseSelectDeadline => 'Please select a deadline';

  @override
  String get pointsHistory => 'Points History';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get reservedPending => 'Reserved (Pending)';

  @override
  String get availablePoints => 'Available Points';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactionsYet => 'No Transactions Yet';

  @override
  String get startCompletingTasks => 'Start completing tasks to earn points';

  @override
  String get earned => 'Earned';

  @override
  String get spent => 'Spent';

  @override
  String get taskCompleted => 'Task Completed';

  @override
  String get rewardRequested => 'Reward Requested';

  @override
  String get adminRewardsManagement => 'Rewards Management (Admin)';

  @override
  String get createReward => 'Create Reward';

  @override
  String get editReward => 'Edit Reward';

  @override
  String get deleteReward => 'Delete Reward';

  @override
  String get rewardName => 'Reward Name';

  @override
  String get rewardDescription => 'Description (Optional)';

  @override
  String get rewardCost => 'Cost (in points)';

  @override
  String get rewardImageUrl => 'Image URL (Optional)';

  @override
  String get enterRewardName => 'Enter reward name';

  @override
  String get enterRewardDescription => 'Describe the reward...';

  @override
  String get enterRewardCost => 'Enter cost in points';

  @override
  String get enterImageUrl => 'Enter image URL';

  @override
  String get rewardNameRequired => 'Reward name is required';

  @override
  String get rewardNameMinLength => 'Name must be at least 3 characters';

  @override
  String get rewardCostRequired => 'Cost is required';

  @override
  String get rewardCostMustBePositive => 'Cost must be a positive number';

  @override
  String get rewardCreatedSuccess => 'Reward created successfully!';

  @override
  String get rewardUpdatedSuccess => 'Reward updated successfully!';

  @override
  String get rewardDeletedSuccess => 'Reward deleted successfully!';

  @override
  String get confirmDeleteReward =>
      'Are you sure you want to delete this reward?';

  @override
  String get confirmDeleteRewardMessage =>
      'This action cannot be undone. Users who requested this reward will keep their requests.';

  @override
  String get rewardRequestsQueue => 'Reward Requests (Admin)';

  @override
  String get noPendingRequests => 'No Pending Requests';

  @override
  String get noRequestsDescription => 'All reward requests have been processed';

  @override
  String get approveRequest => 'Approve';

  @override
  String get rejectRequest => 'Reject';

  @override
  String get requestedBy => 'Requested by';

  @override
  String get requestedAt => 'Requested at';

  @override
  String get pointsWillBeDeducted => 'Points will be deducted';

  @override
  String get pointsWillBeReturned => 'Points will be returned';

  @override
  String get confirmApprove => 'Approve Request';

  @override
  String get confirmReject => 'Reject Request';

  @override
  String approveRequestMessage(Object points) {
    return 'Approve this reward request? $points points will be deducted from the user.';
  }

  @override
  String rejectRequestMessage(Object points) {
    return 'Reject this reward request? $points points will be returned to the user.';
  }

  @override
  String get requestApprovedSuccess =>
      'Request approved! Points deducted from user.';

  @override
  String get requestRejectedSuccess =>
      'Request rejected. Points returned to user.';

  @override
  String get statusReserved => 'Awaiting Approval';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get manageRewards => 'Manage Rewards';

  @override
  String get viewRequests => 'View Requests';

  @override
  String get insufficientPointsShort => 'Not enough';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Error';

  @override
  String get networkError =>
      'No internet connection. Please check your network settings.';

  @override
  String get timeoutError => 'Request timeout. Please try again.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get authError => 'Authentication failed. Please log in again.';

  @override
  String get validationError => 'Invalid data. Please check your input.';

  @override
  String get notFoundError => 'Resource not found.';

  @override
  String get permissionError => 'Permission denied.';

  @override
  String get unknownError => 'An unexpected error occurred. Please try again.';

  @override
  String get dismiss => 'Dismiss';
}
