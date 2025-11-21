import { type FC, useState, useMemo } from 'react'
import { useParams } from 'react-router'
import { useQuery, useMutation } from 'urql'
import {
  Container,
  Typography,
  Box,
  Alert,
  Tabs,
  Tab,
  Button,
  CircularProgress,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  TextField,
  InputAdornment,
  Fab,
  Paper,
  Chip,
} from '@mui/material'
import {
  Add as AddIcon,
  Search as SearchIcon,
} from '@mui/icons-material'
import { TaskCard, CreateTaskModal, TaskDetailModal } from '@components/tasks'
import {
  GET_GROUP_TASKS_QUERY,
  COMPLETE_TASK_MUTATION,
  GET_GROUP_MEMBERS_QUERY,
} from '@api/queries'
import { useAuthStore } from '@store/authStore'

type TabValue = 'all' | 'my' | 'upForGrabs' | 'review'

interface TabPanelProps {
  children?: React.ReactNode
  value: TabValue
  currentValue: TabValue
}

const TabPanel: FC<TabPanelProps> = ({ children, value, currentValue }) => {
  return (
    <div role="tabpanel" hidden={value !== currentValue}>
      {value === currentValue && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  )
}

export const GroupTasks: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const { user } = useAuthStore()

  // UI state
  const [activeTab, setActiveTab] = useState<TabValue>('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [priorityFilter, setPriorityFilter] = useState<string>('all')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null)

  // Fetch group details to check admin status
  const [{ data: membersData }] = useQuery({
    query: GET_GROUP_MEMBERS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  // Fetch tasks
  const [{ data, fetching, error }, refetchTasks] = useQuery({
    query: GET_GROUP_TASKS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  // Complete task mutation
  const [, completeTask] = useMutation(COMPLETE_TASK_MUTATION)

  // Check if current user is admin
  const currentMember = membersData?.getGroupMembers.find(
    (member: any) => member.userId === user?.id
  )
  const isAdmin = currentMember?.role === 'ADMIN'

  // Filter tasks based on active tab and filters
  const filteredTasks = useMemo(() => {
    if (!data?.getGroupTasks) return []

    let tasks = [...data.getGroupTasks]

    // Tab filtering
    switch (activeTab) {
      case 'my':
        tasks = tasks.filter((task) => task.assigneeId === user?.id)
        break
      case 'upForGrabs':
        tasks = tasks.filter((task) => !task.assigneeId)
        break
      case 'review':
        tasks = tasks.filter((task) => task.status === 'AWAITING_APPROVAL')
        break
      case 'all':
      default:
        break
    }

    // Priority filtering
    if (priorityFilter !== 'all') {
      tasks = tasks.filter((task) => task.priority === priorityFilter)
    }

    // Status filtering
    if (statusFilter !== 'all') {
      tasks = tasks.filter((task) => task.status === statusFilter)
    }

    // Search filtering
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      tasks = tasks.filter(
        (task) =>
          task.title.toLowerCase().includes(query) ||
          task.description?.toLowerCase().includes(query)
      )
    }

    // Sort: completed tasks go to the end
    tasks.sort((a, b) => {
      const aCompleted = a.status === 'COMPLETED'
      const bCompleted = b.status === 'COMPLETED'
      if (aCompleted && !bCompleted) return 1
      if (!aCompleted && bCompleted) return -1
      
      // For Up-for-Grabs tab, sort by points (high to low)
      if (activeTab === 'upForGrabs') {
        return b.points - a.points
      }
      
      // Otherwise, sort by deadline
      return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
    })

    return tasks
  }, [data, activeTab, user, priorityFilter, statusFilter, searchQuery])

  // Get task counts for tabs
  const taskCounts = useMemo(() => {
    if (!data?.getGroupTasks) return { all: 0, my: 0, upForGrabs: 0, review: 0 }

    const tasks = data.getGroupTasks
    return {
      all: tasks.length,
      my: tasks.filter((task: any) => task.assigneeId === user?.id).length,
      upForGrabs: tasks.filter((task: any) => !task.assigneeId).length,
      review: tasks.filter((task: any) => task.status === 'AWAITING_APPROVAL').length,
    }
  }, [data, user])

  const handleCompleteTask = async (taskId: string) => {
    const result = await completeTask({ input: { taskId } })
    if (result.error) {
      console.error('Failed to complete task:', result.error)
    } else {
      refetchTasks({ requestPolicy: 'network-only' })
    }
  }

  if (!groupId) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Группа не найдена</Alert>
      </Container>
    )
  }

  if (error) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Ошибка загрузки задач: {error.message}</Alert>
      </Container>
    )
  }

  return (
    <Container maxWidth="xl" sx={{ mt: 3, mb: 8 }}>
      {/* Header */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4" component="h1">
          Задачи группы
        </Typography>
        {isAdmin && (
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            size="large"
            onClick={() => setCreateModalOpen(true)}
          >
            Создать задачу
          </Button>
        )}
      </Box>

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={activeTab}
          onChange={(_, value) => setActiveTab(value)}
          variant="scrollable"
          scrollButtons="auto"
        >
          <Tab
            label={
              <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                Все задачи
                <Chip label={taskCounts.all} size="small" />
              </Box>
            }
            value="all"
          />
          <Tab
            label={
              <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                Мои задачи
                <Chip label={taskCounts.my} size="small" color="primary" />
              </Box>
            }
            value="my"
          />
          <Tab
            label={
              <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                Доступные
                <Chip label={taskCounts.upForGrabs} size="small" color="success" />
              </Box>
            }
            value="upForGrabs"
          />
          <Tab
            label={
              <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                На проверке
                <Chip label={taskCounts.review} size="small" color="info" />
              </Box>
            }
            value="review"
          />
        </Tabs>
      </Paper>

      {/* Filters and View Mode */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, alignItems: 'center' }}>
          {/* View Mode Toggle */}
          {/* <ToggleButtonGroup
            value={viewMode}
            exclusive
            onChange={(_, value) => value && setViewMode(value)}
            size="small"
          >
            <ToggleButton value="list">
              <ListIcon />
            </ToggleButton>
            <ToggleButton value="kanban" disabled>
              <KanbanIcon />
            </ToggleButton>
            <ToggleButton value="calendar" disabled>
              <CalendarIcon />
            </ToggleButton>
          </ToggleButtonGroup> */}

          {/* Search */}
          <TextField
            size="small"
            placeholder="Поиск по названию или описанию..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            sx={{ flexGrow: 1, minWidth: 200 }}
            slotProps={{
              input: {
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon />
                  </InputAdornment>
                ),
              },
            }}
          />

          {/* Priority Filter */}
          <FormControl size="small" sx={{ minWidth: 140 }}>
            <InputLabel>Приоритет</InputLabel>
            <Select
              value={priorityFilter}
              label="Приоритет"
              onChange={(e) => setPriorityFilter(e.target.value)}
            >
              <MenuItem value="all">Все</MenuItem>
              <MenuItem value="HIGH">Высокий</MenuItem>
              <MenuItem value="MEDIUM">Средний</MenuItem>
              <MenuItem value="LOW">Низкий</MenuItem>
            </Select>
          </FormControl>

          {/* Status Filter */}
          <FormControl size="small" sx={{ minWidth: 140 }}>
            <InputLabel>Статус</InputLabel>
            <Select
              value={statusFilter}
              label="Статус"
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <MenuItem value="all">Все</MenuItem>
              <MenuItem value="PENDING">В ожидании</MenuItem>
              <MenuItem value="AWAITING_APPROVAL">На проверке</MenuItem>
              <MenuItem value="COMPLETED">Завершено</MenuItem>
            </Select>
          </FormControl>
        </Box>
      </Paper>

      {/* Task List */}
      {fetching ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
          <CircularProgress />
        </Box>
      ) : (
        <>
          <TabPanel value="all" currentValue={activeTab}>
            {filteredTasks.length === 0 ? (
              <Alert severity="info">Задачи не найдены</Alert>
            ) : (
              <Grid container spacing={2}>
                {filteredTasks.map((task: any) => (
                  <Grid size={{ xs: 12, md: 6, lg: 4 }} key={task.id}>
                    <TaskCard
                      task={task}
                      currentUserId={user?.id}
                      isAdmin={isAdmin}
                      onComplete={handleCompleteTask}
                      onClick={(taskId) => setSelectedTaskId(taskId)}
                    />
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>

          <TabPanel value="my" currentValue={activeTab}>
            {filteredTasks.length === 0 ? (
              <Alert severity="info">У вас нет назначенных задач</Alert>
            ) : (
              <Grid container spacing={2}>
                {filteredTasks.map((task: any) => (
                  <Grid size={{ xs: 12, md: 6, lg: 4 }} key={task.id}>
                    <TaskCard
                      task={task}
                      currentUserId={user?.id}
                      isAdmin={isAdmin}
                      onComplete={handleCompleteTask}
                      onClick={(taskId) => setSelectedTaskId(taskId)}
                    />
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>

          <TabPanel value="upForGrabs" currentValue={activeTab}>
            {filteredTasks.length === 0 ? (
              <Alert severity="info">
                Нет доступных задач для выполнения. Все задачи назначены.
              </Alert>
            ) : (
              <>
                <Alert severity="success" sx={{ mb: 2 }}>
                  Эти задачи доступны для выбора! Вы получите бонус +50% баллов за выполнение.
                </Alert>
                <Grid container spacing={2}>
                  {filteredTasks.map((task: any) => (
                    <Grid size={{ xs: 12, md: 6, lg: 4 }} key={task.id}>
                      <TaskCard
                        task={task}
                        currentUserId={user?.id}
                        isAdmin={isAdmin}
                        onClick={(taskId) => setSelectedTaskId(taskId)}
                      />
                    </Grid>
                  ))}
                </Grid>
              </>
            )}
          </TabPanel>

          <TabPanel value="review" currentValue={activeTab}>
            {filteredTasks.length === 0 ? (
              <Alert severity="info">Нет задач на проверке</Alert>
            ) : (
              <Grid container spacing={2}>
                {filteredTasks.map((task: any) => (
                  <Grid size={{ xs: 12, md: 6, lg: 4 }} key={task.id}>
                    <TaskCard
                      task={task}
                      currentUserId={user?.id}
                      isAdmin={isAdmin}
                      onClick={(taskId) => setSelectedTaskId(taskId)}
                    />
                  </Grid>
                ))}
              </Grid>
            )}
          </TabPanel>
        </>
      )}

      {/* Floating Action Button for mobile */}
      {isAdmin && (
        <Fab
          color="primary"
          aria-label="add task"
          onClick={() => setCreateModalOpen(true)}
          sx={{
            position: 'fixed',
            bottom: 16,
            right: 16,
            display: { xs: 'flex', sm: 'none' },
          }}
        >
          <AddIcon />
        </Fab>
      )}

      {/* Create Task Modal */}
      <CreateTaskModal
        open={createModalOpen}
        onClose={() => setCreateModalOpen(false)}
        groupId={groupId}
        onSuccess={() => {
          refetchTasks({ requestPolicy: 'network-only' })
        }}
      />

      {/* Task Detail Modal */}
      {selectedTaskId && (
        <TaskDetailModal
          open={!!selectedTaskId}
          onClose={() => setSelectedTaskId(null)}
          taskId={selectedTaskId}
          currentUserId={user?.id}
          isAdmin={isAdmin}
          onTaskUpdated={() => {
            refetchTasks({ requestPolicy: 'network-only' })
          }}
        />
      )}
    </Container>
  )
}
