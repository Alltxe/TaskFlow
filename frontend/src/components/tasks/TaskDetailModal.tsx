import { type FC, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Box,
  Chip,
  Avatar,
  Divider,
  Alert,
  TextField,
  CircularProgress,
  Grid,
  Stack,
} from '@mui/material'
import {
  CheckCircle as CompleteIcon,
  Cancel as RejectIcon,
  ThumbUp as ApproveIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Assignment as ClaimIcon,
  Flag as FlagIcon,
  Schedule as ClockIcon,
  Person as PersonIcon,
  Star as PointsIcon,
  Repeat as RepeatIcon,
} from '@mui/icons-material'
import { format } from 'date-fns'
import { ru } from 'date-fns/locale'
import { useMutation, useQuery } from 'urql'
import {
  GET_TASK_QUERY,
  COMPLETE_TASK_MUTATION,
  APPROVE_TASK_MUTATION,
  DELETE_TASK_MUTATION,
  CLAIM_TASK_MUTATION,
} from '@api/queries'
import { toast } from '@lib/toast'

interface TaskDetailModalProps {
  open: boolean
  onClose: () => void
  taskId: string
  currentUserId?: string
  isAdmin?: boolean
  onTaskUpdated?: () => void
}

// Helper functions (same as TaskCard)
const getPriorityColor = (priority: string): 'default' | 'warning' | 'error' => {
  switch (priority) {
    case 'HIGH':
      return 'error'
    case 'MEDIUM':
      return 'warning'
    case 'LOW':
    default:
      return 'default'
  }
}

const getPriorityLabel = (priority: string): string => {
  switch (priority) {
    case 'HIGH':
      return 'Высокий'
    case 'MEDIUM':
      return 'Средний'
    case 'LOW':
      return 'Низкий'
    default:
      return priority
  }
}

const getStatusColor = (
  status: string
): 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning' => {
  switch (status) {
    case 'COMPLETED':
      return 'success'
    case 'AWAITING_APPROVAL':
      return 'info'
    case 'PENDING':
      return 'warning'
    case 'OVERDUE':
      return 'error'
    default:
      return 'default'
  }
}

const getStatusLabel = (status: string): string => {
  switch (status) {
    case 'PENDING':
      return 'В ожидании'
    case 'AWAITING_APPROVAL':
      return 'На проверке'
    case 'COMPLETED':
      return 'Завершено'
    case 'OVERDUE':
      return 'Просрочено'
    default:
      return status
  }
}

// Format recurrence rule for display
const formatRecurrenceRule = (rule: string | null): string => {
  if (!rule) return 'Не повторяется'

  const parts: string[] = []

  // Frequency
  let freq = ''
  if (rule.includes('FREQ=HOURLY')) freq = 'Ежечасно'
  else if (rule.includes('FREQ=DAILY')) freq = 'Ежедневно'
  else if (rule.includes('FREQ=WEEKLY')) freq = 'Еженедельно'
  else if (rule.includes('FREQ=MONTHLY')) freq = 'Ежемесячно'
  else if (rule.includes('FREQ=YEARLY')) freq = 'Ежегодно'

  // Interval
  const intervalMatch = rule.match(/INTERVAL=(\d+)/)
  if (intervalMatch && intervalMatch[1] !== '1') {
    freq = `Каждые ${intervalMatch[1]} ${
      rule.includes('FREQ=HOURLY')
        ? 'часов'
        : rule.includes('FREQ=DAILY')
          ? 'дней'
          : rule.includes('FREQ=WEEKLY')
            ? 'недель'
            : rule.includes('FREQ=MONTHLY')
              ? 'месяцев'
              : rule.includes('FREQ=YEARLY')
                ? 'лет'
                : ''
    }`
  }

  parts.push(freq)

  // Week days
  const byDayMatch = rule.match(/BYDAY=([A-Z,]+)/)
  if (byDayMatch) {
    const days = byDayMatch[1]
      .split(',')
      .map(day => {
        switch (day) {
          case 'MO':
            return 'Пн'
          case 'TU':
            return 'Вт'
          case 'WE':
            return 'Ср'
          case 'TH':
            return 'Чт'
          case 'FR':
            return 'Пт'
          case 'SA':
            return 'Сб'
          case 'SU':
            return 'Вс'
          default:
            return day
        }
      })
      .join(', ')
    parts.push(`(${days})`)
  }

  // Time
  const timeInfo: string[] = []
  const byHourMatch = rule.match(/BYHOUR=([0-9,]+)/)
  const byMinuteMatch = rule.match(/BYMINUTE=([0-9,]+)/)
  const bySecondMatch = rule.match(/BYSECOND=([0-9,]+)/)

  if (byHourMatch || byMinuteMatch || bySecondMatch) {
    const hours = byHourMatch ? byHourMatch[1].split(',').map(h => h.padStart(2, '0')) : []
    const minutes = byMinuteMatch ? byMinuteMatch[1].split(',').map(m => m.padStart(2, '0')) : []
    const seconds = bySecondMatch ? bySecondMatch[1].split(',').map(s => s.padStart(2, '0')) : []

    if (hours.length > 0 && minutes.length > 0 && seconds.length > 0) {
      // Full time specified
      const times = hours.flatMap(h => minutes.flatMap(m => seconds.map(s => `${h}:${m}:${s}`)))
      if (times.length <= 3) {
        parts.push(`[${times.join(', ')}]`)
      } else {
        parts.push(`[${times.length} времён]`)
      }
    } else {
      // Partial time
      if (byHourMatch) timeInfo.push(`${byHourMatch[1]} ч`)
      if (byMinuteMatch) timeInfo.push(`${byMinuteMatch[1]} мин`)
      if (bySecondMatch) timeInfo.push(`${bySecondMatch[1]} сек`)
      parts.push(`[${timeInfo.join(':')}]`)
    }
  }

  // End condition
  const countMatch = rule.match(/COUNT=(\d+)/)
  const untilMatch = rule.match(/UNTIL=([0-9TZ]+)/)

  if (countMatch) {
    parts.push(`(${countMatch[1]} раз)`)
  } else if (untilMatch) {
    const dateStr = untilMatch[1]
    const year = dateStr.substring(0, 4)
    const month = dateStr.substring(4, 6)
    const day = dateStr.substring(6, 8)
    parts.push(`(до ${day}.${month}.${year})`)
  }

  return parts.join(' ')
}

export const TaskDetailModal: FC<TaskDetailModalProps> = ({
  open,
  onClose,
  taskId,
  currentUserId,
  isAdmin,
  onTaskUpdated,
}) => {
  const [rejectionReason, setRejectionReason] = useState('')
  const [showRejectForm, setShowRejectForm] = useState(false)

  // Fetch task details
  const [{ data, fetching, error }] = useQuery({
    query: GET_TASK_QUERY,
    variables: { taskId },
    pause: !taskId || !open,
  })

  // Mutations
  const [{ fetching: completing }, completeTask] = useMutation(COMPLETE_TASK_MUTATION)
  const [{ fetching: approving }, approveTask] = useMutation(APPROVE_TASK_MUTATION)
  const [{ fetching: deleting }, deleteTask] = useMutation(DELETE_TASK_MUTATION)
  const [{ fetching: claiming }, claimTask] = useMutation(CLAIM_TASK_MUTATION)

  const task = data?.getTask

  if (!task && !fetching) {
    return null
  }

  const isAssignedToCurrentUser = task?.assigneeId === currentUserId
  const canComplete = isAssignedToCurrentUser && task?.status === 'PENDING'
  const canApprove = isAdmin && task?.status === 'AWAITING_APPROVAL'
  const canEdit = isAdmin || task?.createdById === currentUserId
  const canDelete = isAdmin || task?.createdById === currentUserId
  const canClaim = !task?.assigneeId && task?.status === 'PENDING'

  const handleComplete = async () => {
    const result = await completeTask({ input: { taskId } })
    if (!result.error) {
      toast.taskCompleted(task?.title || 'Задача')
      onTaskUpdated?.()
      onClose()
    } else {
      toast.error('Не удалось завершить задачу')
    }
  }

  const handleApprove = async () => {
    const result = await approveTask({ input: { taskId, approved: true } })
    if (!result.error) {
      toast.taskApproved(task?.title || 'Задача', task?.points || 0)
      onTaskUpdated?.()
      onClose()
    } else {
      toast.error('Не удалось одобрить задачу')
    }
  }

  const handleReject = async () => {
    if (!rejectionReason.trim()) {
      toast.warning('Пожалуйста, укажите причину отклонения')
      return
    }
    const result = await approveTask({
      input: { taskId, approved: false, rejectionReason },
    })
    if (!result.error) {
      toast.taskRejected(task?.title || 'Задача', rejectionReason)
      onTaskUpdated?.()
      onClose()
    } else {
      toast.error('Не удалось отклонить задачу')
    }
  }

  const handleDelete = async () => {
    if (window.confirm('Вы уверены, что хотите удалить эту задачу?')) {
      const result = await deleteTask({ taskId })
      if (!result.error) {
        toast.success('Задача удалена')
        onTaskUpdated?.()
        onClose()
      } else {
        toast.error('Не удалось удалить задачу')
      }
    }
  }

  const handleClaim = async () => {
    const result = await claimTask({ input: { taskId } })
    if (!result.error) {
      toast.taskClaimed(task?.title || 'Задача', task?.points || 0)
      onTaskUpdated?.()
      onClose()
    } else {
      toast.error('Не удалось взять задачу')
    }
  }

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      {fetching ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <DialogContent>
          <Alert severity="error">Ошибка загрузки задачи: {error.message}</Alert>
        </DialogContent>
      ) : task ? (
        <>
          <DialogTitle>
            <Box sx={{ display: 'flex', gap: 1, mb: 1, flexWrap: 'wrap' }}>
              <Chip label={getStatusLabel(task.status)} color={getStatusColor(task.status)} />
              <Chip
                icon={<FlagIcon />}
                label={getPriorityLabel(task.priority)}
                color={getPriorityColor(task.priority)}
                variant="outlined"
              />
              {task.requiresApproval && (
                <Chip label="Требует проверки" size="small" variant="outlined" />
              )}
              {task.isRecurring && <Chip label="Повторяющаяся" size="small" variant="outlined" />}
            </Box>
            {task.title}
          </DialogTitle>

          <DialogContent dividers>
            {/* Up-for-Grabs bonus alert */}
            {(task.wasClaimedFromPool || (!task.assigneeId && task.status === 'PENDING')) && (
              <Alert severity="success" sx={{ mb: 2 }}>
                <Typography variant="body2">
                  {task.wasClaimedFromPool ? (
                    <>
                      <strong>Задача взята из пула!</strong> Вы получите бонус +50% баллов за
                      выполнение этой задачи.
                    </>
                  ) : (
                    <>
                      <strong>Доступна для выбора!</strong> Вы получите бонус +50% баллов за
                      выполнение этой задачи.
                    </>
                  )}
                </Typography>
              </Alert>
            )}

            {/* Description */}
            {task.description && (
              <>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Описание:
                </Typography>
                <Typography variant="body1" paragraph>
                  {task.description}
                </Typography>
                <Divider sx={{ my: 2 }} />
              </>
            )}

            {/* Task Info Grid */}
            <Grid container spacing={2}>
              {/* Deadline */}
              <Grid size={{ xs: 12, sm: 6 }}>
                <Stack direction="row" spacing={1} alignItems="center">
                  <ClockIcon color="action" />
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Срок выполнения
                    </Typography>
                    <Typography variant="body2">
                      {format(new Date(task.deadline), 'dd MMMM yyyy, HH:mm', { locale: ru })}
                    </Typography>
                  </Box>
                </Stack>
              </Grid>

              {/* Points */}
              <Grid size={{ xs: 12, sm: 6 }}>
                <Stack direction="row" spacing={1} alignItems="center">
                  <PointsIcon color="action" />
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Баллы
                    </Typography>
                    <Typography variant="body2">
                      {task.points}
                      {(task.wasClaimedFromPool ||
                        (!task.assigneeId && task.status === 'PENDING')) && (
                        <Chip
                          label="+50% бонус"
                          color="success"
                          size="small"
                          sx={{ ml: 1, height: 20, fontSize: '0.7rem' }}
                        />
                      )}
                    </Typography>
                  </Box>
                </Stack>
              </Grid>

              {/* Assignee */}
              <Grid size={{ xs: 12, sm: 6 }}>
                <Stack direction="row" spacing={1} alignItems="center">
                  <PersonIcon color="action" />
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Исполнитель
                    </Typography>
                    {task.assignee ? (
                      <Stack direction="row" spacing={1} alignItems="center">
                        <Avatar
                          src={task.assignee.avatarUrl || undefined}
                          sx={{ width: 20, height: 20 }}
                        >
                          {task.assignee.username[0].toUpperCase()}
                        </Avatar>
                        <Typography variant="body2">
                          {task.assignee.username}
                          {isAssignedToCurrentUser && ' (вы)'}
                        </Typography>
                      </Stack>
                    ) : (
                      <Typography variant="body2" color="warning.main">
                        Доступна для выбора
                      </Typography>
                    )}
                  </Box>
                </Stack>
              </Grid>

              {/* Created by */}
              {task.createdBy && (
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <PersonIcon color="action" />
                    <Box>
                      <Typography variant="caption" color="text.secondary">
                        Создал
                      </Typography>
                      <Stack direction="row" spacing={1} alignItems="center">
                        <Avatar
                          src={task.createdBy.avatarUrl || undefined}
                          sx={{ width: 20, height: 20 }}
                        >
                          {task.createdBy.username[0].toUpperCase()}
                        </Avatar>
                        <Typography variant="body2">{task.createdBy.username}</Typography>
                      </Stack>
                    </Box>
                  </Stack>
                </Grid>
              )}

              {/* Completed At */}
              {task.completedAt && (
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <ClockIcon color="action" />
                    <Box>
                      <Typography variant="caption" color="text.secondary">
                        Завершено
                      </Typography>
                      <Typography variant="body2">
                        {format(new Date(task.completedAt), 'dd MMM yyyy, HH:mm', { locale: ru })}
                      </Typography>
                    </Box>
                  </Stack>
                </Grid>
              )}

              {/* Weight */}
              {task.weight && task.weight > 1 && (
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Typography variant="caption" color="text.secondary">
                    Вес задачи:
                  </Typography>
                  <Typography variant="body2">{task.weight}</Typography>
                </Grid>
              )}

              {/* Recurrence */}
              {task.isRecurring && (
                <Grid size={{ xs: 12 }}>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <RepeatIcon color="action" />
                    <Box>
                      <Typography variant="caption" color="text.secondary">
                        Повторение
                      </Typography>
                      <Typography variant="body2">
                        {formatRecurrenceRule(task.recurrenceRule)}
                      </Typography>
                    </Box>
                  </Stack>
                </Grid>
              )}
            </Grid>

            {/* Reject Form */}
            {showRejectForm && (
              <Box sx={{ mt: 3 }}>
                <TextField
                  fullWidth
                  multiline
                  rows={3}
                  label="Причина отклонения"
                  value={rejectionReason}
                  onChange={e => setRejectionReason(e.target.value)}
                  placeholder="Укажите, что нужно исправить..."
                  required
                />
              </Box>
            )}
          </DialogContent>

          <DialogActions>
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', flex: 1 }}>
              {/* Left side actions */}
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                {canComplete && (
                  <Button
                    variant="contained"
                    color="success"
                    startIcon={<CompleteIcon />}
                    onClick={handleComplete}
                    disabled={completing}
                  >
                    Завершить
                  </Button>
                )}

                {canClaim && (
                  <Button
                    variant="contained"
                    color="primary"
                    startIcon={<ClaimIcon />}
                    onClick={handleClaim}
                    disabled={claiming}
                  >
                    Взять на себя
                  </Button>
                )}

                {canApprove && !showRejectForm && (
                  <>
                    <Button
                      variant="contained"
                      color="success"
                      startIcon={<ApproveIcon />}
                      onClick={handleApprove}
                      disabled={approving}
                    >
                      Одобрить
                    </Button>
                    <Button
                      variant="outlined"
                      color="error"
                      startIcon={<RejectIcon />}
                      onClick={() => setShowRejectForm(true)}
                      disabled={approving}
                    >
                      Отклонить
                    </Button>
                  </>
                )}

                {canApprove && showRejectForm && (
                  <>
                    <Button
                      id={`task-action-confirm-reject-${taskId}`}
                      variant="contained"
                      color="error"
                      onClick={handleReject}
                      disabled={approving || !rejectionReason.trim()}
                    >
                      Подтвердить отклонение
                    </Button>
                    <Button
                      id={`task-action-cancel-reject-${taskId}`}
                      variant="outlined"
                      onClick={() => {
                        setShowRejectForm(false)
                        setRejectionReason('')
                      }}
                      disabled={approving}
                    >
                      Отменить
                    </Button>
                  </>
                )}
              </Box>

              {/* Right side actions */}
              <Box sx={{ display: 'flex', gap: 1, ml: 'auto' }}>
                {canEdit && (
                  <Button
                    id={`task-action-edit-detail-${taskId}`}
                    startIcon={<EditIcon />}
                    disabled
                  >
                    Редактировать
                  </Button>
                )}
                {canDelete && (
                  <Button
                    id={`task-action-delete-detail-${taskId}`}
                    color="error"
                    startIcon={<DeleteIcon />}
                    onClick={handleDelete}
                    disabled={deleting}
                  >
                    Удалить
                  </Button>
                )}
                <Button id={`task-action-close-detail-${taskId}`} onClick={onClose}>
                  Закрыть
                </Button>
              </Box>
            </Box>
          </DialogActions>
        </>
      ) : null}
    </Dialog>
  )
}
