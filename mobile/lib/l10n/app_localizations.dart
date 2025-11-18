import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TaskFlow'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get myTasks;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// Pluralized items count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} one{# item} few{# items} other{# items}}'**
  String itemsCount(num count);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @navigationProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfileLabel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @onTimeRate.
  ///
  /// In en, this message translates to:
  /// **'On-Time Rate'**
  String get onTimeRate;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @joinOrCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Join or create a group to get started'**
  String get joinOrCreateGroup;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get tomorrow;

  /// Relative days count
  ///
  /// In en, this message translates to:
  /// **'in {count} days'**
  String inDays(Object count);

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get away;

  /// Away until date
  ///
  /// In en, this message translates to:
  /// **'Away until {date}'**
  String awayUntil(Object date);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @aboutTaskFlow.
  ///
  /// In en, this message translates to:
  /// **'About TaskFlow'**
  String get aboutTaskFlow;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationText;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to get started'**
  String get fillDetails;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get chooseUsername;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// Welcome message with username
  ///
  /// In en, this message translates to:
  /// **'Welcome, {username}!'**
  String welcomeUser(Object username);

  /// No description provided for @homePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Placeholder'**
  String get homePlaceholder;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {uri}'**
  String pageNotFound(Object uri);

  /// No description provided for @editProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit profile — coming soon'**
  String get editProfileComingSoon;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied to clipboard'**
  String get inviteLinkCopied;

  /// No description provided for @failedToLoadGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to load group'**
  String get failedToLoadGroup;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @invitePeopleToGroup.
  ///
  /// In en, this message translates to:
  /// **'Invite people to {groupName}'**
  String invitePeopleToGroup(Object groupName);

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get inviteLink;

  /// No description provided for @inviteToken.
  ///
  /// In en, this message translates to:
  /// **'Invite Token'**
  String get inviteToken;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get tokenCopied;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @copyInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get copyInviteLink;

  /// No description provided for @inviteLinkNeverExpires.
  ///
  /// In en, this message translates to:
  /// **'This invite link never expires. You can regenerate it from group settings if needed.'**
  String get inviteLinkNeverExpires;

  /// No description provided for @taskApproval.
  ///
  /// In en, this message translates to:
  /// **'Task Approval'**
  String get taskApproval;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @groupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'Group Members ({count})'**
  String groupMembersCount(Object count);

  /// No description provided for @joinedAt.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedAt(Object date);

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make Member'**
  String get makeMember;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// No description provided for @removeFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get removeFromGroup;

  /// No description provided for @useSettingsIconInAppBar.
  ///
  /// In en, this message translates to:
  /// **'Use the Settings icon in the app bar'**
  String get useSettingsIconInAppBar;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {username} from this group?'**
  String removeMemberConfirm(Object username);

  /// No description provided for @memberRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get memberRemovedSuccess;

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRoleTitle;

  /// No description provided for @changeRoleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change {username}\'s role to {newRole}?'**
  String changeRoleConfirm(Object newRole, Object username);

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @roleChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Role changed to {newRole}'**
  String roleChangedTo(Object newRole);

  /// No description provided for @joinedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Joined \"{groupName}\" successfully!'**
  String joinedSuccessfully(Object groupName);

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroupTitle;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @pleaseLoginToJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Please login or register to join this group'**
  String get pleaseLoginToJoinGroup;

  /// No description provided for @joiningGroup.
  ///
  /// In en, this message translates to:
  /// **'Joining group...'**
  String get joiningGroup;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @failedToJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to join group'**
  String get failedToJoinGroup;

  /// No description provided for @goToGroups.
  ///
  /// In en, this message translates to:
  /// **'Go to Groups'**
  String get goToGroups;

  /// No description provided for @successfullyJoined.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined!'**
  String get successfullyJoined;

  /// No description provided for @redirectingToGroup.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to group...'**
  String get redirectingToGroup;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get approval;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @invitePeopleToGroup_short.
  ///
  /// In en, this message translates to:
  /// **'Invite {groupName}'**
  String invitePeopleToGroup_short(Object groupName);

  /// No description provided for @regenerateInviteToken.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Invite Token'**
  String get regenerateInviteToken;

  /// No description provided for @regenerateInviteTokenConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will invalidate the current invite link. Are you sure?'**
  String get regenerateInviteTokenConfirm;

  /// No description provided for @inviteTokenRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Invite token regenerated'**
  String get inviteTokenRegenerated;

  /// No description provided for @groupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupSettingsTitle;

  /// No description provided for @failedToLoadGroupSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load group settings'**
  String get failedToLoadGroupSettings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @rotationType.
  ///
  /// In en, this message translates to:
  /// **'Rotation Type'**
  String get rotationType;

  /// No description provided for @gamification.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get gamification;

  /// No description provided for @enablePointsAndRewards.
  ///
  /// In en, this message translates to:
  /// **'Enable points and rewards'**
  String get enablePointsAndRewards;

  /// No description provided for @requireApproval.
  ///
  /// In en, this message translates to:
  /// **'Require Approval'**
  String get requireApproval;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get memberManagement;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All tasks and data will be permanently deleted.'**
  String get deleteGroupConfirm;

  /// No description provided for @deleteGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get deleteGroupSuccess;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name is required'**
  String get groupNameRequired;

  /// No description provided for @adminMustApproveTasks.
  ///
  /// In en, this message translates to:
  /// **'Admin must approve tasks'**
  String get adminMustApproveTasks;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @groupDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Details'**
  String get groupDetailsTitle;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @claimTask.
  ///
  /// In en, this message translates to:
  /// **'Claim Task'**
  String get claimTask;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @filterByPriority.
  ///
  /// In en, this message translates to:
  /// **'Filter by Priority'**
  String get filterByPriority;

  /// No description provided for @allPriorities.
  ///
  /// In en, this message translates to:
  /// **'All Priorities'**
  String get allPriorities;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @gamified.
  ///
  /// In en, this message translates to:
  /// **'Gamified'**
  String get gamified;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// Task points display
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String taskPoints(Object points);

  /// No description provided for @taskClaimedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task claimed successfully'**
  String get taskClaimedSuccessfully;

  /// Confirm task completion dialog
  ///
  /// In en, this message translates to:
  /// **'Mark \"{taskTitle}\" as complete?'**
  String markTaskCompleteConfirm(Object taskTitle);

  /// No description provided for @taskCompletedAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Task completed! Awaiting approval'**
  String get taskCompletedAwaitingApproval;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @noRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Rewards Available'**
  String get noRewardsAvailable;

  /// No description provided for @rewardRequestComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reward request feature coming soon!'**
  String get rewardRequestComingSoon;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get noDataYet;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Points display in leaderboard
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsLabel(Object points);

  /// No description provided for @pointsWord.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsWord;

  /// No description provided for @leftGroupSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Left group successfully'**
  String get leftGroupSuccessfully;

  /// No description provided for @gamificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get gamificationLabel;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or create a new task'**
  String get tryAdjustingFilters;

  /// No description provided for @checkBackLaterRewards.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new rewards'**
  String get checkBackLaterRewards;

  /// No description provided for @completeTasksLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Complete tasks to appear on the leaderboard'**
  String get completeTasksLeaderboard;

  /// No description provided for @requiresApproval.
  ///
  /// In en, this message translates to:
  /// **'Requires Approval'**
  String get requiresApproval;

  /// Member joined date
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedDate(Object date);

  /// No description provided for @groupCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully'**
  String get groupCreatedSuccessfully;

  /// No description provided for @enablePointsAndRewardsSystem.
  ///
  /// In en, this message translates to:
  /// **'Enable points and rewards system'**
  String get enablePointsAndRewardsSystem;

  /// No description provided for @requireApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Require Approval'**
  String get requireApprovalTitle;

  /// No description provided for @adminMustApproveCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Admin must approve completed tasks'**
  String get adminMustApproveCompletedTasks;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @myTasksTab.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTab;

  /// No description provided for @availableTab.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableTab;

  /// No description provided for @reviewTab.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTab;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get statusAwaitingApproval;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @pointsLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabelDetail;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @requiresApprovalLabel.
  ///
  /// In en, this message translates to:
  /// **'Requires Approval'**
  String get requiresApprovalLabel;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetailsTitle;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTaskConfirmTitle;

  /// No description provided for @deleteTaskConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirmMessage;

  /// No description provided for @executor.
  ///
  /// In en, this message translates to:
  /// **'Executor'**
  String get executor;

  /// No description provided for @upForGrabs.
  ///
  /// In en, this message translates to:
  /// **'Up-for-Grabs'**
  String get upForGrabs;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @pts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pts;

  /// No description provided for @bonusPoints.
  ///
  /// In en, this message translates to:
  /// **'+50% bonus'**
  String get bonusPoints;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get createdBy;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @rejectTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Task'**
  String get rejectTaskTitle;

  /// No description provided for @rejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection'**
  String get rejectionReasonHint;

  /// No description provided for @errorLoadingTask.
  ///
  /// In en, this message translates to:
  /// **'Error loading task'**
  String get errorLoadingTask;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @updateTask.
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @enterTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get enterTaskTitle;

  /// No description provided for @enterTitleValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task title'**
  String get enterTitleValidation;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @enterTaskDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter task description'**
  String get enterTaskDescription;

  /// No description provided for @tapToSelectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Tap to select deadline'**
  String get tapToSelectDeadline;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @enterPointValue.
  ///
  /// In en, this message translates to:
  /// **'Enter point value'**
  String get enterPointValue;

  /// No description provided for @enterPointValueValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter point value'**
  String get enterPointValueValidation;

  /// No description provided for @pointsRangeValidation.
  ///
  /// In en, this message translates to:
  /// **'Points must be between 1 and 1000'**
  String get pointsRangeValidation;

  /// No description provided for @requiresApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Requires Approval'**
  String get requiresApprovalTitle;

  /// No description provided for @requiresApprovalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Task must be approved by admin after completion'**
  String get requiresApprovalSubtitle;

  /// No description provided for @taskCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task created successfully'**
  String get taskCreatedSuccessfully;

  /// No description provided for @groupTasksTab.
  ///
  /// In en, this message translates to:
  /// **'Group Tasks'**
  String get groupTasksTab;

  /// No description provided for @upForGrabsTab.
  ///
  /// In en, this message translates to:
  /// **'Up-for-Grabs'**
  String get upForGrabsTab;

  /// No description provided for @pendingApprovalTab.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApprovalTab;

  /// No description provided for @noTasksAssigned.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned to you'**
  String get noTasksAssigned;

  /// No description provided for @tasksWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Tasks will appear here'**
  String get tasksWillAppearHere;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select a group'**
  String get selectGroup;

  /// No description provided for @viewGroupTasksFromGroupsTab.
  ///
  /// In en, this message translates to:
  /// **'View group tasks from the Groups tab'**
  String get viewGroupTasksFromGroupsTab;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @noTasksPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'No tasks pending approval'**
  String get noTasksPendingApproval;

  /// No description provided for @errorLoadingTasks.
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks'**
  String get errorLoadingTasks;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get statusPendingReview;

  /// Days left countdown
  ///
  /// In en, this message translates to:
  /// **'{count}d left'**
  String daysLeft(Object count);

  /// Hours left countdown
  ///
  /// In en, this message translates to:
  /// **'{count}h left'**
  String hoursLeft(Object count);

  /// Minutes left countdown
  ///
  /// In en, this message translates to:
  /// **'{count}m left'**
  String minutesLeft(Object count);

  /// Days overdue
  ///
  /// In en, this message translates to:
  /// **'{count}d overdue'**
  String daysOverdue(Object count);

  /// Hours overdue
  ///
  /// In en, this message translates to:
  /// **'{count}h overdue'**
  String hoursOverdue(Object count);

  /// Minutes overdue
  ///
  /// In en, this message translates to:
  /// **'{count}m overdue'**
  String minutesOverdue(Object count);

  /// No description provided for @tasksAssigned.
  ///
  /// In en, this message translates to:
  /// **'Tasks Assigned'**
  String get tasksAssigned;

  /// No description provided for @tasksCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompletedLabel;

  /// No description provided for @pointsBalance.
  ///
  /// In en, this message translates to:
  /// **'Points Balance'**
  String get pointsBalance;

  /// No description provided for @completionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRateLabel;

  /// No description provided for @upcomingTasks.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tasks'**
  String get upcomingTasks;

  /// No description provided for @dueTasks.
  ///
  /// In en, this message translates to:
  /// **'Due Tasks'**
  String get dueTasks;

  /// No description provided for @overdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue Tasks'**
  String get overdueTasks;

  /// No description provided for @pendingApprovalTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApprovalTasks;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All Groups'**
  String get allGroups;

  /// No description provided for @filterByGroup.
  ///
  /// In en, this message translates to:
  /// **'Filter by Group'**
  String get filterByGroup;

  /// No description provided for @tasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks Due Today'**
  String get tasksDueToday;

  /// No description provided for @noTasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks due today'**
  String get noTasksDueToday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get nextWeek;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Tasks for specific date
  ///
  /// In en, this message translates to:
  /// **'Tasks for {date}'**
  String tasksForDate(Object date);

  /// No description provided for @rotationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotation Type'**
  String get rotationTypeLabel;

  /// No description provided for @rotationTypeRoundRobin.
  ///
  /// In en, this message translates to:
  /// **'Round Robin'**
  String get rotationTypeRoundRobin;

  /// No description provided for @rotationTypeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get rotationTypeRandom;

  /// No description provided for @rotationTypeLoadBalancing.
  ///
  /// In en, this message translates to:
  /// **'Load Balancing'**
  String get rotationTypeLoadBalancing;

  /// No description provided for @rotationTypeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled (Manual)'**
  String get rotationTypeDisabled;

  /// No description provided for @pleaseSelectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Please select a deadline'**
  String get pleaseSelectDeadline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
