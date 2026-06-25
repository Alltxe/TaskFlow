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
  String get welcomeScreenTitle => 'Добро пожаловать';

  @override
  String get welcomeScreenSubtitle =>
      'Для начала работы войдите или создайте аккаунт';

  @override
  String get welcomeCreateAccount => 'Создать аккаунт';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Введите email и мы отправим код для сброса пароля';

  @override
  String get forgotPasswordEmailLabel => 'Ваш email';

  @override
  String get sendResetCode => 'Отправить код';

  @override
  String resetCodeSentSubtitle(String email) {
    return 'Введите 6-значный код, отправленный на $email';
  }

  @override
  String get resetCodeLabel => 'Код из письма';

  @override
  String get resetPasswordTitle => 'Новый пароль';

  @override
  String get setNewPassword => 'Установить пароль';

  @override
  String get passwordResetSuccess =>
      'Пароль успешно изменён. Войдите с новым паролем.';

  @override
  String get invalidResetCode => 'Неверный или устаревший код';

  @override
  String get resendCode => 'Отправить повторно';

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
  String get loginRequired => 'Требуется вход';

  @override
  String get pleaseLoginToJoinGroup =>
      'Пожалуйста, войдите или зарегистрируйтесь, чтобы присоединиться к группе';

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
  String get approval => 'Проверка';

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
  String get templateAnchorDeadlineLabel => 'Интервал срока';

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
  String get requestRewardTitle => 'Запросить награду';

  @override
  String requestRewardMessage(Object rewardName, Object points) {
    return 'Запросить \"$rewardName\" за $points очков?';
  }

  @override
  String get rewardRequestedSuccess => 'Награда запрошена! Ожидает одобрения.';

  @override
  String insufficientPoints(Object required, Object available) {
    return 'Недостаточно очков. Нужно $required, доступно $available.';
  }

  @override
  String get availableBalance => 'Доступный баланс';

  @override
  String yourBalance(Object points) {
    return 'Ваш баланс: $points очк.';
  }

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
  String get recurringTemplatesTab => 'Шаблоны';

  @override
  String get noRecurringTemplates => 'Пока нет повторяющихся шаблонов';

  @override
  String get recurringTemplatesInfoTitle => 'Как работают шаблоны';

  @override
  String get recurringTemplatesInfoBody =>
      'Шаблоны не являются исполняемыми задачами. По расписанию из них автоматически создаются обычные задачи. Срок для каждой новой задачи задаётся относительным интервалом (например, 1 день или 1 неделя).';

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

  @override
  String get rotationTypeLabel => 'Тип ротации';

  @override
  String get rotationTypeRoundRobin => 'По очереди';

  @override
  String get rotationTypeRandom => 'Случайно';

  @override
  String get rotationTypeLoadBalancing => 'Балансировка нагрузки';

  @override
  String get rotationTypeDisabled => 'Отключено (Вручную)';

  @override
  String get rotationTypesHelpTitle => 'Режимы распределения задач';

  @override
  String get rotationTypesHelpIntro =>
      'Определяет, как назначаются новые задачи без выбранного исполнителя.';

  @override
  String get rotationTypeHelpRoundRobin =>
      'Задачи выдаются по кругу: каждый следующий участник получает задачу после предыдущего. Участники в отпуске пропускаются.';

  @override
  String get rotationTypeHelpRandom =>
      'Исполнитель выбирается случайно из доступных участников группы.';

  @override
  String get rotationTypeHelpWeightedRandom =>
      'Случайный выбор с учётом нагрузки: у кого меньше активных задач, тот чаще получает новые.';

  @override
  String get rotationTypeHelpLoadBalancing =>
      'Учитывает сложность выполненных задач. Новая задача достаётся тому, у кого накоплено меньше тяжёлых задач. При создании задачи можно указать её сложность.';

  @override
  String get rotationTypeHelpDisabled =>
      'Автоназначение отключено. Задачи попадают в общий список «доступно всем», пока кто-нибудь не возьмёт их вручную.';

  @override
  String get pleaseSelectDeadline => 'Пожалуйста, выберите срок';

  @override
  String get recurrenceTemplateLabel => 'Повторяющийся шаблон';

  @override
  String get recurrenceTemplateSubtitle =>
      'Автоматически создавать задачи по расписанию';

  @override
  String get recurringTemplateChip => 'Шаблон';

  @override
  String get templateAnchorDeadlineHint =>
      'Для шаблона здесь задается относительный интервал срока для сгенерированных задач';

  @override
  String get templateAnchorDeadlineShortHint =>
      'Сгенерированные задачи используют выбранный интервал срока';

  @override
  String get recurringDeadlineAutoHint =>
      'Для повторяющихся шаблонов выберите относительный интервал срока (день/неделя/месяц)';

  @override
  String get recurringDeadlineSelectorLabel =>
      'Срок для каждой сгенерированной задачи';

  @override
  String get recurringDeadlineIntervalLabel => 'Значение';

  @override
  String get recurringDeadlineUnitLabel => 'Единица';

  @override
  String get recurringDeadlineUnitDay => 'День';

  @override
  String get recurringDeadlineUnitWeek => 'Неделя';

  @override
  String get recurringDeadlineUnitMonth => 'Месяц';

  @override
  String get recurringDeadlineSelectorHint =>
      'Пример: 1 неделя означает, что срок каждой сгенерированной задачи — через неделю после создания';

  @override
  String get recurrenceFrequencyLabel => 'Частота';

  @override
  String get recurrenceFrequencyDaily => 'Ежедневно';

  @override
  String get recurrenceFrequencyWeekly => 'Еженедельно';

  @override
  String get recurrenceFrequencyMonthly => 'Ежемесячно';

  @override
  String get recurrenceIntervalLabel => 'Интервал';

  @override
  String get recurrenceEveryPeriod => 'Каждый период';

  @override
  String recurrenceEveryNPeriods(Object count) {
    return 'Каждые $count периодов';
  }

  @override
  String get recurrenceWeekdaysLabel => 'Дни недели';

  @override
  String get recurrenceSelectWeekday => 'Выберите хотя бы один день недели';

  @override
  String recurrenceDayOfMonth(Object day) {
    return 'День месяца: $day';
  }

  @override
  String get recurrenceEndsLabel => 'Окончание';

  @override
  String get recurrenceEndNever => 'Никогда';

  @override
  String get recurrenceEndAfterCount => 'После количества повторений';

  @override
  String get recurrenceEndUntilDate => 'В дату';

  @override
  String get recurrenceOccurrencesLabel => 'Количество повторений';

  @override
  String recurrenceOccurrencesValue(Object count) {
    return '$count повторений';
  }

  @override
  String get recurrenceUntilDateLabel => 'До даты';

  @override
  String get recurrenceSelectUntilDate =>
      'Нажмите, чтобы выбрать дату окончания';

  @override
  String get recurrenceRuleLabel => 'Правило повторения';

  @override
  String get recurrenceRuleInvalid =>
      'Пожалуйста, настройте корректное правило повторения';

  @override
  String get recurrenceRuleInvalidShort => 'некорректно';

  @override
  String get recurrenceSectionWhen => 'Как часто повторять';

  @override
  String get recurrenceSummaryTitle => 'Что получится';

  @override
  String recurrencePreviewTask(int number) {
    return 'Задача $number';
  }

  @override
  String recurrencePreviewAppears(Object date) {
    return 'Появится: $date';
  }

  @override
  String get recurrencePreviewAppearsImmediately =>
      'Появится: сразу после сохранения';

  @override
  String recurrencePreviewDeadline(Object date) {
    return 'Срок: $date';
  }

  @override
  String recurrencePreviewMoreTasks(int count) {
    return 'и ещё $count';
  }

  @override
  String get recurrencePreviewRepeatsForever =>
      'Далее задачи будут появляться по тому же расписанию';

  @override
  String get recurrenceTestRuleLabel =>
      'Тестовое правило повторения (только debug)';

  @override
  String get recurrenceTestRuleHint => 'Для разработчиков';

  @override
  String get recurrenceTestRuleDescription =>
      'Если заполнено, переопределяет настройки визуального редактора. Только для тестирования.';

  @override
  String get recurrenceTestRuleInvalid =>
      'Некорректное тестовое правило повторения';

  @override
  String get weekdayShortMon => 'Пн';

  @override
  String get weekdayShortTue => 'Вт';

  @override
  String get weekdayShortWed => 'Ср';

  @override
  String get weekdayShortThu => 'Чт';

  @override
  String get weekdayShortFri => 'Пт';

  @override
  String get weekdayShortSat => 'Сб';

  @override
  String get weekdayShortSun => 'Вс';

  @override
  String get pointsHistory => 'История очков';

  @override
  String get totalEarned => 'Всего заработано';

  @override
  String get totalSpent => 'Всего потрачено';

  @override
  String get reservedPending => 'Зарезервировано (ожидание)';

  @override
  String get availablePoints => 'Доступные очки';

  @override
  String get transactionHistory => 'История транзакций';

  @override
  String get noTransactionsYet => 'Транзакций пока нет';

  @override
  String get startCompletingTasks =>
      'Выполняйте задачи, чтобы зарабатывать очки';

  @override
  String get earned => 'Заработано';

  @override
  String get spent => 'Потрачено';

  @override
  String get taskCompleted => 'Задача выполнена';

  @override
  String get rewardRequested => 'Награда запрошена';

  @override
  String get adminRewardsManagement => 'Управление наградами (админ)';

  @override
  String get createReward => 'Создать награду';

  @override
  String get editReward => 'Редактировать награду';

  @override
  String get deleteReward => 'Удалить награду';

  @override
  String get rewardName => 'Название награды';

  @override
  String get rewardDescription => 'Описание (необязательно)';

  @override
  String get rewardCost => 'Стоимость (в очках)';

  @override
  String get rewardImageUrl => 'URL изображения (необязательно)';

  @override
  String get enterRewardName => 'Введите название награды';

  @override
  String get enterRewardDescription => 'Опишите награду...';

  @override
  String get enterRewardCost => 'Введите стоимость в очках';

  @override
  String get enterImageUrl => 'Введите URL изображения';

  @override
  String get rewardNameRequired => 'Название награды обязательно';

  @override
  String get rewardNameMinLength => 'Название должно быть не короче 3 символов';

  @override
  String get rewardCostRequired => 'Стоимость обязательна';

  @override
  String get rewardCostMustBePositive =>
      'Стоимость должна быть положительным числом';

  @override
  String get rewardCreatedSuccess => 'Награда успешно создана!';

  @override
  String get rewardUpdatedSuccess => 'Награда успешно обновлена!';

  @override
  String get rewardDeletedSuccess => 'Награда успешно удалена!';

  @override
  String get confirmDeleteReward =>
      'Вы уверены, что хотите удалить эту награду?';

  @override
  String get confirmDeleteRewardMessage =>
      'Это действие нельзя отменить. Запросы пользователей сохранятся.';

  @override
  String get rewardRequestsQueue => 'Запросы наград (админ)';

  @override
  String get noPendingRequests => 'Нет ожидающих запросов';

  @override
  String get noRequestsDescription => 'Все запросы наград обработаны';

  @override
  String get approveRequest => 'Одобрить';

  @override
  String get rejectRequest => 'Отклонить';

  @override
  String get requestedBy => 'Запросил';

  @override
  String get requestedAt => 'Запрошено';

  @override
  String get pointsWillBeDeducted => 'Очки будут списаны';

  @override
  String get pointsWillBeReturned => 'Очки будут возвращены';

  @override
  String get confirmApprove => 'Одобрить запрос';

  @override
  String get confirmReject => 'Отклонить запрос';

  @override
  String approveRequestMessage(Object points) {
    return 'Одобрить этот запрос награды? У пользователя будет списано $points очков.';
  }

  @override
  String rejectRequestMessage(Object points) {
    return 'Отклонить этот запрос награды? Пользователю будет возвращено $points очков.';
  }

  @override
  String get requestApprovedSuccess => 'Запрос одобрен! Очки списаны.';

  @override
  String get requestRejectedSuccess => 'Запрос отклонён. Очки возвращены.';

  @override
  String get statusReserved => 'Ожидает одобрения';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get manageRewards => 'Управление наградами';

  @override
  String get viewRequests => 'Просмотр запросов';

  @override
  String get insufficientPointsShort => 'Недостаточно';

  @override
  String get create => 'Создать';

  @override
  String get delete => 'Удалить';

  @override
  String get error => 'Ошибка';

  @override
  String get networkError =>
      'Нет подключения к интернету. Проверьте настройки сети.';

  @override
  String get timeoutError => 'Превышено время ожидания. Попробуйте еще раз.';

  @override
  String get serverError => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get authError => 'Ошибка авторизации. Войдите снова.';

  @override
  String get invalidCredentialsError => 'Неверный email или пароль.';

  @override
  String get validationError => 'Некорректные данные. Проверьте ввод.';

  @override
  String get notFoundError => 'Ресурс не найден.';

  @override
  String get permissionError => 'Доступ запрещен.';

  @override
  String get unknownError =>
      'Произошла непредвиденная ошибка. Попробуйте еще раз.';

  @override
  String get dismiss => 'Закрыть';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get currentPasswordRequired => 'Введите текущий пароль';

  @override
  String get newPasswordRequired => 'Введите новый пароль';

  @override
  String get confirmNewPasswordRequired => 'Подтвердите новый пароль';

  @override
  String get profileUpdatedSuccess => 'Профиль успешно обновлён';

  @override
  String get passwordChangedSuccess => 'Пароль успешно изменён';

  @override
  String get usernameHint => 'Введите новое имя пользователя';

  @override
  String get changePasswordTitle => 'Изменить пароль';

  @override
  String get rotationTypeWeightedRandom => 'Взвешенная случайность';

  @override
  String get priorityCritical => 'Критический';

  @override
  String get statusCancelled => 'Отменена';

  @override
  String get roleAdmin => 'Админ';

  @override
  String get roleMember => 'Участник';

  @override
  String get memberStatusActive => 'Активен';

  @override
  String get changeRole => 'Сменить роль';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateJustNow => 'только что';

  @override
  String dateMinutesAgo(Object count) {
    return '$count мин. назад';
  }

  @override
  String dateHoursAgo(Object count) {
    return '$count ч. назад';
  }

  @override
  String dateDaysAgo(Object count) {
    return '$count дн. назад';
  }

  @override
  String dateWeeksAgo(Object count) {
    return '$count нед. назад';
  }

  @override
  String dateMonthsAgo(Object count) {
    return '$count мес. назад';
  }

  @override
  String dateYearsAgo(Object count) {
    return '$count г. назад';
  }

  @override
  String get joinGroupByToken => 'Ввести код приглашения';

  @override
  String get enterInviteToken => 'Введите токен приглашения';

  @override
  String get pasteFromClipboard => 'Вставить из буфера';

  @override
  String get invalidInviteToken => 'Неверный токен приглашения';

  @override
  String get groupPreviewTitle => 'Предпросмотр группы';

  @override
  String memberCount(Object count) {
    return '$count участников';
  }

  @override
  String get joinGroupConfirm => 'Присоединиться';

  @override
  String get joinOrCreateGroupHint =>
      'Создайте новую группу или присоединитесь по коду приглашения';

  @override
  String get enterInviteCode => 'Ввести код приглашения';

  @override
  String get groupNameHint => 'Введите название группы';

  @override
  String get groupNameMinLength => 'Название должно быть не короче 3 символов';

  @override
  String get groupDescriptionOptional => 'Описание (необязательно)';

  @override
  String get groupDescriptionHint => 'Введите описание группы';

  @override
  String get assignTo => 'Назначить';

  @override
  String get autoByRotation => 'Авто (по ротации)';

  @override
  String get upForGrabsBonus => 'Без назначения (+50% бонус)';

  @override
  String get useGroupDefault => 'По умолчанию группы';

  @override
  String get taskDifficultyLabel => 'Сложность';

  @override
  String get taskDifficultyHint =>
      'Насколько тяжёлая эта задача? (1 — лёгкая, 10 — очень сложная). Учитывается при балансировке нагрузки.';

  @override
  String get roleParticipant => 'Участник';

  @override
  String get auditLogTitle => 'Журнал аудита';

  @override
  String get groupAuditLog => 'Журнал группы';

  @override
  String get taskHistory => 'История';

  @override
  String get myActions => 'Мои действия';

  @override
  String get auditAction => 'Действие';

  @override
  String get auditEntity => 'Объект';

  @override
  String get auditPerformedBy => 'Выполнил';

  @override
  String get auditPerformedAt => 'Дата';

  @override
  String get noAuditLogs => 'Записей пока нет';

  @override
  String get auditActionUserStatusChanged => 'Статус изменён';

  @override
  String get auditActionUserProfileUpdated => 'Профиль обновлён';

  @override
  String get auditActionGroupCreated => 'Группа создана';

  @override
  String get auditActionGroupUpdated => 'Настройки группы изменены';

  @override
  String get auditActionGroupDeleted => 'Группа удалена';

  @override
  String get auditActionMemberAdded => 'Участник присоединился';

  @override
  String get auditActionMemberRemoved => 'Участник удалён';

  @override
  String get auditActionMemberRoleChanged => 'Роль изменена';

  @override
  String get auditActionTaskCreated => 'Задача создана';

  @override
  String get auditActionTaskUpdated => 'Задача изменена';

  @override
  String get auditActionTaskDeleted => 'Задача удалена';

  @override
  String get auditActionTaskAssigned => 'Задача назначена';

  @override
  String get auditActionTaskCompleted => 'Задача выполнена';

  @override
  String get auditActionTaskApproved => 'Задача одобрена';

  @override
  String get auditActionTaskRejected => 'Задача отклонена';

  @override
  String get auditActionTaskOverdue => 'Просрочена задача';

  @override
  String get auditActionRewardCreated => 'Награда создана';

  @override
  String get auditActionRewardUpdated => 'Награда изменена';

  @override
  String get auditActionRewardDeleted => 'Награда удалена';

  @override
  String get auditActionRewardRequested => 'Запрошена награда';

  @override
  String get auditActionRewardRequestApproved => 'Награда выдана';

  @override
  String get auditActionRewardRequestRejected => 'Запрос награды отклонён';

  @override
  String get auditActionPointsEarned => 'Начислены очки';

  @override
  String get auditActionPointsReserved => 'Очки зарезервированы';

  @override
  String get auditActionPointsSpent => 'Очки потрачены';

  @override
  String get auditActionPointsRefunded => 'Очки возвращены';

  @override
  String get auditActionUnknown => 'Действие';

  @override
  String auditDetailTaskTitle(Object title) {
    return '«$title»';
  }

  @override
  String auditDetailTaskTemplate(Object title) {
    return 'Шаблон «$title»';
  }

  @override
  String auditDetailGroupName(Object name) {
    return '«$name»';
  }

  @override
  String auditDetailGroupRenamed(Object oldName, Object newName) {
    return '«$oldName» → «$newName»';
  }

  @override
  String auditDetailRoleChanged(Object oldRole, Object newRole) {
    return '$oldRole → $newRole';
  }

  @override
  String auditDetailPoints(Object amount) {
    return '+$amount очков';
  }

  @override
  String auditDetailPointsWithDescription(Object amount, Object description) {
    return '+$amount очк. · $description';
  }

  @override
  String auditDetailPointsSpent(Object amount) {
    return '−$amount очков';
  }

  @override
  String auditDetailRejectionReason(Object reason) {
    return 'Причина: $reason';
  }

  @override
  String get auditDetailTaskAwaitingApproval => 'Ожидает одобрения';

  @override
  String get auditDetailMemberJoined => 'Вступил в группу';

  @override
  String get auditDetailMemberLeft => 'Покинул группу';

  @override
  String get auditDetailMemberRemovedByAdmin => 'Исключён из группы';

  @override
  String auditLogEntryMeta(Object user, Object date) {
    return '$user · $date';
  }

  @override
  String auditLogInGroup(Object name) {
    return 'Группа «$name»';
  }

  @override
  String get auditLogPersonalScope => 'Личный профиль';

  @override
  String get auditLogSystemUser => 'Система';

  @override
  String get auditDetailPointsTaskCompleted => 'За выполнение задачи';

  @override
  String get auditDetailPointsTaskApproved => 'За одобрение задачи';

  @override
  String get auditDetailPointsTaskCompletedBonus =>
      'За выполнение задачи (бонус Up-for-Grabs)';

  @override
  String get auditDetailPointsTaskApprovedBonus =>
      'За одобрение задачи (бонус Up-for-Grabs)';

  @override
  String get notificationsEmpty => 'Нет уведомлений';

  @override
  String get notificationsEmptyHint => 'Всё прочитано!';

  @override
  String get markAllRead => 'Отметить все как прочитанные';

  @override
  String get markRead => 'Отметить прочитанным';

  @override
  String get notificationTypeTaskAssigned => 'Задача назначена';

  @override
  String get notificationTypeTaskCompleted => 'Задача выполнена';

  @override
  String get notificationTypeTaskApproved => 'Задача одобрена';

  @override
  String get notificationTypeTaskRejected => 'Задача отклонена';

  @override
  String get notificationTypeRewardRequested => 'Запрос награды';

  @override
  String get notificationTypeRewardApproved => 'Награда одобрена';

  @override
  String get notificationTypeRewardRejected => 'Награда отклонена';

  @override
  String get notificationTypePointAwarded => 'Начислены очки';

  @override
  String get notificationTypeInvitation => 'Приглашение в группу';

  @override
  String get notificationTypeSystem => 'Системное';

  @override
  String get notificationTypeTaskClaimed => 'Задача взята';

  @override
  String get notificationTypeTaskPendingReview => 'Задача на проверке';

  @override
  String get notificationTypeRewardRequest => 'Запрос награды';

  @override
  String notificationMessageTaskAssigned(Object title) {
    return 'Вам назначена задача: $title';
  }

  @override
  String notificationMessageTaskClaimed(Object title) {
    return 'Вы взяли задачу: $title';
  }

  @override
  String notificationMessageTaskAwaitingApproval(Object title) {
    return 'Задача «$title» ожидает одобрения';
  }

  @override
  String notificationMessageTaskApproved(Object title) {
    return 'Ваша задача «$title» одобрена';
  }

  @override
  String notificationMessageTaskRejected(Object title, Object reason) {
    return 'Ваша задача «$title» отклонена: $reason';
  }

  @override
  String notificationMessagePointsEarnedCompletion(
    Object points,
    Object title,
    Object bonus,
  ) {
    return 'Вы получили $points очк. за выполнение «$title»$bonus';
  }

  @override
  String notificationMessagePointsEarnedApproval(
    Object points,
    Object title,
    Object bonus,
  ) {
    return 'Вы получили $points очк. за одобрение «$title»$bonus';
  }

  @override
  String get notificationMessageUpForGrabsBonus =>
      ' (бонус за взятие из пула!)';

  @override
  String notificationMessageRewardRequested(Object name) {
    return 'Новый запрос награды: «$name»';
  }

  @override
  String notificationMessageRewardApproved(Object name) {
    return 'Ваш запрос награды «$name» одобрен';
  }

  @override
  String notificationMessageRewardRejected(Object name, Object reason) {
    return 'Ваш запрос награды «$name» отклонён: $reason';
  }

  @override
  String notificationMessageDeadline24h(Object title) {
    return '«$title» — дедлайн через 24 часа';
  }

  @override
  String notificationMessageDeadline1h(Object title) {
    return '«$title» — дедлайн через 1 час';
  }

  @override
  String get notificationNoReason => 'Причина не указана';

  @override
  String get unreadOnly => 'Только непрочитанные';

  @override
  String get rotationSchedule => 'Расписание ротации';

  @override
  String get rotationHistory => 'История ротации';

  @override
  String get rotationPattern => 'Шаблон ротации';

  @override
  String get rotationScheduleTitle => 'Предстоящие назначения';

  @override
  String get rotationHistoryTitle => 'История назначений';

  @override
  String get rotationScheduleEmpty => 'Нет предстоящих назначений';

  @override
  String get rotationHistoryEmpty => 'История назначений пуста';

  @override
  String scheduledFor(Object date) {
    return 'Запланировано на $date';
  }

  @override
  String assignedTo(Object name) {
    return 'Назначено: $name';
  }

  @override
  String pointsEarned(Object points) {
    return '$points очков заработано';
  }

  @override
  String get viewRotation => 'Просмотр ротации';

  @override
  String get recurringTemplates => 'Шаблоны задач';

  @override
  String get recurringTemplatesEmpty => 'Нет шаблонов повторяющихся задач';

  @override
  String get generateNextTask => 'Сгенерировать следующую';

  @override
  String get generateNextTaskConfirm =>
      'Создать следующий экземпляр задачи из этого шаблона?';

  @override
  String get taskGenerated => 'Следующая задача успешно создана';

  @override
  String get recurrenceRule => 'Правило повторения';

  @override
  String get viewRecurringTemplates => 'Шаблоны задач';

  @override
  String get filterTasks => 'Фильтр задач';

  @override
  String get applyFilters => 'Применить';

  @override
  String get attachments => 'Вложения';

  @override
  String get addAttachment => 'Добавить';

  @override
  String get deleteAttachmentTitle => 'Удалить вложение?';

  @override
  String get deleteAttachmentMessage =>
      'Файл будет удалён без возможности восстановления.';

  @override
  String get attachmentAdded => 'Вложение добавлено';

  @override
  String get attachmentDeleted => 'Вложение удалено';

  @override
  String get fromGallery => 'Из галереи';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get mediaPermissionDenied => 'Нет разрешения на доступ к медиафайлам';
}
