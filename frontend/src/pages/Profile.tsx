import { type FC, useState } from 'react'
import { useMutation, useQuery } from 'urql'
import {
  Container,
  Typography,
  Box,
  Paper,
  Grid,
  Avatar,
  Chip,
  Alert,
  Button,
  Divider,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Switch,
  FormControlLabel,
} from '@mui/material'
import {
  Edit as EditIcon,
  Spa as AwayIcon,
  Save as SaveIcon,
  Cancel as CancelIcon,
} from '@mui/icons-material'
import { DatePicker } from '@mui/x-date-pickers'
import { useAuthStore } from '@store/authStore'
import { format } from 'date-fns'
import { ru } from 'date-fns/locale'
import {
  UPDATE_USER_MUTATION,
  SET_AWAY_STATUS_MUTATION,
  MY_STATISTICS_QUERY,
} from '@api/queries'
import { toast } from '@lib/toast'

/**
 * User Profile Page
 * Phase 5.3 & Phase 8: User profile with "Away" status management
 */
export const Profile: FC = () => {
  const { user, updateUser: updateAuthUser } = useAuthStore()
  const [editModalOpen, setEditModalOpen] = useState(false)
  const [awayModalOpen, setAwayModalOpen] = useState(false)

  // Form state
  const [username, setUsername] = useState(user?.username || '')
  const [avatarUrl, setAvatarUrl] = useState(user?.avatarUrl || '')
  const [isAway, setIsAway] = useState(user?.isAway || false)
  const [awayUntil, setAwayUntil] = useState<Date | null>(
    user?.awayUntil ? new Date(user.awayUntil) : null
  )

  // GraphQL mutations
  const [, updateUser] = useMutation(UPDATE_USER_MUTATION)
  const [, setAwayStatus] = useMutation(SET_AWAY_STATUS_MUTATION)

  // Statistics query
  const [{ data: statsData }] = useQuery({
    query: MY_STATISTICS_QUERY,
    variables: { groupId: null }, // Overall stats
    pause: !user,
  })

  const handleEditProfile = async () => {
    const result = await updateUser({
      input: {
        username: username !== user?.username ? username : undefined,
        avatarUrl: avatarUrl !== user?.avatarUrl ? avatarUrl : undefined,
      },
    })

    if (result.error) {
      toast.error('Ошибка при обновлении профиля')
      console.error(result.error)
    } else if (result.data?.updateUser) {
      updateAuthUser(result.data.updateUser)
      toast.success('Профиль успешно обновлен')
      setEditModalOpen(false)
    }
  }

  const handleSetAwayStatus = async () => {
    const result = await setAwayStatus({
      input: {
        isAway,
        awayUntil: isAway && awayUntil ? awayUntil.toISOString() : null,
      },
    })

    if (result.error) {
      toast.error('Ошибка при установке статуса')
      console.error(result.error)
    } else if (result.data?.setUserAwayStatus) {
      updateAuthUser(result.data.setUserAwayStatus)
      toast.success(
        isAway
          ? 'Статус "Отсутствует" установлен'
          : 'Статус "Отсутствует" снят'
      )
      setAwayModalOpen(false)
    }
  }

  const handleOpenEditModal = () => {
    setUsername(user?.username || '')
    setAvatarUrl(user?.avatarUrl || '')
    setEditModalOpen(true)
  }

  const handleOpenAwayModal = () => {
    setIsAway(user?.isAway || false)
    setAwayUntil(user?.awayUntil ? new Date(user.awayUntil) : null)
    setAwayModalOpen(true)
  }

  if (!user) {
    return (
      <Container maxWidth="md" sx={{ mt: 20 }}>
        <Alert severity="error">Пользователь не авторизован</Alert>
      </Container>
    )
  }

  const stats = statsData?.myStatistics

  return (
    <Container maxWidth="md" sx={{ mt: 25, mb: 8 }}>
      {/* Profile Header */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
          <Avatar
            src={user.avatarUrl || undefined}
            alt={user.username}
            sx={{ width: 80, height: 80 }}
          >
            {user.username[0].toUpperCase()}
          </Avatar>
          <Box sx={{ flexGrow: 1 }}>
            <Typography variant="h4" component="h1" gutterBottom>
              {user.username}
            </Typography>
            <Typography variant="body1" color="text.secondary" gutterBottom>
              {user.email}
            </Typography>
            <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
              {user.isAway ? (
                <Chip
                  icon={<AwayIcon />}
                  label={`Отсутствует${user.awayUntil ? ` до ${format(new Date(user.awayUntil), 'dd MMM yyyy', { locale: ru })}` : ''}`}
                  color="warning"
                />
              ) : (
                <Chip label="Активен" color="success" />
              )}
            </Box>
          </Box>
          <Button variant="outlined" startIcon={<EditIcon />} onClick={handleOpenEditModal}>
            Редактировать
          </Button>
        </Box>
      </Paper>

      {/* User Information */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Информация
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Grid container spacing={2}>
          <Grid size={{ xs: 6 }}>
            <Typography variant="caption" color="text.secondary">
              Email
            </Typography>
            <Typography variant="body1">{user.email}</Typography>
          </Grid>
          <Grid size={{ xs: 6 }}>
            <Typography variant="caption" color="text.secondary">
              Имя пользователя
            </Typography>
            <Typography variant="body1">{user.username}</Typography>
          </Grid>
          <Grid size={{ xs: 6 }}>
            <Typography variant="caption" color="text.secondary">
              Дата регистрации
            </Typography>
            <Typography variant="body1">
              {format(new Date(user.createdAt), 'dd MMMM yyyy', { locale: ru })}
            </Typography>
          </Grid>
          <Grid size={{ xs: 6 }}>
            <Typography variant="caption" color="text.secondary">
              Статус
            </Typography>
            <Typography variant="body1">
              {user.isAway ? 'Отсутствует' : 'Активен'}
            </Typography>
          </Grid>
        </Grid>
      </Paper>

      {/* Away Status Management */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Управление статусом "Отсутствует"
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
          Установите период отсутствия, чтобы автоматически исключить себя из ротации задач.
        </Typography>
        <Button variant="contained" startIcon={<AwayIcon />} onClick={handleOpenAwayModal}>
          {user.isAway ? 'Изменить период отсутствия' : 'Установить период отсутствия'}
        </Button>
      </Paper>

      {/* Statistics Panel */}
      {stats && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" gutterBottom>
            Статистика
          </Typography>
          <Divider sx={{ mb: 2 }} />
          <Grid container spacing={3}>
            <Grid size={{ xs: 6, md: 3 }}>
              <Typography variant="caption" color="text.secondary">
                Баланс баллов
              </Typography>
              <Typography variant="h5">{stats.currentPointBalance}</Typography>
            </Grid>
            <Grid size={{ xs: 6, md: 3 }}>
              <Typography variant="caption" color="text.secondary">
                Задач выполнено
              </Typography>
              <Typography variant="h5">{stats.tasksCompleted}</Typography>
            </Grid>
            <Grid size={{ xs: 6, md: 3 }}>
              <Typography variant="caption" color="text.secondary">
                Процент выполнения
              </Typography>
              <Typography variant="h5">{Math.round(stats.completionRate)}%</Typography>
            </Grid>
            <Grid size={{ xs: 6, md: 3 }}>
              <Typography variant="caption" color="text.secondary">
                Вовремя выполнено
              </Typography>
              <Typography variant="h5">{Math.round(stats.onTimePercentage)}%</Typography>
            </Grid>
          </Grid>
        </Paper>
      )}

      {/* Edit Profile Modal */}
      <Dialog open={editModalOpen} onClose={() => setEditModalOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Редактировать профиль</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            label="Имя пользователя"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            sx={{ mt: 2, mb: 2 }}
            helperText="От 3 до 30 символов, только буквы, цифры и подчеркивание"
          />
          <TextField
            fullWidth
            label="URL аватара"
            value={avatarUrl}
            onChange={(e) => setAvatarUrl(e.target.value)}
            placeholder="https://example.com/avatar.jpg"
            helperText="Необязательно. Введите URL вашего изображения"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditModalOpen(false)} startIcon={<CancelIcon />}>
            Отмена
          </Button>
          <Button onClick={handleEditProfile} variant="contained" startIcon={<SaveIcon />}>
            Сохранить
          </Button>
        </DialogActions>
      </Dialog>

      {/* Away Status Modal */}
      <Dialog open={awayModalOpen} onClose={() => setAwayModalOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Управление статусом отсутствия</DialogTitle>
        <DialogContent>
          <FormControlLabel
            control={<Switch checked={isAway} onChange={(e) => setIsAway(e.target.checked)} />}
            label="Я отсутствую"
            sx={{ mt: 2, mb: 2 }}
          />
          {isAway && (
            <>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Выберите дату возвращения. В это время вы будете исключены из автоматической ротации
                задач.
              </Typography>
              <DatePicker
                label="Дата возвращения"
                value={awayUntil}
                onChange={(newValue) => setAwayUntil(newValue)}
                minDate={new Date()}
                slotProps={{
                  textField: {
                    fullWidth: true,
                    helperText: 'Необязательно. Оставьте пустым для бессрочного отсутствия',
                  },
                }}
              />
            </>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAwayModalOpen(false)} startIcon={<CancelIcon />}>
            Отмена
          </Button>
          <Button onClick={handleSetAwayStatus} variant="contained" startIcon={<SaveIcon />}>
            Сохранить
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  )
}
