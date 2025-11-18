import { type FC, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Checkbox,
  Grid,
  Alert,
  CircularProgress,
  Slider,
  Typography,
  ToggleButtonGroup,
  ToggleButton,
  Chip,
  Box,
  Stack,
  IconButton,
} from '@mui/material'
import { DateTimePicker } from '@mui/x-date-pickers/DateTimePicker'
import { TimePicker } from '@mui/x-date-pickers/TimePicker'
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider'
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns'
import { ru } from 'date-fns/locale'
import { useMutation, useQuery } from 'urql'
import { CREATE_TASK_MUTATION, GET_GROUP_MEMBERS_QUERY } from '@api/queries'
import { Delete as DeleteIcon } from '@mui/icons-material'

interface CreateTaskModalProps {
  open: boolean
  onClose: () => void
  groupId: string
  onSuccess?: () => void
}

export const CreateTaskModal: FC<CreateTaskModalProps> = ({
  open,
  onClose,
  groupId,
  onSuccess,
}) => {
  // Form state
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [deadline, setDeadline] = useState<Date | null>(null)
  const [priority, setPriority] = useState<string>('MEDIUM')
  const [points, setPoints] = useState(50)
  const [requiresApproval, setRequiresApproval] = useState(true)
  const [isRecurring, setIsRecurring] = useState(false)
  const [recurrenceType, setRecurrenceType] = useState<string>('NONE') // NONE, HOURLY, DAILY, WEEKLY, MONTHLY
  const [weekDays, setWeekDays] = useState<string[]>([]) // For WEEKLY: ['MO', 'WE', 'FR']
  const [interval, setInterval] = useState(1) // Every N hours/days/weeks/months
  const [endType, setEndType] = useState<string>('NEVER') // NEVER, COUNT, UNTIL
  const [endCount, setEndCount] = useState(10) // Number of occurrences
  const [endDate, setEndDate] = useState<Date | null>(null) // End date
  const [specificTimes, setSpecificTimes] = useState<Date[]>([]) // Specific times for recurrence
  const [assigneeId, setAssigneeId] = useState<string>('auto')
  const [rotationType, setRotationType] = useState<string>('group')
  const [weight, setWeight] = useState(1)

  // Fetch group members for assignment dropdown
  const [{ data: membersData }] = useQuery({
    query: GET_GROUP_MEMBERS_QUERY,
    variables: { groupId },
    pause: !groupId,
  })

  // Create task mutation
  const [{ fetching, error }, createTask] = useMutation(CREATE_TASK_MUTATION)

  // Generate RRULE string from recurrence settings
  const generateRecurrenceRule = (): string | null => {
    if (!isRecurring || recurrenceType === 'NONE') return null

    const parts: string[] = []

    // Base frequency
    parts.push(`FREQ=${recurrenceType}`)

    // Interval (every N hours/days/weeks/months)
    if (interval > 1) {
      parts.push(`INTERVAL=${interval}`)
    }

    // Week days (for WEEKLY)
    if (recurrenceType === 'WEEKLY' && weekDays.length > 0) {
      parts.push(`BYDAY=${weekDays.join(',')}`)
    }

    // Specific times - extract hours, minutes, seconds
    if (specificTimes.length > 0) {
      const hours = new Set<number>()
      const minutes = new Set<number>()
      const seconds = new Set<number>()

      specificTimes.forEach((time) => {
        hours.add(time.getHours())
        minutes.add(time.getMinutes())
        seconds.add(time.getSeconds())
      })

      // Only add if user specified times (not default)
      if (hours.size > 0 && hours.size < 24) {
        parts.push(`BYHOUR=${Array.from(hours).sort((a, b) => a - b).join(',')}`)
      }
      if (minutes.size > 0 && minutes.size < 60) {
        parts.push(`BYMINUTE=${Array.from(minutes).sort((a, b) => a - b).join(',')}`)
      }
      if (seconds.size > 0 && seconds.size < 60) {
        parts.push(`BYSECOND=${Array.from(seconds).sort((a, b) => a - b).join(',')}`)
      }
    }

    // End condition
    if (endType === 'COUNT' && endCount > 0) {
      parts.push(`COUNT=${endCount}`)
    } else if (endType === 'UNTIL' && endDate) {
      const dateStr = endDate.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z'
      parts.push(`UNTIL=${dateStr}`)
    }

    return parts.join(';')
  }

  const handleSubmit = async () => {
    if (!title || !deadline) {
      return
    }

    const input: any = {
      title,
      description: description || null,
      deadline: deadline.toISOString(),
      priority,
      points,
      requiresApproval,
      isRecurring,
      recurrenceRule: generateRecurrenceRule(),
      groupId,
      weight,
    }

    // Handle assignment
    if (assigneeId !== 'auto' && assigneeId !== 'upForGrabs') {
      input.assigneeId = assigneeId
    }

    // Handle rotation type
    if (rotationType !== 'group') {
      input.rotationType = rotationType
    }

    // If "Up-for-Grabs" is selected, disable rotation
    if (assigneeId === 'upForGrabs') {
      input.rotationType = 'DISABLED'
    }

    const result = await createTask({ input })

    if (!result.error) {
      handleClose()
      onSuccess?.()
    }
  }

  const handleClose = () => {
    // Reset form
    setTitle('')
    setDescription('')
    setDeadline(null)
    setPriority('MEDIUM')
    setPoints(50)
    setRequiresApproval(true)
    setIsRecurring(false)
    setRecurrenceType('NONE')
    setWeekDays([])
    setInterval(1)
    setEndType('NEVER')
    setEndCount(10)
    setEndDate(null)
    setSpecificTimes([])
    setAssigneeId('auto')
    setRotationType('group')
    setWeight(1)
    onClose()
  }

  return (
    <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={ru}>
      <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
        <DialogTitle>Создать новую задачу</DialogTitle>
        <DialogContent>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              Ошибка создания задачи: {error.message}
            </Alert>
          )}

          <Grid container spacing={2} sx={{ mt: 0.5 }}>
            {/* Title */}
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                required
                label="Название задачи"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Например: Помыть посуду"
              />
            </Grid>

            {/* Description */}
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Описание"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Подробности задачи (необязательно)"
              />
            </Grid>

            {/* Deadline */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <DateTimePicker
                label="Срок выполнения *"
                value={deadline}
                onChange={(newValue) => setDeadline(newValue)}
                slotProps={{
                  textField: {
                    fullWidth: true,
                    required: true,
                  },
                }}
              />
            </Grid>

            {/* Priority */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <FormControl fullWidth required>
                <InputLabel>Приоритет</InputLabel>
                <Select
                  value={priority}
                  label="Приоритет"
                  onChange={(e) => setPriority(e.target.value)}
                >
                  <MenuItem value="LOW">Низкий</MenuItem>
                  <MenuItem value="MEDIUM">Средний</MenuItem>
                  <MenuItem value="HIGH">Высокий</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            {/* Points */}
            <Grid size={{ xs: 12 }}>
              <Typography gutterBottom>Баллы за выполнение: {points}</Typography>
              <Slider
                value={points}
                onChange={(_, value) => setPoints(value as number)}
                min={1}
                max={1000}
                step={5}
                marks={[
                  { value: 1, label: '1' },
                  { value: 250, label: '250' },
                  { value: 500, label: '500' },
                  { value: 750, label: '750' },
                  { value: 1000, label: '1000' },
                ]}
                valueLabelDisplay="auto"
              />
            </Grid>

            {/* Assignment */}
            <Grid size={{ xs: 12, sm: 6 }}>
              <FormControl fullWidth>
                <InputLabel>Назначить исполнителя</InputLabel>
                <Select
                  value={assigneeId}
                  label="Назначить исполнителя"
                  onChange={(e) => setAssigneeId(e.target.value)}
                >
                  <MenuItem value="auto">Автоматически (по ротации)</MenuItem>
                  <MenuItem value="upForGrabs">Доступна для выбора (бонус +50%)</MenuItem>
                  {membersData?.getGroupMembers?.map((member: any) => (
                    <MenuItem key={member.userId} value={member.userId}>
                      {member.user.username}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>

            {/* Rotation Type (only if auto assignment) */}
            {assigneeId === 'auto' && (
              <Grid size={{ xs: 12, sm: 6 }}>
                <FormControl fullWidth>
                  <InputLabel>Тип ротации</InputLabel>
                  <Select
                    value={rotationType}
                    label="Тип ротации"
                    onChange={(e) => setRotationType(e.target.value)}
                  >
                    <MenuItem value="group">Использовать настройку группы</MenuItem>
                    <MenuItem value="ROUND_ROBIN">Циклическая</MenuItem>
                    <MenuItem value="RANDOM">Случайная</MenuItem>
                    <MenuItem value="LOAD_BALANCING">Балансировка нагрузки</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
            )}

            {/* Weight (for load balancing) */}
            {(rotationType === 'LOAD_BALANCING' ||
              rotationType === 'group') && (
              <Grid size={{ xs: 12 }}>
                <Typography gutterBottom>Вес задачи (для балансировки): {weight}</Typography>
                <Slider
                  value={weight}
                  onChange={(_, value) => setWeight(value as number)}
                  min={1}
                  max={10}
                  step={1}
                  marks
                  valueLabelDisplay="auto"
                />
              </Grid>
            )}

            {/* Options */}
            <Grid size={{ xs: 12 }}>
              <FormControlLabel
                control={
                  <Checkbox
                    checked={requiresApproval}
                    onChange={(e) => setRequiresApproval(e.target.checked)}
                  />
                }
                label="Требует проверки администратором"
              />
            </Grid>

            {/* Recurrence Settings */}
            {/* <Grid size={{ xs: 12 }}>
              <FormControlLabel
                control={
                  <Checkbox
                    checked={isRecurring}
                    onChange={(e) => {
                      setIsRecurring(e.target.checked)
                      if (!e.target.checked) {
                        setRecurrenceType('NONE')
                        setWeekDays([])
                        setInterval(1)
                        setEndType('NEVER')
                        setSpecificTimes([])
                      }
                    }}
                  />
                }
                label="Повторяющаяся задача"
              />
            </Grid> */}

            {/* Recurrence Type Selection */}
            {isRecurring && (
              <>
                <Grid size={{ xs: 12 }}>
                  <Typography variant="body2" gutterBottom sx={{ mb: 1 }}>
                    Частота повторения:
                  </Typography>
                  <ToggleButtonGroup
                    value={recurrenceType}
                    exclusive
                    onChange={(_, value) => {
                      if (value !== null) {
                        setRecurrenceType(value)
                        if (value !== 'WEEKLY') {
                          setWeekDays([])
                        }
                        setSpecificTimes([]) // Reset times on frequency change
                      }
                    }}
                    fullWidth
                    size="small"
                  >
                    <ToggleButton value="HOURLY">Ежечасно</ToggleButton>
                    <ToggleButton value="DAILY">Ежедневно</ToggleButton>
                    <ToggleButton value="WEEKLY">По дням</ToggleButton>
                    <ToggleButton value="MONTHLY">Ежемесячно</ToggleButton>
                  </ToggleButtonGroup>
                </Grid>

                {/* Interval */}
                <Grid size={{ xs: 12 }}>
                  <TextField
                    fullWidth
                    type="number"
                    label={`Каждые N ${recurrenceType === 'HOURLY' ? 'часов' : recurrenceType === 'DAILY' ? 'дней' : recurrenceType === 'WEEKLY' ? 'недель' : 'месяцев'}`}
                    value={interval}
                    onChange={(e) => setInterval(Math.max(1, parseInt(e.target.value) || 1))}
                    inputProps={{ min: 1, max: recurrenceType === 'HOURLY' ? 24 : 365 }}
                    size="small"
                  />
                </Grid>
              </>
            )}

            {/* Week Days Selection (for WEEKLY) */}
            {isRecurring && recurrenceType === 'WEEKLY' && (
              <Grid size={{ xs: 12 }}>
                <Typography variant="body2" gutterBottom sx={{ mb: 1 }}>
                  Дни недели (опционально):
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {[
                    { label: 'Пн', value: 'MO' },
                    { label: 'Вт', value: 'TU' },
                    { label: 'Ср', value: 'WE' },
                    { label: 'Чт', value: 'TH' },
                    { label: 'Пт', value: 'FR' },
                    { label: 'Сб', value: 'SA' },
                    { label: 'Вс', value: 'SU' },
                  ].map((day) => (
                    <Chip
                      key={day.value}
                      label={day.label}
                      onClick={() => {
                        setWeekDays((prev) =>
                          prev.includes(day.value)
                            ? prev.filter((d) => d !== day.value)
                            : [...prev, day.value]
                        )
                      }}
                      color={weekDays.includes(day.value) ? 'primary' : 'default'}
                      variant={weekDays.includes(day.value) ? 'filled' : 'outlined'}
                    />
                  ))}
                </Box>
                {weekDays.length === 0 && (
                  <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, display: 'block' }}>
                    Если не выбрано, повторяется каждую неделю
                  </Typography>
                )}
              </Grid>
            )}

            {/* End Type */}
            {isRecurring && (
              <Grid size={{ xs: 12 }}>
                <Typography variant="body2" gutterBottom sx={{ mb: 1 }}>
                  Окончание повторения:
                </Typography>
                <ToggleButtonGroup
                  value={endType}
                  exclusive
                  onChange={(_, value) => value && setEndType(value)}
                  fullWidth
                  size="small"
                >
                  <ToggleButton value="NEVER">Никогда</ToggleButton>
                  <ToggleButton value="COUNT">После N раз</ToggleButton>
                  <ToggleButton value="UNTIL">До даты</ToggleButton>
                </ToggleButtonGroup>
              </Grid>
            )}

            {/* End Count */}
            {isRecurring && endType === 'COUNT' && (
              <Grid size={{ xs: 12 }}>
                <TextField
                  fullWidth
                  type="number"
                  label="Количество повторений"
                  value={endCount}
                  onChange={(e) => setEndCount(Math.max(1, parseInt(e.target.value) || 1))}
                  inputProps={{ min: 1, max: 999 }}
                  size="small"
                />
              </Grid>
            )}

            {/* End Date */}
            {isRecurring && endType === 'UNTIL' && (
              <Grid size={{ xs: 12 }}>
                <DateTimePicker
                  label="Дата окончания"
                  value={endDate}
                  onChange={(newValue) => setEndDate(newValue)}
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      size: 'small',
                    },
                  }}
                />
              </Grid>
            )}

            {/* Time-based recurrence */}
            {isRecurring && recurrenceType !== 'NONE' && (
              <Grid size={{ xs: 12 }}>
                <Typography variant="body2" gutterBottom sx={{ mb: 1 }}>
                  Конкретное время (опционально):
                </Typography>
                <Alert severity="info" sx={{ mb: 2 }}>
                  {recurrenceType === 'HOURLY' && 'Задача будет создаваться каждый час в указанные минуты/секунды'}
                  {recurrenceType === 'DAILY' && 'Задача будет создаваться каждый день в указанное время'}
                  {recurrenceType === 'WEEKLY' && 'Задача будет создаваться в выбранные дни недели в указанное время'}
                  {recurrenceType === 'MONTHLY' && 'Задача будет создаваться каждый месяц в указанное время'}
                </Alert>
                <Stack spacing={1}>
                  {specificTimes.map((time, index) => (
                    <Box key={index} sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                      <TimePicker
                        label={`Время ${index + 1}`}
                        value={time}
                        onChange={(newValue) => {
                          if (newValue) {
                            const updated = [...specificTimes]
                            updated[index] = newValue
                            setSpecificTimes(updated)
                          }
                        }}
                        ampm={false}
                        views={['hours', 'minutes', 'seconds']}
                        format="HH:mm:ss"
                        slotProps={{
                          textField: {
                            size: 'small',
                            fullWidth: true,
                          },
                        }}
                      />
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => {
                          setSpecificTimes(specificTimes.filter((_, i) => i !== index))
                        }}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </Box>
                  ))}
                  <Button
                    size="small"
                    variant="outlined"
                    onClick={() => {
                      const now = new Date()
                      now.setHours(9, 0, 0, 0)
                      setSpecificTimes([...specificTimes, now])
                    }}
                    disabled={specificTimes.length >= 10}
                  >
                    + Добавить время
                  </Button>
                </Stack>
                <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                  {specificTimes.length === 0 && 'Оставьте пустым для повторения в любое время'}
                  {specificTimes.length > 0 && `Задач будет создано: ${specificTimes.length} раз за ${recurrenceType === 'HOURLY' ? 'час' : recurrenceType === 'DAILY' ? 'день' : recurrenceType === 'WEEKLY' ? 'неделю' : 'месяц'}`}
                </Typography>
              </Grid>
            )}
          </Grid>
        </DialogContent>

        <DialogActions>
          <Button onClick={handleClose} disabled={fetching}>
            Отмена
          </Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            disabled={fetching || !title || !deadline}
            startIcon={fetching && <CircularProgress size={20} />}
          >
            Создать задачу
          </Button>
        </DialogActions>
      </Dialog>
    </LocalizationProvider>
  )
}
