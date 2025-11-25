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
import {
  useGetUserTasksQuery,
  useGetUserGroupsQuery,
  useMyStatisticsQuery,
} from '@api/generated/graphql'
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
    const found = datesList.find(d => d.toDateString() === today.toDateString())
    if (found) setSelectedDate(found)
    else setSelectedDate(datesList[0])
  }, [weekOffset])

  // Filter tasks for selected date and group
  const allTasks = tasksData?.getUserTasks || []
  const filteredTasks = allTasks
    .filter(task => {
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
    <Box
      id="dashboard-page"
      sx={{
        maxWidth: { xs: '100%', sm: 600, md: 900 },
        mx: 'auto',
        px: { xs: 0, sm: 3 },
        pt: { xs: 1, sm: 0 },
      }}
    >
      {/* Header Section */}
      <Box sx={{ mb: { xs: 2, sm: 4 }, px: { xs: 2, sm: 0 } }}>
        <Typography
          id="dashboard-title"
          variant="h4"
          fontWeight={700}
          sx={{ mb: 1, fontSize: { xs: '1.5rem', sm: '2rem' } }}
        >
          Мои задачи
        </Typography>
        <Typography
          variant="body1"
          color="text.secondary"
          sx={{ fontSize: { xs: '0.875rem', sm: '1rem' } }}
        >
          {selectedDate &&
            `${selectedDate.getDate()} ${monthNames[selectedDate.getMonth()]} ${selectedDate.getFullYear()} г.`}
        </Typography>
      </Box>

      {/* Statistics Cards */}
      {stats && (
        <Grid
          id="dashboard-stats"
          container
          spacing={2}
          sx={{ mb: { xs: 2, sm: 4 }, px: { xs: 2, sm: 0 } }}
        >
          <Grid size={{ xs: 6, sm: 6, md: 4 }}>
            <Paper sx={{ p: { xs: 1.5, sm: 2 }, textAlign: 'center' }}>
              <TaskIcon sx={{ fontSize: { xs: 24, sm: 32 }, color: 'primary.main', mb: 1 }} />
              <Typography
                variant="h4"
                fontWeight={700}
                sx={{ fontSize: { xs: '1.5rem', sm: '2rem' } }}
              >
                {stats.tasksAssigned}
              </Typography>
              <Typography
                variant="body2"
                color="text.secondary"
                sx={{ fontSize: { xs: '0.7rem', sm: '0.875rem' } }}
              >
                Назначено задач
              </Typography>
            </Paper>
          </Grid>
          <Grid size={{ xs: 6, sm: 6, md: 4 }}>
            <Paper sx={{ p: { xs: 1.5, sm: 2 }, textAlign: 'center' }}>
              <CheckIcon sx={{ fontSize: { xs: 24, sm: 32 }, color: 'success.main', mb: 1 }} />
              <Typography
                variant="h4"
                fontWeight={700}
                sx={{ fontSize: { xs: '1.5rem', sm: '2rem' } }}
              >
                {stats.tasksCompleted}
              </Typography>
              <Typography
                variant="body2"
                color="text.secondary"
                sx={{ fontSize: { xs: '0.7rem', sm: '0.875rem' } }}
              >
                Выполнено задач
              </Typography>
            </Paper>
          </Grid>
          <Grid size={{ xs: 6, sm: 6, md: 4 }}>
            <Paper sx={{ p: { xs: 1.5, sm: 2 }, textAlign: 'center' }}>
              <PointsIcon sx={{ fontSize: { xs: 24, sm: 32 }, color: 'warning.main', mb: 1 }} />
              <Typography
                variant="h4"
                fontWeight={700}
                sx={{ fontSize: { xs: '1.5rem', sm: '2rem' } }}
              >
                {stats.currentPointBalance}
              </Typography>
              <Typography
                variant="body2"
                color="text.secondary"
                sx={{ fontSize: { xs: '0.7rem', sm: '0.875rem' } }}
              >
                Очков
              </Typography>
            </Paper>
          </Grid>
          {/* <Grid size={{ xs: 6, sm: 6, md: 3 }}>
            <Paper sx={{ p: { xs: 1.5, sm: 2 }, textAlign: 'center' }}>
              <CheckIcon sx={{ fontSize: { xs: 24, sm: 32 }, color: 'info.main', mb: 1 }} />
              <Typography variant="h4" fontWeight={700} sx={{ fontSize: { xs: '1.5rem', sm: '2rem' } }}>
                {Math.round(stats.completionRate)}%
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.7rem', sm: '0.875rem' } }}>
                Процент выполнения
              </Typography>
            </Paper>
          </Grid> */}
        </Grid>
      )}

      {/* Group Filter */}
      <Box sx={{ mb: { xs: 2, sm: 3 }, px: { xs: 2, sm: 0 } }}>
        <FormControl size="small" sx={{ minWidth: { xs: '100%', sm: 200 } }}>
          <InputLabel>Группа</InputLabel>
          <Select
            id="dashboard-group-select"
            value={selectedGroup}
            label="Группа"
            onChange={e => setSelectedGroup(e.target.value)}
          >
            <MenuItem value="all">Все группы</MenuItem>
            {groupsData?.getUserGroups.map(group => (
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
          p: { xs: 1.5, sm: 2.5 },
          mb: { xs: 2, sm: 4 },
          mx: { xs: 2, sm: 0 },
          borderRadius: { xs: 2, sm: 3 },
          border: '1px solid',
          borderColor: 'divider',
          bgcolor: 'background.paper',
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <IconButton
            id="dashboard-prev-period"
            onClick={handlePrevPeriod}
            size="small"
            sx={{ flexShrink: 0 }}
          >
            <ChevronLeftIcon />
          </IconButton>

          <Box
            id="dashboard-week-strip"
            sx={{
              display: 'flex',
              gap: { xs: 0.5, sm: 1.5 },
              flex: 1,
              justifyContent: 'center',
              overflowX: 'auto',
              '&::-webkit-scrollbar': { display: 'none' },
              scrollbarWidth: 'none',
            }}
          >
            {datesList.map(date => {
              const isSelected = selectedDate && date.toDateString() === selectedDate.toDateString()
              const isToday = date.toDateString() === today.toDateString()

              return (
                <Box
                  id={`dashboard-week-date-${date.toISOString()}`}
                  key={date.toISOString()}
                  onClick={() => setSelectedDate(date)}
                  sx={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: { xs: 0.25, sm: 0.5 },
                    py: { xs: 1, sm: 1.5 },
                    px: { xs: 1, sm: 2.5 },
                    minWidth: { xs: 45, sm: 70 },
                    borderRadius: { xs: 1.5, sm: 2 },
                    cursor: 'pointer',
                    bgcolor: isSelected ? 'primary.main' : 'transparent',
                    color: isSelected ? 'primary.contrastText' : 'text.primary',
                    transition: 'all 0.2s',
                    border: '2px solid',
                    borderColor: isSelected
                      ? 'primary.main'
                      : isToday
                        ? 'primary.light'
                        : 'transparent',
                    flexShrink: 0,
                    '&:hover': {
                      bgcolor: isSelected ? 'primary.dark' : 'action.hover',
                    },
                  }}
                >
                  <Typography
                    variant="caption"
                    sx={{
                      fontWeight: 600,
                      fontSize: { xs: '0.6rem', sm: '0.7rem' },
                      textTransform: 'uppercase',
                      letterSpacing: { xs: 0.3, sm: 0.5 },
                      opacity: isSelected ? 1 : 0.7,
                    }}
                  >
                    {getWeekDay(date)}
                  </Typography>
                  <Typography
                    variant="h6"
                    sx={{
                      fontWeight: 700,
                      lineHeight: 1,
                      fontSize: { xs: '1rem', sm: '1.25rem' },
                    }}
                  >
                    {date.getDate()}
                  </Typography>
                </Box>
              )
            })}
          </Box>

          <IconButton
            id="dashboard-next-period"
            onClick={handleNextPeriod}
            size="small"
            sx={{ flexShrink: 0 }}
          >
            <ChevronRightIcon />
          </IconButton>
        </Box>
      </Paper>

      {/* Tasks Section */}
      <Box id="dashboard-tasks-section" sx={{ px: { xs: 2, sm: 0 } }}>
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            mb: { xs: 2, sm: 3 },
            flexWrap: 'wrap',
            gap: 1,
          }}
        >
          <Typography
            variant="h6"
            fontWeight={600}
            sx={{ fontSize: { xs: '1rem', sm: '1.25rem' } }}
          >
            Задачи на выбранную дату
          </Typography>
          <Chip
            label={`${filteredTasks.filter(t => t.status !== 'COMPLETED').length} ожидают`}
            size="small"
            color="primary"
            variant="outlined"
          />
        </Box>

        <Box
          id="dashboard-tasks-list"
          sx={{ display: 'flex', flexDirection: 'column', gap: { xs: 1.5, sm: 2 } }}
        >
          {filteredTasks.length === 0 ? (
            <Card
              elevation={0}
              sx={{
                border: '1px solid',
                borderColor: 'divider',
                borderRadius: 2,
              }}
            >
              <CardContent sx={{ textAlign: 'center', py: { xs: 4, sm: 6 } }}>
                <Typography
                  variant="body1"
                  color="text.secondary"
                  sx={{ fontSize: { xs: '0.875rem', sm: '1rem' } }}
                >
                  Нет запланированных задач на эту дату
                </Typography>
              </CardContent>
            </Card>
          ) : (
            filteredTasks.map(task => {
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
                  <CardContent sx={{ p: { xs: 1.5, sm: 2.5 } }}>
                    <Box
                      sx={{ display: 'flex', alignItems: 'flex-start', gap: { xs: 1.5, sm: 2 } }}
                    >
                      <Box
                        sx={{
                          width: { xs: 32, sm: 40 },
                          height: { xs: 32, sm: 40 },
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
                            fontSize: { xs: 20, sm: 24 },
                          }}
                        />
                      </Box>

                      <Box sx={{ flex: 1, minWidth: 0 }}>
                        <Typography
                          variant="body1"
                          fontWeight={600}
                          sx={{
                            mb: 1,
                            textDecoration: isCompleted ? 'line-through' : 'none',
                            fontSize: { xs: '0.875rem', sm: '1rem' },
                          }}
                        >
                          {task.title}
                        </Typography>

                        <Box
                          sx={{
                            display: 'flex',
                            gap: { xs: 1, sm: 1.5 },
                            alignItems: 'center',
                            flexWrap: 'wrap',
                          }}
                        >
                          <Chip
                            label={getPriorityLabel(task.priority)}
                            size="small"
                            color={getPriorityColor(task.priority)}
                            sx={{
                              fontSize: { xs: '0.65rem', sm: '0.75rem' },
                              height: { xs: 20, sm: 24 },
                            }}
                          />
                          <Chip
                            label={`${task.points} очков`}
                            size="small"
                            variant="outlined"
                            sx={{
                              fontSize: { xs: '0.65rem', sm: '0.75rem' },
                              height: { xs: 20, sm: 24 },
                            }}
                          />
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                            <TimeIcon
                              sx={{ fontSize: { xs: 14, sm: 16 }, color: 'text.secondary' }}
                            />
                            <Typography
                              variant="caption"
                              color="text.secondary"
                              sx={{ fontSize: { xs: '0.7rem', sm: '0.75rem' } }}
                            >
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
