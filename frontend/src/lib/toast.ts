/**
 * Toast notification helper for displaying success, error, and info messages
 * Uses the notification store to manage toast notifications
 */

import { useNotificationStore } from '@store/notificationStore'

export const toast = {
  success: (message: string) => {
    useNotificationStore.getState().addNotification({
      type: 'success',
      message,
    })
  },

  error: (message: string) => {
    useNotificationStore.getState().addNotification({
      type: 'error',
      message,
    })
  },

  info: (message: string) => {
    useNotificationStore.getState().addNotification({
      type: 'info',
      message,
    })
  },

  warning: (message: string) => {
    useNotificationStore.getState().addNotification({
      type: 'warning',
      message,
    })
  },

  // Specific notification for task assignment (Phase 5.5)
  taskAssigned: (taskTitle: string) => {
    useNotificationStore.getState().addNotification({
      type: 'info',
      message: `Вам назначена новая задача: "${taskTitle}"`,
    })
  },

  // Notification for task claimed from Up-for-Grabs pool
  taskClaimed: (taskTitle: string, points: number) => {
    useNotificationStore.getState().addNotification({
      type: 'success',
      message: `Вы взяли задачу "${taskTitle}" (+${Math.round(points * 1.5)} баллов с бонусом)`,
    })
  },

  // Notification for task completed
  taskCompleted: (taskTitle: string) => {
    useNotificationStore.getState().addNotification({
      type: 'success',
      message: `Задача "${taskTitle}" отправлена на проверку`,
    })
  },

  // Notification for task approved
  taskApproved: (taskTitle: string, points: number) => {
    useNotificationStore.getState().addNotification({
      type: 'success',
      message: `Задача "${taskTitle}" одобрена! Вы получили ${points} баллов`,
    })
  },

  // Notification for task rejected
  taskRejected: (taskTitle: string, reason?: string) => {
    useNotificationStore.getState().addNotification({
      type: 'error',
      message: `Задача "${taskTitle}" отклонена${reason ? `: ${reason}` : ''}`,
    })
  },
}

/**
 * Generic toast notification helper function
 * @param message - The message to display
 * @param type - The type of notification (success, error, info, warning)
 */
export function showToast(
  message: string,
  type: 'success' | 'error' | 'info' | 'warning' = 'info'
): void {
  useNotificationStore.getState().addNotification({
    type,
    message,
  })
}
