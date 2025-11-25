import { type FC, useState, useEffect } from 'react'
import {
  Container,
  Typography,
  Box,
  Paper,
  TextField,
  FormControl,
  RadioGroup,
  FormControlLabel,
  Radio,
  Switch,
  Button,
  Alert,
  CircularProgress,
  Divider,
} from '@mui/material'
import { Save as SaveIcon } from '@mui/icons-material'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation } from 'urql'
import { GET_GROUP_QUERY, UPDATE_GROUP_MUTATION } from '@api/queries'
import { useAuthStore } from '@store/authStore'

interface GroupData {
  id: string
  name: string
  description?: string
  requiresApproval: boolean
  rotationType: 'ROUND_ROBIN' | 'RANDOM' | 'LOAD_BALANCING' | 'DISABLED'
  gamificationEnabled: boolean
  createdById: string
}

export const GroupSettings: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const navigate = useNavigate()
  const user = useAuthStore(state => state.user)

  const [formData, setFormData] = useState<Partial<GroupData>>({
    name: '',
    description: '',
    requiresApproval: true,
    rotationType: 'ROUND_ROBIN',
    gamificationEnabled: true,
  })
  const [hasChanges, setHasChanges] = useState(false)
  const [saveSuccess, setSaveSuccess] = useState(false)

  const [result] = useQuery<{ getGroup: GroupData }>({
    query: GET_GROUP_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [, updateGroupMutation] = useMutation(UPDATE_GROUP_MUTATION)

  const { data, fetching, error } = result

  useEffect(() => {
    if (data?.getGroup) {
      setFormData({
        name: data.getGroup.name,
        description: data.getGroup.description || '',
        requiresApproval: data.getGroup.requiresApproval,
        rotationType: data.getGroup.rotationType,
        gamificationEnabled: data.getGroup.gamificationEnabled,
      })
    }
  }, [data])

  // Check if user is admin (creator of the group)
  const isAdmin = data?.getGroup && user && data.getGroup.createdById === user.id

  const handleSave = async () => {
    if (!groupId || !isAdmin) return

    setSaveSuccess(false)

    try {
      const result = await updateGroupMutation({
        groupId,
        input: {
          name: formData.name,
          description: formData.description || undefined,
          requiresApproval: formData.requiresApproval,
          rotationType: formData.rotationType,
          gamificationEnabled: formData.gamificationEnabled,
        },
      })

      if (result.error) {
        throw new Error(result.error.message)
      }

      setHasChanges(false)
      setSaveSuccess(true)

      // Hide success message after 3 seconds
      setTimeout(() => setSaveSuccess(false), 3000)
    } catch (err) {
      console.error('Failed to update group:', err)
    }
  }

  const handleCancel = () => {
    navigate(`/group/${groupId}/tasks`)
  }

  if (fetching) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8, display: 'flex', justifyContent: 'center' }}>
        <CircularProgress />
      </Container>
    )
  }

  if (error) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">Ошибка загрузки настроек: {error.message}</Alert>
      </Container>
    )
  }

  if (!isAdmin) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">
          У вас нет прав для редактирования настроек этой группы. Только администратор может
          изменять настройки.
        </Alert>
        <Button sx={{ mt: 2 }} onClick={handleCancel}>
          Вернуться к задачам
        </Button>
      </Container>
    )
  }

  return (
    <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Настройки группы
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Управление параметрами группы "{data?.getGroup?.name}"
        </Typography>
      </Box>

      {saveSuccess && (
        <Alert severity="success" sx={{ mb: 3 }}>
          Настройки успешно сохранены
        </Alert>
      )}

      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          Основная информация
        </Typography>
        <Divider sx={{ mb: 3 }} />

        <TextField
          fullWidth
          label="Название группы"
          value={formData.name}
          onChange={e => {
            setFormData({ ...formData, name: e.target.value })
            setHasChanges(true)
          }}
          required
          sx={{ mb: 3 }}
        />

        <TextField
          fullWidth
          label="Описание"
          value={formData.description}
          onChange={e => {
            setFormData({ ...formData, description: e.target.value })
            setHasChanges(true)
          }}
          multiline
          rows={3}
          sx={{ mb: 4 }}
        />

        <Typography variant="h6" gutterBottom sx={{ mt: 4 }}>
          Режим управления
        </Typography>
        <Divider sx={{ mb: 3 }} />

        <FormControlLabel
          control={
            <Switch
              checked={formData.requiresApproval}
              onChange={e => {
                setFormData({ ...formData, requiresApproval: e.target.checked })
                setHasChanges(true)
              }}
            />
          }
          label="Требуется проверка выполнения задач"
        />
        <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 3 }}>
          Если включено, администратор должен одобрить выполненные задачи перед начислением очков
        </Typography>

        <Typography variant="h6" gutterBottom sx={{ mt: 4 }}>
          Режим ротации
        </Typography>
        <Divider sx={{ mb: 3 }} />

        <FormControl component="fieldset">
          <RadioGroup
            value={formData.rotationType}
            onChange={e => {
              setFormData({
                ...formData,
                rotationType: e.target.value as GroupData['rotationType'],
              })
              setHasChanges(true)
            }}
          >
            <FormControlLabel value="ROUND_ROBIN" control={<Radio />} label="Циклическая ротация" />
            <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
              Задачи распределяются по очереди среди участников
            </Typography>

            <FormControlLabel value="RANDOM" control={<Radio />} label="Случайная ротация" />
            <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
              Случайный выбор исполнителя для каждой задачи
            </Typography>

            <FormControlLabel
              value="LOAD_BALANCING"
              control={<Radio />}
              label="Балансировка нагрузки"
            />
            <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
              Автоматическое выравнивание количества задач между участниками
            </Typography>

            <FormControlLabel value="DISABLED" control={<Radio />} label="Без ротации" />
            <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 3 }}>
              Задачи назначаются вручную администратором
            </Typography>
          </RadioGroup>
        </FormControl>

        <Typography variant="h6" gutterBottom sx={{ mt: 4 }}>
          Геймификация
        </Typography>
        <Divider sx={{ mb: 3 }} />

        <FormControlLabel
          control={
            <Switch
              checked={formData.gamificationEnabled}
              onChange={e => {
                setFormData({ ...formData, gamificationEnabled: e.target.checked })
                setHasChanges(true)
              }}
            />
          }
          label="Включить очки и награды"
        />
        <Typography variant="body2" color="text.secondary" sx={{ ml: 4 }}>
          Участники будут получать очки за выполнение задач и смогут обменивать их на награды
        </Typography>
      </Paper>

      <Box sx={{ mt: 4, display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
        <Button onClick={handleCancel}>Отмена</Button>
        <Button
          variant="contained"
          startIcon={<SaveIcon />}
          onClick={handleSave}
          disabled={!hasChanges}
        >
          Сохранить изменения
        </Button>
      </Box>
    </Container>
  )
}
