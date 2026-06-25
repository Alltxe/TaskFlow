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

  /// No description provided for @welcomeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeScreenTitle;

  /// No description provided for @welcomeScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to get started'**
  String get welcomeScreenSubtitle;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get welcomeCreateAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Recovery'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendResetCode;

  /// Subtitle after code is sent
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email}'**
  String resetCodeSentSubtitle(String email);

  /// No description provided for @resetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetCodeLabel;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordTitle;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get setNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully. Please log in.'**
  String get passwordResetSuccess;

  /// No description provided for @invalidResetCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset code'**
  String get invalidResetCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

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

  /// No description provided for @templateAnchorDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring deadline interval'**
  String get templateAnchorDeadlineLabel;

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

  /// No description provided for @requestRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Reward'**
  String get requestRewardTitle;

  /// Confirm reward request dialog
  ///
  /// In en, this message translates to:
  /// **'Would you like to request \"{rewardName}\" for {points} points?'**
  String requestRewardMessage(Object rewardName, Object points);

  /// No description provided for @rewardRequestedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reward requested successfully! Awaiting approval.'**
  String get rewardRequestedSuccess;

  /// Error when user doesn't have enough points
  ///
  /// In en, this message translates to:
  /// **'Insufficient points. You need {required} points but only have {available}.'**
  String insufficientPoints(Object required, Object available);

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// User's current point balance
  ///
  /// In en, this message translates to:
  /// **'Your balance: {points} pts'**
  String yourBalance(Object points);

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

  /// No description provided for @recurringTemplatesTab.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get recurringTemplatesTab;

  /// No description provided for @noRecurringTemplates.
  ///
  /// In en, this message translates to:
  /// **'No recurring templates yet'**
  String get noRecurringTemplates;

  /// No description provided for @recurringTemplatesInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'How templates work'**
  String get recurringTemplatesInfoTitle;

  /// No description provided for @recurringTemplatesInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Templates are not executable tasks. They automatically create regular tasks on a schedule. Each generated task uses a relative deadline interval (for example, 1 day or 1 week).'**
  String get recurringTemplatesInfoBody;

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

  /// No description provided for @rotationTypesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Task assignment modes'**
  String get rotationTypesHelpTitle;

  /// No description provided for @rotationTypesHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Defines how new tasks without a selected assignee are distributed.'**
  String get rotationTypesHelpIntro;

  /// No description provided for @rotationTypeHelpRoundRobin.
  ///
  /// In en, this message translates to:
  /// **'Tasks rotate in order: each next member gets a task after the previous one. Members on leave are skipped.'**
  String get rotationTypeHelpRoundRobin;

  /// No description provided for @rotationTypeHelpRandom.
  ///
  /// In en, this message translates to:
  /// **'A random available group member is assigned each time.'**
  String get rotationTypeHelpRandom;

  /// No description provided for @rotationTypeHelpWeightedRandom.
  ///
  /// In en, this message translates to:
  /// **'Random selection weighted by workload: members with fewer active tasks are picked more often.'**
  String get rotationTypeHelpWeightedRandom;

  /// No description provided for @rotationTypeHelpLoadBalancing.
  ///
  /// In en, this message translates to:
  /// **'Uses task difficulty from completed work. The next task goes to whoever has the lowest accumulated load. You can set difficulty when creating a task.'**
  String get rotationTypeHelpLoadBalancing;

  /// No description provided for @rotationTypeHelpDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-assignment is off. Tasks go to the shared pool until someone claims them manually.'**
  String get rotationTypeHelpDisabled;

  /// No description provided for @pleaseSelectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Please select a deadline'**
  String get pleaseSelectDeadline;

  /// No description provided for @recurrenceTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring template'**
  String get recurrenceTemplateLabel;

  /// No description provided for @recurrenceTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically create tasks on a schedule'**
  String get recurrenceTemplateSubtitle;

  /// No description provided for @recurringTemplateChip.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get recurringTemplateChip;

  /// No description provided for @templateAnchorDeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'For templates, this sets the relative deadline interval for generated tasks'**
  String get templateAnchorDeadlineHint;

  /// No description provided for @templateAnchorDeadlineShortHint.
  ///
  /// In en, this message translates to:
  /// **'Generated tasks use configured deadline interval'**
  String get templateAnchorDeadlineShortHint;

  /// No description provided for @recurringDeadlineAutoHint.
  ///
  /// In en, this message translates to:
  /// **'For recurring templates, choose a relative deadline interval (day/week/month)'**
  String get recurringDeadlineAutoHint;

  /// No description provided for @recurringDeadlineSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline for each generated task'**
  String get recurringDeadlineSelectorLabel;

  /// No description provided for @recurringDeadlineIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get recurringDeadlineIntervalLabel;

  /// No description provided for @recurringDeadlineUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get recurringDeadlineUnitLabel;

  /// No description provided for @recurringDeadlineUnitDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get recurringDeadlineUnitDay;

  /// No description provided for @recurringDeadlineUnitWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get recurringDeadlineUnitWeek;

  /// No description provided for @recurringDeadlineUnitMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get recurringDeadlineUnitMonth;

  /// No description provided for @recurringDeadlineSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 1 week means each generated task is due one week after creation'**
  String get recurringDeadlineSelectorHint;

  /// No description provided for @recurrenceFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurrenceFrequencyLabel;

  /// No description provided for @recurrenceFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceFrequencyDaily;

  /// No description provided for @recurrenceFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceFrequencyWeekly;

  /// No description provided for @recurrenceFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceFrequencyMonthly;

  /// No description provided for @recurrenceIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get recurrenceIntervalLabel;

  /// No description provided for @recurrenceEveryPeriod.
  ///
  /// In en, this message translates to:
  /// **'Every period'**
  String get recurrenceEveryPeriod;

  /// Recurrence interval label for N periods
  ///
  /// In en, this message translates to:
  /// **'Every {count} periods'**
  String recurrenceEveryNPeriods(Object count);

  /// No description provided for @recurrenceWeekdaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Week days'**
  String get recurrenceWeekdaysLabel;

  /// No description provided for @recurrenceSelectWeekday.
  ///
  /// In en, this message translates to:
  /// **'Select at least one weekday'**
  String get recurrenceSelectWeekday;

  /// Selected day of month for recurring monthly tasks
  ///
  /// In en, this message translates to:
  /// **'Day of month: {day}'**
  String recurrenceDayOfMonth(Object day);

  /// No description provided for @recurrenceEndsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get recurrenceEndsLabel;

  /// No description provided for @recurrenceEndNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recurrenceEndNever;

  /// No description provided for @recurrenceEndAfterCount.
  ///
  /// In en, this message translates to:
  /// **'After number of occurrences'**
  String get recurrenceEndAfterCount;

  /// No description provided for @recurrenceEndUntilDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get recurrenceEndUntilDate;

  /// No description provided for @recurrenceOccurrencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Occurrences'**
  String get recurrenceOccurrencesLabel;

  /// Recurrence occurrences count
  ///
  /// In en, this message translates to:
  /// **'{count} occurrences'**
  String recurrenceOccurrencesValue(Object count);

  /// No description provided for @recurrenceUntilDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Until date'**
  String get recurrenceUntilDateLabel;

  /// No description provided for @recurrenceSelectUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to select end date'**
  String get recurrenceSelectUntilDate;

  /// No description provided for @recurrenceRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurrence rule'**
  String get recurrenceRuleLabel;

  /// No description provided for @recurrenceRuleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please configure a valid recurrence rule'**
  String get recurrenceRuleInvalid;

  /// No description provided for @recurrenceRuleInvalidShort.
  ///
  /// In en, this message translates to:
  /// **'invalid'**
  String get recurrenceRuleInvalidShort;

  /// No description provided for @recurrenceSectionWhen.
  ///
  /// In en, this message translates to:
  /// **'How often to repeat'**
  String get recurrenceSectionWhen;

  /// No description provided for @recurrenceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get recurrenceSummaryTitle;

  /// No description provided for @recurrencePreviewTask.
  ///
  /// In en, this message translates to:
  /// **'Task {number}'**
  String recurrencePreviewTask(int number);

  /// No description provided for @recurrencePreviewAppears.
  ///
  /// In en, this message translates to:
  /// **'Appears: {date}'**
  String recurrencePreviewAppears(Object date);

  /// No description provided for @recurrencePreviewAppearsImmediately.
  ///
  /// In en, this message translates to:
  /// **'Appears: right after you save'**
  String get recurrencePreviewAppearsImmediately;

  /// No description provided for @recurrencePreviewDeadline.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String recurrencePreviewDeadline(Object date);

  /// No description provided for @recurrencePreviewMoreTasks.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String recurrencePreviewMoreTasks(int count);

  /// No description provided for @recurrencePreviewRepeatsForever.
  ///
  /// In en, this message translates to:
  /// **'More tasks will follow the same schedule'**
  String get recurrencePreviewRepeatsForever;

  /// No description provided for @recurrenceTestRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Test recurrence rule (debug only)'**
  String get recurrenceTestRuleLabel;

  /// No description provided for @recurrenceTestRuleHint.
  ///
  /// In en, this message translates to:
  /// **'For developers'**
  String get recurrenceTestRuleHint;

  /// No description provided for @recurrenceTestRuleDescription.
  ///
  /// In en, this message translates to:
  /// **'If filled, overrides the visual editor settings. For testing only.'**
  String get recurrenceTestRuleDescription;

  /// No description provided for @recurrenceTestRuleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid test recurrence rule'**
  String get recurrenceTestRuleInvalid;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @pointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Points History'**
  String get pointsHistory;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @reservedPending.
  ///
  /// In en, this message translates to:
  /// **'Reserved (Pending)'**
  String get reservedPending;

  /// No description provided for @availablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available Points'**
  String get availablePoints;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactionsYet;

  /// No description provided for @startCompletingTasks.
  ///
  /// In en, this message translates to:
  /// **'Start completing tasks to earn points'**
  String get startCompletingTasks;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task Completed'**
  String get taskCompleted;

  /// No description provided for @rewardRequested.
  ///
  /// In en, this message translates to:
  /// **'Reward Requested'**
  String get rewardRequested;

  /// No description provided for @adminRewardsManagement.
  ///
  /// In en, this message translates to:
  /// **'Rewards Management (Admin)'**
  String get adminRewardsManagement;

  /// No description provided for @createReward.
  ///
  /// In en, this message translates to:
  /// **'Create Reward'**
  String get createReward;

  /// No description provided for @editReward.
  ///
  /// In en, this message translates to:
  /// **'Edit Reward'**
  String get editReward;

  /// No description provided for @deleteReward.
  ///
  /// In en, this message translates to:
  /// **'Delete Reward'**
  String get deleteReward;

  /// No description provided for @rewardName.
  ///
  /// In en, this message translates to:
  /// **'Reward Name'**
  String get rewardName;

  /// No description provided for @rewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get rewardDescription;

  /// No description provided for @rewardCost.
  ///
  /// In en, this message translates to:
  /// **'Cost (in points)'**
  String get rewardCost;

  /// No description provided for @rewardImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL (Optional)'**
  String get rewardImageUrl;

  /// No description provided for @enterRewardName.
  ///
  /// In en, this message translates to:
  /// **'Enter reward name'**
  String get enterRewardName;

  /// No description provided for @enterRewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the reward...'**
  String get enterRewardDescription;

  /// No description provided for @enterRewardCost.
  ///
  /// In en, this message translates to:
  /// **'Enter cost in points'**
  String get enterRewardCost;

  /// No description provided for @enterImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter image URL'**
  String get enterImageUrl;

  /// No description provided for @rewardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Reward name is required'**
  String get rewardNameRequired;

  /// No description provided for @rewardNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get rewardNameMinLength;

  /// No description provided for @rewardCostRequired.
  ///
  /// In en, this message translates to:
  /// **'Cost is required'**
  String get rewardCostRequired;

  /// No description provided for @rewardCostMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Cost must be a positive number'**
  String get rewardCostMustBePositive;

  /// No description provided for @rewardCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reward created successfully!'**
  String get rewardCreatedSuccess;

  /// No description provided for @rewardUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reward updated successfully!'**
  String get rewardUpdatedSuccess;

  /// No description provided for @rewardDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reward deleted successfully!'**
  String get rewardDeletedSuccess;

  /// No description provided for @confirmDeleteReward.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reward?'**
  String get confirmDeleteReward;

  /// No description provided for @confirmDeleteRewardMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Users who requested this reward will keep their requests.'**
  String get confirmDeleteRewardMessage;

  /// No description provided for @rewardRequestsQueue.
  ///
  /// In en, this message translates to:
  /// **'Reward Requests (Admin)'**
  String get rewardRequestsQueue;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @noRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'All reward requests have been processed'**
  String get noRequestsDescription;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRequest;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @requestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested at'**
  String get requestedAt;

  /// No description provided for @pointsWillBeDeducted.
  ///
  /// In en, this message translates to:
  /// **'Points will be deducted'**
  String get pointsWillBeDeducted;

  /// No description provided for @pointsWillBeReturned.
  ///
  /// In en, this message translates to:
  /// **'Points will be returned'**
  String get pointsWillBeReturned;

  /// No description provided for @confirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve Request'**
  String get confirmApprove;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get confirmReject;

  /// Confirm approve reward request
  ///
  /// In en, this message translates to:
  /// **'Approve this reward request? {points} points will be deducted from the user.'**
  String approveRequestMessage(Object points);

  /// Confirm reject reward request
  ///
  /// In en, this message translates to:
  /// **'Reject this reward request? {points} points will be returned to the user.'**
  String rejectRequestMessage(Object points);

  /// No description provided for @requestApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request approved! Points deducted from user.'**
  String get requestApprovedSuccess;

  /// No description provided for @requestRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request rejected. Points returned to user.'**
  String get requestRejectedSuccess;

  /// No description provided for @statusReserved.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get statusReserved;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @manageRewards.
  ///
  /// In en, this message translates to:
  /// **'Manage Rewards'**
  String get manageRewards;

  /// No description provided for @viewRequests.
  ///
  /// In en, this message translates to:
  /// **'View Requests'**
  String get viewRequests;

  /// No description provided for @insufficientPointsShort.
  ///
  /// In en, this message translates to:
  /// **'Not enough'**
  String get insufficientPointsShort;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get timeoutError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please log in again.'**
  String get authError;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidCredentialsError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check your input.'**
  String get validationError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get notFoundError;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get permissionError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @confirmNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get confirmNewPasswordRequired;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get usernameHint;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @rotationTypeWeightedRandom.
  ///
  /// In en, this message translates to:
  /// **'Weighted Random'**
  String get rotationTypeWeightedRandom;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @memberStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get memberStatusActive;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get dateJustNow;

  /// No description provided for @dateMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String dateMinutesAgo(Object count);

  /// No description provided for @dateHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String dateHoursAgo(Object count);

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String dateDaysAgo(Object count);

  /// No description provided for @dateWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String dateWeeksAgo(Object count);

  /// No description provided for @dateMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String dateMonthsAgo(Object count);

  /// No description provided for @dateYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String dateYearsAgo(Object count);

  /// No description provided for @joinGroupByToken.
  ///
  /// In en, this message translates to:
  /// **'Join by Invite Code'**
  String get joinGroupByToken;

  /// No description provided for @enterInviteToken.
  ///
  /// In en, this message translates to:
  /// **'Enter invite token'**
  String get enterInviteToken;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @invalidInviteToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite token'**
  String get invalidInviteToken;

  /// No description provided for @groupPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Preview'**
  String get groupPreviewTitle;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCount(Object count);

  /// No description provided for @joinGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroupConfirm;

  /// No description provided for @joinOrCreateGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Create a new group or join one with an invite code'**
  String get joinOrCreateGroupHint;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Invite Code'**
  String get enterInviteCode;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupNameHint;

  /// No description provided for @groupNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Group name must be at least 3 characters'**
  String get groupNameMinLength;

  /// No description provided for @groupDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get groupDescriptionOptional;

  /// No description provided for @groupDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group description'**
  String get groupDescriptionHint;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignTo;

  /// No description provided for @autoByRotation.
  ///
  /// In en, this message translates to:
  /// **'Auto (by rotation)'**
  String get autoByRotation;

  /// No description provided for @upForGrabsBonus.
  ///
  /// In en, this message translates to:
  /// **'Up-for-Grabs (+50% bonus)'**
  String get upForGrabsBonus;

  /// No description provided for @useGroupDefault.
  ///
  /// In en, this message translates to:
  /// **'Use group default'**
  String get useGroupDefault;

  /// No description provided for @taskDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get taskDifficultyLabel;

  /// No description provided for @taskDifficultyHint.
  ///
  /// In en, this message translates to:
  /// **'How hard is this task? (1 = easy, 10 = very hard). Used to balance workload when load balancing rotation is enabled.'**
  String get taskDifficultyHint;

  /// No description provided for @roleParticipant.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get roleParticipant;

  /// No description provided for @auditLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLogTitle;

  /// No description provided for @groupAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Group Audit Log'**
  String get groupAuditLog;

  /// No description provided for @taskHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get taskHistory;

  /// No description provided for @myActions.
  ///
  /// In en, this message translates to:
  /// **'My Actions'**
  String get myActions;

  /// No description provided for @auditAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get auditAction;

  /// No description provided for @auditEntity.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get auditEntity;

  /// No description provided for @auditPerformedBy.
  ///
  /// In en, this message translates to:
  /// **'Performed by'**
  String get auditPerformedBy;

  /// No description provided for @auditPerformedAt.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get auditPerformedAt;

  /// No description provided for @noAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'No audit logs yet'**
  String get noAuditLogs;

  /// No description provided for @auditActionUserStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Status changed'**
  String get auditActionUserStatusChanged;

  /// No description provided for @auditActionUserProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get auditActionUserProfileUpdated;

  /// No description provided for @auditActionGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get auditActionGroupCreated;

  /// No description provided for @auditActionGroupUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group settings updated'**
  String get auditActionGroupUpdated;

  /// No description provided for @auditActionGroupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get auditActionGroupDeleted;

  /// No description provided for @auditActionMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member joined'**
  String get auditActionMemberAdded;

  /// No description provided for @auditActionMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get auditActionMemberRemoved;

  /// No description provided for @auditActionMemberRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed'**
  String get auditActionMemberRoleChanged;

  /// No description provided for @auditActionTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get auditActionTaskCreated;

  /// No description provided for @auditActionTaskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get auditActionTaskUpdated;

  /// No description provided for @auditActionTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get auditActionTaskDeleted;

  /// No description provided for @auditActionTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'Task assigned'**
  String get auditActionTaskAssigned;

  /// No description provided for @auditActionTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get auditActionTaskCompleted;

  /// No description provided for @auditActionTaskApproved.
  ///
  /// In en, this message translates to:
  /// **'Task approved'**
  String get auditActionTaskApproved;

  /// No description provided for @auditActionTaskRejected.
  ///
  /// In en, this message translates to:
  /// **'Task rejected'**
  String get auditActionTaskRejected;

  /// No description provided for @auditActionTaskOverdue.
  ///
  /// In en, this message translates to:
  /// **'Task overdue'**
  String get auditActionTaskOverdue;

  /// No description provided for @auditActionRewardCreated.
  ///
  /// In en, this message translates to:
  /// **'Reward created'**
  String get auditActionRewardCreated;

  /// No description provided for @auditActionRewardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reward updated'**
  String get auditActionRewardUpdated;

  /// No description provided for @auditActionRewardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reward deleted'**
  String get auditActionRewardDeleted;

  /// No description provided for @auditActionRewardRequested.
  ///
  /// In en, this message translates to:
  /// **'Reward requested'**
  String get auditActionRewardRequested;

  /// No description provided for @auditActionRewardRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Reward granted'**
  String get auditActionRewardRequestApproved;

  /// No description provided for @auditActionRewardRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Reward request rejected'**
  String get auditActionRewardRequestRejected;

  /// No description provided for @auditActionPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points earned'**
  String get auditActionPointsEarned;

  /// No description provided for @auditActionPointsReserved.
  ///
  /// In en, this message translates to:
  /// **'Points reserved'**
  String get auditActionPointsReserved;

  /// No description provided for @auditActionPointsSpent.
  ///
  /// In en, this message translates to:
  /// **'Points spent'**
  String get auditActionPointsSpent;

  /// No description provided for @auditActionPointsRefunded.
  ///
  /// In en, this message translates to:
  /// **'Points refunded'**
  String get auditActionPointsRefunded;

  /// No description provided for @auditActionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get auditActionUnknown;

  /// No description provided for @auditDetailTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'“{title}”'**
  String auditDetailTaskTitle(Object title);

  /// No description provided for @auditDetailTaskTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template “{title}”'**
  String auditDetailTaskTemplate(Object title);

  /// No description provided for @auditDetailGroupName.
  ///
  /// In en, this message translates to:
  /// **'“{name}”'**
  String auditDetailGroupName(Object name);

  /// No description provided for @auditDetailGroupRenamed.
  ///
  /// In en, this message translates to:
  /// **'“{oldName}” → “{newName}”'**
  String auditDetailGroupRenamed(Object oldName, Object newName);

  /// No description provided for @auditDetailRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'{oldRole} → {newRole}'**
  String auditDetailRoleChanged(Object oldRole, Object newRole);

  /// No description provided for @auditDetailPoints.
  ///
  /// In en, this message translates to:
  /// **'+{amount} points'**
  String auditDetailPoints(Object amount);

  /// No description provided for @auditDetailPointsWithDescription.
  ///
  /// In en, this message translates to:
  /// **'+{amount} points · {description}'**
  String auditDetailPointsWithDescription(Object amount, Object description);

  /// No description provided for @auditDetailPointsSpent.
  ///
  /// In en, this message translates to:
  /// **'−{amount} points'**
  String auditDetailPointsSpent(Object amount);

  /// No description provided for @auditDetailRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String auditDetailRejectionReason(Object reason);

  /// No description provided for @auditDetailTaskAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get auditDetailTaskAwaitingApproval;

  /// No description provided for @auditDetailMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined the group'**
  String get auditDetailMemberJoined;

  /// No description provided for @auditDetailMemberLeft.
  ///
  /// In en, this message translates to:
  /// **'Left the group'**
  String get auditDetailMemberLeft;

  /// No description provided for @auditDetailMemberRemovedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Removed from the group'**
  String get auditDetailMemberRemovedByAdmin;

  /// No description provided for @auditLogEntryMeta.
  ///
  /// In en, this message translates to:
  /// **'{user} · {date}'**
  String auditLogEntryMeta(Object user, Object date);

  /// No description provided for @auditLogInGroup.
  ///
  /// In en, this message translates to:
  /// **'Group \"{name}\"'**
  String auditLogInGroup(Object name);

  /// No description provided for @auditLogPersonalScope.
  ///
  /// In en, this message translates to:
  /// **'Personal account'**
  String get auditLogPersonalScope;

  /// No description provided for @auditLogSystemUser.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get auditLogSystemUser;

  /// No description provided for @auditDetailPointsTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'For completing a task'**
  String get auditDetailPointsTaskCompleted;

  /// No description provided for @auditDetailPointsTaskApproved.
  ///
  /// In en, this message translates to:
  /// **'For task approval'**
  String get auditDetailPointsTaskApproved;

  /// No description provided for @auditDetailPointsTaskCompletedBonus.
  ///
  /// In en, this message translates to:
  /// **'For completing a task (Up-for-Grabs bonus)'**
  String get auditDetailPointsTaskCompletedBonus;

  /// No description provided for @auditDetailPointsTaskApprovedBonus.
  ///
  /// In en, this message translates to:
  /// **'For task approval (Up-for-Grabs bonus)'**
  String get auditDetailPointsTaskApprovedBonus;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notificationsEmptyHint;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @notificationTypeTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'Task Assigned'**
  String get notificationTypeTaskAssigned;

  /// No description provided for @notificationTypeTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task Completed'**
  String get notificationTypeTaskCompleted;

  /// No description provided for @notificationTypeTaskApproved.
  ///
  /// In en, this message translates to:
  /// **'Task Approved'**
  String get notificationTypeTaskApproved;

  /// No description provided for @notificationTypeTaskRejected.
  ///
  /// In en, this message translates to:
  /// **'Task Rejected'**
  String get notificationTypeTaskRejected;

  /// No description provided for @notificationTypeRewardRequested.
  ///
  /// In en, this message translates to:
  /// **'Reward Requested'**
  String get notificationTypeRewardRequested;

  /// No description provided for @notificationTypeRewardApproved.
  ///
  /// In en, this message translates to:
  /// **'Reward Approved'**
  String get notificationTypeRewardApproved;

  /// No description provided for @notificationTypeRewardRejected.
  ///
  /// In en, this message translates to:
  /// **'Reward Rejected'**
  String get notificationTypeRewardRejected;

  /// No description provided for @notificationTypePointAwarded.
  ///
  /// In en, this message translates to:
  /// **'Points Awarded'**
  String get notificationTypePointAwarded;

  /// No description provided for @notificationTypeInvitation.
  ///
  /// In en, this message translates to:
  /// **'Group Invitation'**
  String get notificationTypeInvitation;

  /// No description provided for @notificationTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationTypeSystem;

  /// No description provided for @notificationTypeTaskClaimed.
  ///
  /// In en, this message translates to:
  /// **'Task claimed'**
  String get notificationTypeTaskClaimed;

  /// No description provided for @notificationTypeTaskPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Task pending review'**
  String get notificationTypeTaskPendingReview;

  /// No description provided for @notificationTypeRewardRequest.
  ///
  /// In en, this message translates to:
  /// **'Reward request'**
  String get notificationTypeRewardRequest;

  /// No description provided for @notificationMessageTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'You have been assigned: {title}'**
  String notificationMessageTaskAssigned(Object title);

  /// No description provided for @notificationMessageTaskClaimed.
  ///
  /// In en, this message translates to:
  /// **'You claimed: {title}'**
  String notificationMessageTaskClaimed(Object title);

  /// No description provided for @notificationMessageTaskAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Task \"{title}\" is awaiting approval'**
  String notificationMessageTaskAwaitingApproval(Object title);

  /// No description provided for @notificationMessageTaskApproved.
  ///
  /// In en, this message translates to:
  /// **'Your task \"{title}\" has been approved'**
  String notificationMessageTaskApproved(Object title);

  /// No description provided for @notificationMessageTaskRejected.
  ///
  /// In en, this message translates to:
  /// **'Your task \"{title}\" was rejected: {reason}'**
  String notificationMessageTaskRejected(Object title, Object reason);

  /// No description provided for @notificationMessagePointsEarnedCompletion.
  ///
  /// In en, this message translates to:
  /// **'You earned {points} points for completing \"{title}\"{bonus}'**
  String notificationMessagePointsEarnedCompletion(
    Object points,
    Object title,
    Object bonus,
  );

  /// No description provided for @notificationMessagePointsEarnedApproval.
  ///
  /// In en, this message translates to:
  /// **'You earned {points} points for \"{title}\" approval{bonus}'**
  String notificationMessagePointsEarnedApproval(
    Object points,
    Object title,
    Object bonus,
  );

  /// No description provided for @notificationMessageUpForGrabsBonus.
  ///
  /// In en, this message translates to:
  /// **' (Up-for-Grabs bonus!)'**
  String get notificationMessageUpForGrabsBonus;

  /// No description provided for @notificationMessageRewardRequested.
  ///
  /// In en, this message translates to:
  /// **'New reward request for \"{name}\"'**
  String notificationMessageRewardRequested(Object name);

  /// No description provided for @notificationMessageRewardApproved.
  ///
  /// In en, this message translates to:
  /// **'Your reward request for \"{name}\" has been approved'**
  String notificationMessageRewardApproved(Object name);

  /// No description provided for @notificationMessageRewardRejected.
  ///
  /// In en, this message translates to:
  /// **'Your reward request for \"{name}\" was rejected: {reason}'**
  String notificationMessageRewardRejected(Object name, Object reason);

  /// No description provided for @notificationMessageDeadline24h.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is due in 24 hours'**
  String notificationMessageDeadline24h(Object title);

  /// No description provided for @notificationMessageDeadline1h.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is due in 1 hour'**
  String notificationMessageDeadline1h(Object title);

  /// No description provided for @notificationNoReason.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get notificationNoReason;

  /// No description provided for @unreadOnly.
  ///
  /// In en, this message translates to:
  /// **'Unread only'**
  String get unreadOnly;

  /// No description provided for @rotationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Rotation Schedule'**
  String get rotationSchedule;

  /// No description provided for @rotationHistory.
  ///
  /// In en, this message translates to:
  /// **'Rotation History'**
  String get rotationHistory;

  /// No description provided for @rotationPattern.
  ///
  /// In en, this message translates to:
  /// **'Rotation Pattern'**
  String get rotationPattern;

  /// No description provided for @rotationScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Assignments'**
  String get rotationScheduleTitle;

  /// No description provided for @rotationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment History'**
  String get rotationHistoryTitle;

  /// No description provided for @rotationScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No upcoming assignments'**
  String get rotationScheduleEmpty;

  /// No description provided for @rotationHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No assignment history'**
  String get rotationHistoryEmpty;

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {date}'**
  String scheduledFor(Object date);

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String assignedTo(Object name);

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'{points} pts earned'**
  String pointsEarned(Object points);

  /// No description provided for @viewRotation.
  ///
  /// In en, this message translates to:
  /// **'View Rotation'**
  String get viewRotation;

  /// No description provided for @recurringTemplates.
  ///
  /// In en, this message translates to:
  /// **'Recurring Templates'**
  String get recurringTemplates;

  /// No description provided for @recurringTemplatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring task templates'**
  String get recurringTemplatesEmpty;

  /// No description provided for @generateNextTask.
  ///
  /// In en, this message translates to:
  /// **'Generate Next Task'**
  String get generateNextTask;

  /// No description provided for @generateNextTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Generate the next task instance from this template?'**
  String get generateNextTaskConfirm;

  /// No description provided for @taskGenerated.
  ///
  /// In en, this message translates to:
  /// **'Next task generated successfully'**
  String get taskGenerated;

  /// No description provided for @recurrenceRule.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Rule'**
  String get recurrenceRule;

  /// No description provided for @viewRecurringTemplates.
  ///
  /// In en, this message translates to:
  /// **'Recurring Templates'**
  String get viewRecurringTemplates;

  /// No description provided for @filterTasks.
  ///
  /// In en, this message translates to:
  /// **'Filter Tasks'**
  String get filterTasks;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAttachment;

  /// No description provided for @deleteAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment?'**
  String get deleteAttachmentTitle;

  /// No description provided for @deleteAttachmentMessage.
  ///
  /// In en, this message translates to:
  /// **'The file will be permanently deleted.'**
  String get deleteAttachmentMessage;

  /// No description provided for @attachmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Attachment added'**
  String get attachmentAdded;

  /// No description provided for @attachmentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Attachment deleted'**
  String get attachmentDeleted;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @mediaPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Media access permission denied'**
  String get mediaPermissionDenied;
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
