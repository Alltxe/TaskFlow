import {
  Box,
  Typography,
  Paper,
  Chip,
  IconButton,
  Card,
  CardContent,
  Grid,
  CircularProgress,
  Alert,
  FormControl,
  Select,
  MenuItem,
  InputLabel,
} from '@mui/material'
import {
  ChevronLeft as ChevronLeftIcon,
  ChevronRight as ChevronRightIcon,
  AccessTime as TimeIcon,
  CheckCircleOutline as CheckIcon,
  Assignment as TaskIcon,
  Stars as PointsIcon,
} from '@mui/icons-material'
import { useState, useEffect } from 'react'
import { useGetUserTasksQuery, useGetUserGroupsQuery, useMyStatisticsQuery } from '@api/generated/graphql'
import { format, isWithinInterval, startOfDay, endOfDay } from 'date-fns'
import { ru } from 'date-fns/locale'

export function DashboardPage() {
  const today = new Date()
  const weekDays = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
  const monthNames = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ]

  const [weekOffset, setWeekOffset] = useState(0)
  const [selectedDate, setSelectedDate] = useState<Date | null>(null)
  const [selectedGroup, setSelectedGroup] = useState<string>('all')

  // Fetch user's tasks
  const [tasksResult] = useGetUserTasksQuery()

  // Fetch user's groups
  const [groupsResult] = useGetUserGroupsQuery()

  // Fetch statistics
  const [statsResult] = useMyStatisticsQuery({
    variables: { groupId: selectedGroup === 'all' ? undefined : selectedGroup },
  })

  const { data: tasksData, fetching: fetchingTasks, error: tasksError } = tasksResult
  const { data: groupsData } = groupsResult
  const { data: statsData } = statsResult

  const getWeekDay = (date: Date) => weekDays[date.getDay()]

  const getMonday = (date: Date) => {
    const d = new Date(date)
    const day = d.getDay()
    const diff = day === 0 ? -6 : 1 - day
    d.setDate(d.getDate() + diff)
    d.setHours(0, 0, 0, 0)
    return d
  }

  const getWeekDates = () => {
    const monday = getMonday(today)
    const dates = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday)
      d.setDate(monday.getDate() + weekOffset * 7 + i)
      dates.push(d)
    }
    return dates
  }

  const datesList = getWeekDates()

  const handlePrevPeriod = () => setWeekOffset(weekOffset - 1)
  const handleNextPeriod = () => setWeekOffset(weekOffset + 1)

  useEffect(() => {
    const found = datesList.find((d) => d.toDateString() === today.toDateString())
    if (found) setSelectedDate(found)
    else setSelectedDate(datesList[0])
  }, [weekOffset])

  // Filter tasks for selected date and group
  const allTasks = tasksData?.getUserTasks || []
  const filteredTasks = allTasks
    .filter((task) => {
      const taskDate = new Date(task.deadline)
      const dateMatch =
        selectedDate &&
        isWithinInterval(taskDate, {
          start: startOfDay(selectedDate),
          end: endOfDay(selectedDate),
        })
      const groupMatch = selectedGroup === 'all' || task.groupId === selectedGroup
      return dateMatch && groupMatch
    })
    .sort((a, b) => {
      // Completed tasks go to the end
      const aCompleted = a.status === 'COMPLETED'
      const bCompleted = b.status === 'COMPLETED'
      if (aCompleted && !bCompleted) return 1
      if (!aCompleted && bCompleted) return -1
      // If both have same completion status, sort by deadline
      return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
    })

  const stats = statsData?.myStatistics

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'HIGH':
        return 'error'
      case 'MEDIUM':
        return 'warning'
      case 'LOW':
        return 'success'
      default:
        return 'default'
    }
  }

  const getPriorityLabel = (priority: string) => {
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

  if (fetchingTasks) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 8 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (tasksError) {
    return (
      <Box sx={{ mt: 4 }}>
        <Alert severity="error">Ошибка загрузки задач: {tasksError.message}</Alert>
      </Box>
    )
  }

  return (
    <Box sx={{ maxWidth: 1400, mx: 'auto' }}>
      {/* Header Section */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight={700} sx={{ mb: 1 }}>
          Мои задачи
        </Typography>
        <Typography variant="body1" color="text.secondary">
          {selectedDate &&
            `${selectedDate.getDate()} ${monthNames[selectedDate.getMonth()]} ${selectedDate.getFullYear()} г.`}
        </Typography>
      </Box>

      {/* Statistics Cards */}
      {stats && (
        <Grid container spacing={2} sx={{ mb: 4 }}>
          <Grid size={{ xs: 12, sm: 6, md: 3 }}>
            <Paper sx={{ p: 2, textAlign: 'center' }}>
              <TaskIcon sx={{ fontSize: 32, color: 'primary.main', mb: 1 }} />
              <Typography variant="h4" fontWeight={700}>
                {stats.tasksAssigned}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Назначено задач
              </Typography>
            </Paper>
          </Grid>
          <Grid size={{ xs: 12, sm: 6, md: 3 }}>
            <Paper sx={{ p: 2, textAlign: 'center' }}>
              <CheckIcon sx={{ fontSize: 32, color: 'success.main', mb: 1 }} />
              <Typography variant="h4" fontWeight={700}>
                {stats.tasksCompleted}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Выполнено задач
              </Typography>
            </Paper>
          </Grid>
          <Grid size={{ xs: 12, sm: 6, md: 3 }}>
            <Paper sx={{ p: 2, textAlign: 'center' }}>
              <PointsIcon sx={{ fontSize: 32, color: 'warning.main', mb: 1 }} />
              <Typography variant="h4" fontWeight={700}>
                {stats.currentPointBalance}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Очков
              </Typography>
            </Paper>
          </Grid>
          <Grid size={{ xs: 12, sm: 6, md: 3 }}>
            <Paper sx={{ p: 2, textAlign: 'center' }}>
              <CheckIcon sx={{ fontSize: 32, color: 'info.main', mb: 1 }} />
              <Typography variant="h4" fontWeight={700}>
                {Math.round(stats.completionRate * 100)}%
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Процент выполнения
              </Typography>
            </Paper>
          </Grid>
        </Grid>
      )}

      {/* Group Filter */}
      <Box sx={{ mb: 3 }}>
        <FormControl size="small" sx={{ minWidth: 200 }}>
          <InputLabel>Группа</InputLabel>
          <Select
            value={selectedGroup}
            label="Группа"
            onChange={(e) => setSelectedGroup(e.target.value)}
          >
            <MenuItem value="all">Все группы</MenuItem>
            {groupsData?.getUserGroups.map((group) => (
              <MenuItem key={group.id} value={group.id}>
                {group.name}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      {/* Week Calendar Strip */}
      <Paper 
        elevation={0}
        sx={{ 
          p: 2.5,
          mb: 4,
          borderRadius: 3,
          border: '1px solid',
          borderColor: 'divider',
          bgcolor: 'background.paper'
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <IconButton onClick={handlePrevPeriod} size="small">
            <ChevronLeftIcon />
          </IconButton>
          
          <Box sx={{ display: 'flex', gap: 1.5, flex: 1, justifyContent: 'center' }}>
            {datesList.map((date) => {
              const isSelected = selectedDate && date.toDateString() === selectedDate.toDateString()
              const isToday = date.toDateString() === today.toDateString()
              
              return (
                <Box
                  key={date.toISOString()}
                  onClick={() => setSelectedDate(date)}
                  sx={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: 0.5,
                    py: 1.5,
                    px: 2.5,
                    minWidth: 70,
                    borderRadius: 2,
                    cursor: 'pointer',
                    bgcolor: isSelected ? 'primary.main' : 'transparent',
                    color: isSelected ? 'primary.contrastText' : 'text.primary',
                    transition: 'all 0.2s',
                    border: '2px solid',
                    borderColor: isSelected ? 'primary.main' : isToday ? 'primary.light' : 'transparent',
                    '&:hover': {
                      bgcolor: isSelected ? 'primary.dark' : 'action.hover',
                    },
                  }}
                >
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      fontWeight: 600,
                      fontSize: '0.7rem',
                      textTransform: 'uppercase',
                      letterSpacing: 0.5,
                      opacity: isSelected ? 1 : 0.7
                    }}
                  >
                    {getWeekDay(date)}
                  </Typography>
                  <Typography 
                    variant="h6" 
                    sx={{ 
                      fontWeight: 700,
                      lineHeight: 1
                    }}
                  >
                    {date.getDate()}
                  </Typography>
                </Box>
              )
            })}
          </Box>

          <IconButton onClick={handleNextPeriod} size="small">
            <ChevronRightIcon />
          </IconButton>
        </Box>
      </Paper>

      {/* Tasks Section */}
      <Box>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
          <Typography variant="h6" fontWeight={600}>
            Задачи на выбранную дату
          </Typography>
          <Chip
            label={`${filteredTasks.filter((t) => t.status !== 'COMPLETED').length} ожидают`}
            size="small"
            color="primary"
            variant="outlined"
          />
        </Box>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {filteredTasks.length === 0 ? (
            <Card
              elevation={0}
              sx={{
                border: '1px solid',
                borderColor: 'divider',
                borderRadius: 2,
              }}
            >
              <CardContent sx={{ textAlign: 'center', py: 6 }}>
                <Typography variant="body1" color="text.secondary">
                  Нет запланированных задач на эту дату
                </Typography>
              </CardContent>
            </Card>
          ) : (
            filteredTasks.map((task) => {
              const isCompleted = task.status === 'COMPLETED'
              const taskDate = new Date(task.deadline)
              const timeStr = format(taskDate, 'HH:mm', { locale: ru })

              return (
                <Card
                  key={task.id}
                  elevation={0}
                  sx={{
                    border: '1px solid',
                    borderColor: isCompleted ? 'success.light' : 'divider',
                    borderRadius: 2,
                    transition: 'all 0.2s',
                    opacity: isCompleted ? 0.7 : 1,
                    '&:hover': {
                      borderColor: 'primary.main',
                      boxShadow: 2,
                    },
                  }}
                >
                  <CardContent sx={{ p: 2.5 }}>
                    <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                      <Box
                        sx={{
                          width: 40,
                          height: 40,
                          borderRadius: 1.5,
                          bgcolor: isCompleted ? 'success.light' : 'primary.light',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          flexShrink: 0,
                        }}
                      >
                        <CheckIcon
                          sx={{
                            color: isCompleted ? 'success.dark' : 'primary.main',
                            fontSize: 24,
                          }}
                        />
                      </Box>

                      <Box sx={{ flex: 1 }}>
                        <Typography
                          variant="body1"
                          fontWeight={600}
                          sx={{
                            mb: 1,
                            textDecoration: isCompleted ? 'line-through' : 'none',
                          }}
                        >
                          {task.title}
                        </Typography>

                        <Box sx={{ display: 'flex', gap: 1.5, alignItems: 'center', flexWrap: 'wrap' }}>
                          <Chip
                            label={getPriorityLabel(task.priority)}
                            size="small"
                            color={getPriorityColor(task.priority)}
                            sx={{ fontSize: '0.75rem' }}
                          />
                          <Chip
                            label={`${task.points} очков`}
                            size="small"
                            variant="outlined"
                            sx={{ fontSize: '0.75rem' }}
                          />
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                            <TimeIcon sx={{ fontSize: 16, color: 'text.secondary' }} />
                            <Typography variant="caption" color="text.secondary">
                              {timeStr}
                            </Typography>
                          </Box>
                        </Box>
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              )
            })
          )}
        </Box>
      </Box>
    </Box>
  )
}
