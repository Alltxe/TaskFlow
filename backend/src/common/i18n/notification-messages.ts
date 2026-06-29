type NotificationLocale = 'ru' | 'en';

function getNotificationLocale(): NotificationLocale {
  const locale = process.env.NOTIFICATION_LOCALE?.toLowerCase();
  return locale === 'en' ? 'en' : 'ru';
}

function t(ru: string, en: string): string {
  return getNotificationLocale() === 'en' ? en : ru;
}

export const NotificationMessages = {
  taskAssignedTitle: () => t('Задача назначена', 'Task assigned'),
  taskAssigned: (title: string) =>
    t(`Вам назначена задача: ${title}`, `You have been assigned: ${title}`),

  taskClaimedTitle: () => t('Задача взята', 'Task claimed'),
  taskClaimed: (title: string) =>
    t(`Вы взяли задачу: ${title}`, `You claimed: ${title}`),

  taskPendingReviewTitle: () => t('Задача на проверке', 'Task pending review'),
  taskAwaitingApproval: (title: string) =>
    t(`Задача «${title}» ожидает одобрения`, `Task "${title}" is awaiting approval`),

  taskApprovedTitle: () => t('Задача одобрена', 'Task approved'),
  taskApproved: (title: string) =>
    t(`Ваша задача «${title}» одобрена`, `Your task "${title}" has been approved`),

  taskRejectedTitle: () => t('Задача отклонена', 'Task rejected'),
  taskRejected: (title: string, reason: string) =>
    t(
      `Ваша задача «${title}» отклонена: ${reason}`,
      `Your task "${title}" was rejected: ${reason}`,
    ),

  pointsAwardedTitle: () => t('Начислены очки', 'Points Awarded'),
  pointsEarnedCompletion: (points: number, title: string, wasClaimed: boolean) => {
    const bonus = wasClaimed
      ? t(' (бонус за взятие из пула!)', ' (Up-for-Grabs bonus!)')
      : '';
    return t(
      `Вы получили ${points} очк. за выполнение «${title}»${bonus}`,
      `You earned ${points} points for completing "${title}"${bonus}`,
    );
  },
  pointsEarnedApproval: (points: number, title: string, wasClaimed: boolean) => {
    const bonus = wasClaimed
      ? t(' (бонус за взятие из пула!)', ' (Up-for-Grabs bonus!)')
      : '';
    return t(
      `Вы получили ${points} очк. за одобрение «${title}»${bonus}`,
      `You earned ${points} points for "${title}" approval${bonus}`,
    );
  },

  rewardRequestTitle: () => t('Запрос награды', 'Reward request'),
  rewardRequested: (name: string) =>
    t(`Новый запрос награды: «${name}»`, `New reward request for "${name}"`),

  rewardApprovedTitle: () => t('Награда одобрена', 'Reward request approved'),
  rewardApproved: (name: string) =>
    t(
      `Ваш запрос награды «${name}» одобрен`,
      `Your reward request for "${name}" has been approved`,
    ),

  rewardRejectedTitle: () => t('Награда отклонена', 'Reward request rejected'),
  rewardRejected: (name: string, reason: string) =>
    t(
      `Ваш запрос награды «${name}» отклонён: ${reason}`,
      `Your reward request for "${name}" was rejected: ${reason}`,
    ),

  noReason: () => t('Причина не указана', 'No reason provided'),

  deadline24hTitle: () => t('Дедлайн через 24 ч.', 'Task due in 24h'),
  deadline24h: (title: string) =>
    t(`«${title}» — дедлайн через 24 часа`, `"${title}" is due in 24 hours`),

  deadline1hTitle: () => t('Дедлайн через 1 ч.', 'Task due in 1h'),
  deadline1h: (title: string) =>
    t(`«${title}» — дедлайн через 1 час`, `"${title}" is due in 1 hour`),
};
