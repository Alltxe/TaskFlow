import type { FC } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Box,
  Alert,
} from '@mui/material'
import { Stars as StarsIcon, Warning as WarningIcon } from '@mui/icons-material'
import { useMutation } from 'urql'
import { REQUEST_REWARD_MUTATION } from '@api/queries'
import { formatPoints } from '@lib/formatPoints'
import { calculateNewBalance } from '@lib/rewardHelpers'
import { showToast } from '@lib/toast'

export interface RewardRequestModalProps {
  open: boolean
  reward: {
    id: string
    name: string
    description?: string | null
    cost: number
  } | null
  groupId: string
  availableBalance: number
  onClose: () => void
  onSuccess?: () => void
}

export const RewardRequestModal: FC<RewardRequestModalProps> = ({
  open,
  reward,
  groupId,
  availableBalance,
  onClose,
  onSuccess,
}) => {
  const [, requestReward] = useMutation(REQUEST_REWARD_MUTATION)

  const handleConfirm = async () => {
    if (!reward) return

    const result = await requestReward({
      input: {
        rewardId: reward.id,
        groupId,
      },
    })

    if (result.error) {
      showToast(`Ошибка запроса награды: ${result.error.message}`, 'error')
      return
    }

    showToast(
      `Запрос отправлен! ${formatPoints(reward.cost)} зарезервировано до одобрения администратором.`,
      'success'
    )
    onClose()
    onSuccess?.()
  }

  if (!reward) return null

  const newBalance = calculateNewBalance(availableBalance, reward.cost)

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>Подтвердите запрос награды</DialogTitle>

      <DialogContent>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <StarsIcon color="primary" />
            {reward.name}
          </Typography>

          {reward.description && (
            <Typography variant="body2" color="text.secondary">
              {reward.description}
            </Typography>
          )}

          <Box
            sx={{
              p: 2,
              bgcolor: 'background.default',
              borderRadius: 1,
              border: '1px solid',
              borderColor: 'divider',
            }}
          >
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Стоимость награды:
            </Typography>
            <Typography variant="h6" color="primary" gutterBottom>
              {formatPoints(reward.cost)}
            </Typography>

            <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }} gutterBottom>
              Текущий доступный баланс:
            </Typography>
            <Typography variant="body1" gutterBottom>
              {formatPoints(availableBalance)}
            </Typography>

            <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }} gutterBottom>
              Новый доступный баланс:
            </Typography>
            <Typography variant="body1" fontWeight={600}>
              {formatPoints(newBalance)}
            </Typography>
          </Box>

          <Alert severity="info" icon={<WarningIcon />}>
            После запроса баллы будут зарезервированы до тех пор, пока администратор не одобрит
            или не отклонит ваш запрос. Зарезервированные баллы нельзя использовать для других
            наград.
          </Alert>
        </Box>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Отмена</Button>
        <Button onClick={handleConfirm} variant="contained" color="primary" startIcon={<StarsIcon />}>
          Подтвердить запрос
        </Button>
      </DialogActions>
    </Dialog>
  )
}
