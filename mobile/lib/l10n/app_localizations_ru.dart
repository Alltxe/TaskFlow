// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TaskFlow';

  @override
  String get ok => 'ОК';

  @override
  String get cancel => 'Отмена';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get loading => 'Загрузка...';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get myTasks => 'Мои задачи';

  @override
  String get noTasks => 'Нет задач';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# элементов',
      many: '# элементов',
      few: '# элемента',
      one: '# элемент',
      zero: 'Нет элементов',
    );
    return '$_temp0';
  }

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get navigationProfileLabel => 'Профиль';

  @override
  String get logout => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get points => 'Очки';

  @override
  String get completed => 'Завершено';

  @override
  String get completionRate => 'Процент завершения';

  @override
  String get onTimeRate => 'Процент вовремя';

  @override
  String get myGroups => 'Мои группы';

  @override
  String get noGroupsYet => 'Пока нет групп';

  @override
  String get joinOrCreateGroup =>
      'Присоединитесь или создайте группу, чтобы начать';

  @override
  String get noDescription => 'Нет описания';

  @override
  String get today => 'сегодня';

  @override
  String get tomorrow => 'завтра';

  @override
  String inDays(Object count) {
    return 'через $count дней';
  }

  @override
  String get away => 'Отсутствует';

  @override
  String awayUntil(Object date) {
    return 'Отсутствует до $date';
  }

  @override
  String get account => 'Аккаунт';

  @override
  String get username => 'Имя пользователя';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get comingSoon => 'Скоро будет';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get vibration => 'Вибрация';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get systemDefault => 'По умолчанию';

  @override
  String get aboutTaskFlow => 'О TaskFlow';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get logoutConfirmationTitle => 'Выйти';

  @override
  String get logoutConfirmationText => 'Вы уверены, что хотите выйти?';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get enterYourEmail => 'Введите вашу почту';

  @override
  String get enterYourPassword => 'Введите ваш пароль';

  @override
  String get emailRequired => 'Почта обязательна';

  @override
  String get invalidEmailFormat => 'Неверный формат почты';

  @override
  String get passwordRequired => 'Пароль обязателен';

  @override
  String get passwordMinLength =>
      'Пароль должен содержать как минимум 8 символов';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get password => 'Пароль';

  @override
  String get createAccountTitle => 'Создать аккаунт';

  @override
  String get fillDetails => 'Заполните данные ниже, чтобы начать';

  @override
  String get chooseUsername => 'Придумайте имя пользователя';

  @override
  String get usernameRequired => 'Имя пользователя обязательно';

  @override
  String get usernameMinLength =>
      'Имя пользователя должно быть не меньше 3 символов';

  @override
  String get createPassword => 'Придумайте пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get confirmPasswordRequired => 'Пожалуйста, подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get home => 'Главная';

  @override
  String get groups => 'Группы';

  @override
  String get rewards => 'Награды';

  @override
  String welcomeUser(Object username) {
    return 'Добро пожаловать, $username!';
  }

  @override
  String get homePlaceholder => 'Заполнитель главного экрана';

  @override
  String get dashboard => 'Панель';

  @override
  String pageNotFound(Object uri) {
    return 'Страница не найдена: $uri';
  }

  @override
  String get editProfileComingSoon => 'Редактирование профиля — скоро будет';

  @override
  String get inviteMembers => 'Пригласить участников';

  @override
  String get inviteLinkCopied =>
      'Ссылка приглашения скопирована в буфер обмена';

  @override
  String get failedToLoadGroup => 'Не удалось загрузить группу';

  @override
  String get retry => 'Повторить';

  @override
  String invitePeopleToGroup(Object groupName) {
    return 'Пригласите людей в группу $groupName';
  }

  @override
  String get inviteLink => 'Ссылка приглашения';

  @override
  String get inviteToken => 'Токен приглашения';

  @override
  String get tokenCopied => 'Токен скопирован в буфер обмена';

  @override
  String get shareInviteLink => 'Поделиться ссылкой приглашения';

  @override
  String get copyInviteLink => 'Копировать ссылку приглашения';

  @override
  String get inviteLinkNeverExpires =>
      'Эта ссылка приглашения никогда не истекает. Вы можете сгенерировать новую в настройках группы при необходимости.';

  @override
  String get taskApproval => 'Утверждение задач';

  @override
  String get youLabel => 'Вы';

  @override
  String groupMembersCount(Object count) {
    return 'Участники группы ($count)';
  }

  @override
  String joinedAt(Object date) {
    return 'Присоединился $date';
  }

  @override
  String get makeMember => 'Сделать участником';

  @override
  String get makeAdmin => 'Сделать администратором';

  @override
  String get removeFromGroup => 'Удалить из группы';

  @override
  String get useSettingsIconInAppBar =>
      'Используйте значок настроек в панели приложения';

  @override
  String get goToSettings => 'Перейти к настройкам';

  @override
  String get removeMemberTitle => 'Удалить участника';

  @override
  String removeMemberConfirm(Object username) {
    return 'Вы уверены, что хотите удалить $username из этой группы?';
  }

  @override
  String get memberRemovedSuccess => 'Участник успешно удалён';

  @override
  String get changeRoleTitle => 'Изменить роль';

  @override
  String changeRoleConfirm(Object newRole, Object username) {
    return 'Изменить роль $username на $newRole?';
  }

  @override
  String get change => 'Изменить';

  @override
  String roleChangedTo(Object newRole) {
    return 'Роль изменена на $newRole';
  }

  @override
  String joinedSuccessfully(Object groupName) {
    return 'Успешно присоединились к \"$groupName\"!';
  }

  @override
  String get joinGroupTitle => 'Присоединиться к группе';

  @override
  String get joiningGroup => 'Присоединение к группе...';

  @override
  String get pleaseWait => 'Пожалуйста, подождите';

  @override
  String get failedToJoinGroup => 'Не удалось присоединиться к группе';

  @override
  String get goToGroups => 'Перейти к группам';

  @override
  String get successfullyJoined => 'Успешно присоединились!';

  @override
  String get redirectingToGroup => 'Перенаправление в группу...';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get members => 'Участники';

  @override
  String get approval => 'Утверждение';

  @override
  String get removeLabel => 'Удалить';

  @override
  String errorWithMessage(Object message) {
    return 'Ошибка: $message';
  }

  @override
  String invitePeopleToGroup_short(Object groupName) {
    return 'Пригласить $groupName';
  }

  @override
  String get regenerateInviteToken => 'Пересоздать токен приглашения';

  @override
  String get regenerateInviteTokenConfirm =>
      'Это сделает текущую ссылку недействительной. Вы уверены?';

  @override
  String get inviteTokenRegenerated => 'Токен приглашения перегенерировался';

  @override
  String get groupSettingsTitle => 'Настройки группы';

  @override
  String get failedToLoadGroupSettings =>
      'Не удалось загрузить настройки группы';

  @override
  String get save => 'Сохранить';

  @override
  String get basicInformation => 'Основная информация';

  @override
  String get groupName => 'Название группы';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get configuration => 'Конфигурация';

  @override
  String get rotationType => 'Тип ротации';

  @override
  String get gamification => 'Геймификация';

  @override
  String get enablePointsAndRewards => 'Включить очки и награды';

  @override
  String get requireApproval => 'Требовать утверждения';

  @override
  String get memberManagement => 'Управление участниками';

  @override
  String get dangerZone => 'Опасная область';

  @override
  String get deleteGroup => 'Удалить группу';

  @override
  String get deleteGroupConfirm =>
      'Это действие не может быть отменено. Все задачи и данные будут удалены навсегда.';

  @override
  String get deleteGroupSuccess => 'Группа удалена';

  @override
  String get groupNameRequired => 'Имя группы обязательно';

  @override
  String get adminMustApproveTasks => 'Админ должен одобрить задания';

  @override
  String get settingsSaved => 'Настройки успешно сохранены';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get groupDetailsTitle => 'Детали группы';

  @override
  String get leaveGroup => 'Покинуть группу';

  @override
  String get leave => 'Покинуть';

  @override
  String get invite => 'Пригласить';

  @override
  String get request => 'Запросить';

  @override
  String get claimTask => 'Взять задачу';

  @override
  String get markComplete => 'Отметить выполненным';

  @override
  String get complete => 'Выполнено';

  @override
  String get filterByPriority => 'Фильтр по приоритету';

  @override
  String get allPriorities => 'Все приоритеты';

  @override
  String get filterByStatus => 'Фильтр по статусу';

  @override
  String get allStatuses => 'Все статусы';

  @override
  String get gamified => 'Геймифицированная';

  @override
  String get clearFilters => 'Очистить фильтры';

  @override
  String get noTasksFound => 'Задачи не найдены';

  @override
  String taskPoints(Object points) {
    return '$points очков';
  }

  @override
  String get taskClaimedSuccessfully => 'Задача успешно забрана';

  @override
  String markTaskCompleteConfirm(Object taskTitle) {
    return 'Отметить \"$taskTitle\" как выполненную?';
  }

  @override
  String get taskCompletedAwaitingApproval =>
      'Задача выполнена! Ожидает одобрения';

  @override
  String get description => 'Описание';

  @override
  String get details => 'Детали';

  @override
  String get noRewardsAvailable => 'Награды недоступны';

  @override
  String get rewardRequestComingSoon =>
      'Функция запроса наград скоро появится!';

  @override
  String get noDataYet => 'Пока нет данных';

  @override
  String get you => 'Вы';

  @override
  String pointsLabel(Object points) {
    return '$points очков';
  }

  @override
  String get pointsWord => 'очков';

  @override
  String get leftGroupSuccessfully => 'Группа успешно покинута';

  @override
  String get gamificationLabel => 'Геймификация';

  @override
  String get tryAdjustingFilters =>
      'Попробуйте изменить фильтры или создать новую задачу';

  @override
  String get checkBackLaterRewards => 'Загляните позже за новыми наградами';

  @override
  String get completeTasksLeaderboard =>
      'Выполняйте задачи, чтобы появиться в таблице лидеров';

  @override
  String get requiresApproval => 'Требует одобрения';

  @override
  String joinedDate(Object date) {
    return 'Присоединился $date';
  }

  @override
  String get groupCreatedSuccessfully => 'Группа успешно создана';

  @override
  String get enablePointsAndRewardsSystem => 'Включить систему очков и наград';

  @override
  String get requireApprovalTitle => 'Требовать одобрения';

  @override
  String get adminMustApproveCompletedTasks =>
      'Админ должен одобрять выполненные задачи';

  @override
  String get allTab => 'Все';

  @override
  String get myTasksTab => 'Мои задачи';

  @override
  String get availableTab => 'Доступные';

  @override
  String get reviewTab => 'Проверка';

  @override
  String get searchTasks => 'Поиск задач...';

  @override
  String get statusCompleted => 'Выполнено';

  @override
  String get statusAwaitingApproval => 'Ожидает одобрения';

  @override
  String get statusOverdue => 'Просрочено';

  @override
  String get statusPending => 'Ожидает';

  @override
  String get priorityLabel => 'Приоритет';

  @override
  String get statusLabel => 'Статус';

  @override
  String get pointsLabelDetail => 'Очки';

  @override
  String get deadlineLabel => 'Срок';

  @override
  String get assignedToLabel => 'Назначено';

  @override
  String get requiresApprovalLabel => 'Требует одобрения';

  @override
  String get taskDetailsTitle => 'Детали задачи';

  @override
  String get editTask => 'Редактировать задачу';

  @override
  String get deleteTask => 'Удалить задачу';

  @override
  String get deleteTaskConfirmTitle => 'Удалить задачу';

  @override
  String get deleteTaskConfirmMessage =>
      'Вы уверены, что хотите удалить эту задачу?';

  @override
  String get executor => 'Исполнитель';

  @override
  String get upForGrabs => 'Доступно всем';

  @override
  String get reward => 'Награда';

  @override
  String get pts => 'очк.';

  @override
  String get bonusPoints => '+50% бонус';

  @override
  String get createdBy => 'Создал';

  @override
  String get rejectionReason => 'Причина отклонения';

  @override
  String get markAsComplete => 'Отметить как выполненную';

  @override
  String get reject => 'Отклонить';

  @override
  String get approve => 'Одобрить';

  @override
  String get rejectTaskTitle => 'Отклонить задачу';

  @override
  String get rejectionReasonHint => 'Введите причину отклонения';

  @override
  String get errorLoadingTask => 'Ошибка загрузки задачи';

  @override
  String get createTask => 'Создать задачу';

  @override
  String get updateTask => 'Обновить задачу';

  @override
  String get taskTitle => 'Название задачи';

  @override
  String get enterTaskTitle => 'Введите название задачи';

  @override
  String get enterTitleValidation => 'Пожалуйста, введите название задачи';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get enterTaskDescription => 'Введите описание задачи';

  @override
  String get tapToSelectDeadline => 'Нажмите, чтобы выбрать срок';

  @override
  String get priority => 'Приоритет';

  @override
  String get enterPointValue => 'Введите количество очков';

  @override
  String get enterPointValueValidation =>
      'Пожалуйста, введите количество очков';

  @override
  String get pointsRangeValidation => 'Очки должны быть от 1 до 1000';

  @override
  String get requiresApprovalTitle => 'Требует одобрения';

  @override
  String get requiresApprovalSubtitle =>
      'Задача должна быть одобрена админом после выполнения';

  @override
  String get taskCreatedSuccessfully => 'Задача успешно создана';

  @override
  String get groupTasksTab => 'Задачи группы';

  @override
  String get upForGrabsTab => 'Доступно всем';

  @override
  String get pendingApprovalTab => 'Ожидают одобрения';

  @override
  String get noTasksAssigned => 'Вам не назначены задачи';

  @override
  String get tasksWillAppearHere => 'Задачи появятся здесь';

  @override
  String get selectGroup => 'Выберите группу';

  @override
  String get viewGroupTasksFromGroupsTab =>
      'Просмотрите задачи группы на вкладке Группы';

  @override
  String get noTasksAvailable => 'Нет доступных задач';

  @override
  String get noTasksPendingApproval => 'Нет задач, ожидающих одобрения';

  @override
  String get errorLoadingTasks => 'Ошибка загрузки задач';

  @override
  String get priorityHigh => 'Высокий';

  @override
  String get priorityMedium => 'Средний';

  @override
  String get priorityLow => 'Низкий';

  @override
  String get statusActive => 'Активна';

  @override
  String get statusPendingReview => 'Ожидает проверки';

  @override
  String daysLeft(Object count) {
    return '$count дн. осталось';
  }

  @override
  String hoursLeft(Object count) {
    return '$count ч. осталось';
  }

  @override
  String minutesLeft(Object count) {
    return '$count мин. осталось';
  }

  @override
  String daysOverdue(Object count) {
    return '$count дн. просрочено';
  }

  @override
  String hoursOverdue(Object count) {
    return '$count ч. просрочено';
  }

  @override
  String minutesOverdue(Object count) {
    return '$count мин. просрочено';
  }

  @override
  String get tasksAssigned => 'Задачи назначены';

  @override
  String get tasksCompletedLabel => 'Задачи завершены';

  @override
  String get pointsBalance => 'Баланс очков';

  @override
  String get completionRateLabel => 'Процент завершения';

  @override
  String get upcomingTasks => 'Предстоящие задачи';

  @override
  String get dueTasks => 'Задачи на сегодня';

  @override
  String get overdueTasks => 'Просроченные задачи';

  @override
  String get pendingApprovalTasks => 'Ожидают одобрения';

  @override
  String get quickStats => 'Быстрая статистика';

  @override
  String get allGroups => 'Все группы';

  @override
  String get filterByGroup => 'Фильтр по группе';

  @override
  String get tasksDueToday => 'Задачи на сегодня';

  @override
  String get noTasksDueToday => 'Нет задач на сегодня';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get previousWeek => 'Предыдущая неделя';

  @override
  String get nextWeek => 'Следующая неделя';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String tasksForDate(Object date) {
    return 'Задачи на $date';
  }
}
