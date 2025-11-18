import { type FC } from 'react'
import {
  Card,
  CardContent,
  CardActions,
  Typography,
  Box,
  Chip,
  Avatar,
  IconButton,
  Tooltip,
} from '@mui/material'
import {
  CheckCircle as CompleteIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Flag as FlagIcon,
  Schedule as ClockIcon,
  Person as PersonIcon,
  Repeat as RepeatIcon,
} from '@mui/icons-material'
import { format, isPast, formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

interface Task {
  id: string
  title: string
  description?: string | null
  deadline: string
  priority: string
  status: string
  points: number
  requiresApproval: boolean
  isRecurring?: boolean
  recurrenceRule?: string | null
  wasClaimedFromPool?: boolean
  assignee?: {
    id: string
    username: string
    avatarUrl?: string | null
  } | null
  createdBy?: {
    id: string
    username: string
    avatarUrl?: string | null
  } | null
}

interface TaskCardProps {
  task: Task
  currentUserId?: string
  isAdmin?: boolean
  onComplete?: (taskId: string) => void
  onEdit?: (taskId: string) => void
  onDelete?: (taskId: string) => void
  onClick?: (taskId: string) => void
}

// Priority colors
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

// Priority labels
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

// Status colors
const getStatusColor = (
  status: string
):
  | 'default'
  | 'primary'
  | 'secondary'
  | 'error'
  | 'info'
  | 'success'
  | 'warning' => {
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

// Status labels
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

export const TaskCard: FC<TaskCardProps> = ({
  task,
  currentUserId,
  isAdmin,
  onComplete,
  onEdit,
  onDelete,
  onClick,
}) => {
  const isOverdue = isPast(new Date(task.deadline)) && task.status === 'PENDING'
  const isAssignedToCurrentUser = task.assignee?.id === currentUserId
  const canComplete = isAssignedToCurrentUser && task.status === 'PENDING'
  const canEdit = isAdmin || task.createdBy?.id === currentUserId
  const canDelete = isAdmin || task.createdBy?.id === currentUserId

  const deadlineDate = new Date(task.deadline)
  const deadlineText = formatDistanceToNow(deadlineDate, {
    addSuffix: true,
    locale: ru,
  })

  return (
    <Card
      sx={{
        cursor: onClick ? 'pointer' : 'default',
        '&:hover': onClick
          ? {
              boxShadow: 4,
              transform: 'translateY(-2px)',
              transition: 'all 0.2s ease-in-out',
            }
          : {},
        borderLeft: 6,
        borderLeftColor: isOverdue ? 'error.main' : `${getPriorityColor(task.priority)}.main`,
      }}
      onClick={() => onClick?.(task.id)}
    >
      <CardContent>
        {/* Header with status and priority */}
        <Box sx={{ display: 'flex', gap: 1, mb: 1.5, flexWrap: 'wrap' }}>
          <Chip
            label={getStatusLabel(isOverdue ? 'OVERDUE' : task.status)}
            color={getStatusColor(isOverdue ? 'OVERDUE' : task.status)}
            size="small"
          />
          <Chip
            icon={<FlagIcon />}
            label={getPriorityLabel(task.priority)}
            color={getPriorityColor(task.priority)}
            size="small"
            variant="outlined"
          />
          {task.requiresApproval && (
            <Chip label="Требует проверки" size="small" variant="outlined" />
          )}
          {task.isRecurring && (
            <Chip
              icon={<RepeatIcon />}
              label="Повторяющаяся"
              size="small"
              variant="outlined"
              color="secondary"
            />
          )}
        </Box>

        {/* Title */}
        <Typography variant="h6" component="h3" gutterBottom>
          {task.title}
        </Typography>

        {/* Description (truncated) */}
        {task.description && (
          <Typography
            variant="body2"
            color="text.secondary"
            sx={{
              mb: 2,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
            }}
          >
            {task.description}
          </Typography>
        )}

        {/* Task metadata */}
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, mt: 2 }}>
          {/* Deadline */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <ClockIcon fontSize="small" color={isOverdue ? 'error' : 'action'} />
            <Typography variant="body2" color={isOverdue ? 'error' : 'text.secondary'}>
              {format(deadlineDate, 'dd MMM yyyy, HH:mm', { locale: ru })}
              {' • '}
              {deadlineText}
            </Typography>
          </Box>

          {/* Assignee */}
          {task.assignee && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <PersonIcon fontSize="small" color="action" />
              <Avatar
                src={task.assignee.avatarUrl || undefined}
                sx={{ width: 24, height: 24 }}
              >
                {task.assignee.username[0].toUpperCase()}
              </Avatar>
              <Typography variant="body2" color="text.secondary">
                {task.assignee.username}
                {isAssignedToCurrentUser && ' (вы)'}
              </Typography>
            </Box>
          )}

          {/* Points */}
          <Box>
            <Chip
              label={`${task.points} ${task.points === 1 ? 'балл' : task.points < 5 ? 'балла' : 'баллов'}${task.wasClaimedFromPool ? ' (+50% бонус)' : ''}`}
              color="primary"
              variant="outlined"
              size="small"
            />
          </Box>
        </Box>
      </CardContent>

      {/* Actions */}
      {(canComplete || canEdit || canDelete) && (
        <CardActions sx={{ justifyContent: 'flex-end', gap: 0.5 }}>
          {canComplete && onComplete && (
            <Tooltip title="Завершить задачу">
              <IconButton
                size="small"
                color="success"
                onClick={(e) => {
                  e.stopPropagation()
                  onComplete(task.id)
                }}
              >
                <CompleteIcon />
              </IconButton>
            </Tooltip>
          )}
          {canEdit && onEdit && (
            <Tooltip title="Редактировать">
              <IconButton
                size="small"
                onClick={(e) => {
                  e.stopPropagation()
                  onEdit(task.id)
                }}
              >
                <EditIcon />
              </IconButton>
            </Tooltip>
          )}
          {canDelete && onDelete && (
            <Tooltip title="Удалить">
              <IconButton
                size="small"
                color="error"
                onClick={(e) => {
                  e.stopPropagation()
                  onDelete(task.id)
                }}
              >
                <DeleteIcon />
              </IconButton>
            </Tooltip>
          )}
        </CardActions>
      )}
    </Card>
  )
}
