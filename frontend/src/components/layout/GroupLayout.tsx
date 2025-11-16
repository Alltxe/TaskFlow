import { type FC } from 'react'
import {
  Box,
  Container,
  Tabs,
  Tab,
  Typography,
  CircularProgress,
  Alert,
} from '@mui/material'
import {
  Assignment as TaskIcon,
  EmojiEvents as RewardsIcon,
  Leaderboard as LeaderboardIcon,
  RateReview as ReviewIcon,
  Group as GroupIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material'
import { Outlet, useParams, useNavigate, useLocation } from 'react-router-dom'
import { useQuery } from 'urql'
import { GET_GROUP_QUERY, GET_GROUP_MEMBERS_QUERY } from '@api/queries'
import { useAuthStore } from '@store/authStore'

interface Group {
  id: string
  name: string
  gamificationEnabled: boolean
  createdById: string
}

interface GroupMember {
  userId: string
  role: 'ADMIN' | 'MEMBER'
}

export const GroupLayout: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const navigate = useNavigate()
  const location = useLocation()
  const user = useAuthStore((state) => state.user)

  const [groupResult] = useQuery<{ getGroup: Group }>({
    query: GET_GROUP_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [membersResult] = useQuery<{ getGroupMembers: GroupMember[] }>({
    query: GET_GROUP_MEMBERS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const { data: groupData, fetching: fetchingGroup, error: groupError } = groupResult
  const { data: membersData } = membersResult

  const group = groupData?.getGroup
  const members = membersData?.getGroupMembers || []
  const currentMember = members.find((m) => m.userId === user?.id)
  const isAdmin = currentMember?.role === 'ADMIN'
  const gamificationEnabled = group?.gamificationEnabled ?? false

  // Determine current tab
  const currentPath = location.pathname
  const getCurrentTab = () => {
    if (currentPath.includes('/tasks')) return `/group/${groupId}/tasks`
    if (currentPath.includes('/rewards')) return `/group/${groupId}/rewards`
    if (currentPath.includes('/leaderboard')) return `/group/${groupId}/leaderboard`
    if (currentPath.includes('/review')) return `/group/${groupId}/review`
    if (currentPath.includes('/members')) return `/group/${groupId}/members`
    if (currentPath.includes('/settings')) return `/group/${groupId}/settings`
    return `/group/${groupId}/tasks` // Default
  }

  const handleTabChange = (_event: React.SyntheticEvent, newValue: string) => {
    navigate(newValue)
  }

  if (fetchingGroup) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4, display: 'flex', justifyContent: 'center' }}>
        <CircularProgress />
      </Container>
    )
  }

  if (groupError) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Ошибка загрузки группы: {groupError.message}</Alert>
      </Container>
    )
  }

  if (!group) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Группа не найдена</Alert>
      </Container>
    )
  }

  return (
    <Box>
      {/* Group Header */}
      <Box
        sx={{
          bgcolor: 'background.paper',
          borderBottom: 1,
          borderColor: 'divider',
          py: 2,
        }}
      >
        <Container maxWidth="lg">
          <Typography variant="h5" component="h1" gutterBottom>
            {group.name}
          </Typography>
        </Container>
      </Box>

      {/* Navigation Tabs */}
      <Box sx={{ bgcolor: 'background.paper', borderBottom: 1, borderColor: 'divider' }}>
        <Container maxWidth="lg">
          <Tabs
            value={getCurrentTab()}
            onChange={handleTabChange}
            variant="scrollable"
            scrollButtons="auto"
          >
            <Tab
              label="Задачи"
              value={`/group/${groupId}/tasks`}
              icon={<TaskIcon />}
              iconPosition="start"
            />
            {gamificationEnabled && (
              <>
                <Tab
                  label="Награды"
                  value={`/group/${groupId}/rewards`}
                  icon={<RewardsIcon />}
                  iconPosition="start"
                />
                <Tab
                  label="Рейтинг"
                  value={`/group/${groupId}/leaderboard`}
                  icon={<LeaderboardIcon />}
                  iconPosition="start"
                />
              </>
            )}
            {isAdmin && (
              <>
                <Tab
                  label="Проверка"
                  value={`/group/${groupId}/review`}
                  icon={<ReviewIcon />}
                  iconPosition="start"
                />
                <Tab
                  label="Участники"
                  value={`/group/${groupId}/members`}
                  icon={<GroupIcon />}
                  iconPosition="start"
                />
                <Tab
                  label="Настройки"
                  value={`/group/${groupId}/settings`}
                  icon={<SettingsIcon />}
                  iconPosition="start"
                />
              </>
            )}
          </Tabs>
        </Container>
      </Box>

      {/* Page Content */}
      <Outlet />
    </Box>
  )
}
