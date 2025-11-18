import { type FC } from 'react'
import { Snackbar, Alert } from '@mui/material'
import { useNotificationStore } from '@store/notificationStore'

/**
 * Toast Notifications component
 * Displays toast notifications from the notification store
 * Phase 5.5: Rotation notifications
 */
export const ToastNotifications: FC = () => {
  const { notifications, removeNotification } = useNotificationStore()

  // Show only the most recent unread notification as a toast
  const latestNotification = notifications.find((n) => !n.read)

  const handleClose = () => {
    if (latestNotification) {
      removeNotification(latestNotification.id)
    }
  }

  if (!latestNotification) {
    return null
  }

  return (
    <Snackbar
      open={true}
      autoHideDuration={6000}
      onClose={handleClose}
      anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
    >
      <Alert
        onClose={handleClose}
        severity={latestNotification.type}
        variant="filled"
        sx={{ width: '100%' }}
      >
        {latestNotification.message}
      </Alert>
    </Snackbar>
  )
}
