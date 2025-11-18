import { type FC, useState, useMemo } from 'react'
import {
  Container,
  Typography,
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Button,
  Chip,
  Menu,
  MenuItem,
  Alert,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  InputAdornment,
  Snackbar,
} from '@mui/material'
import {
  MoreVert as MoreVertIcon,
  ContentCopy as CopyIcon,
  PersonAdd as PersonAddIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material'
import { useParams } from 'react-router-dom'
import { useQuery, useMutation } from 'urql'
import {
  GET_GROUP_MEMBERS_QUERY,
  GET_GROUP_QUERY,
  REMOVE_MEMBER_MUTATION,
  UPDATE_MEMBER_ROLE_MUTATION,
  REGENERATE_INVITE_TOKEN_MUTATION,
  GET_GROUP_TASKS_QUERY,
} from '@api/queries'
import { useAuthStore } from '@store/authStore'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

interface User {
  id: string
  username: string
  avatarUrl?: string
  isAway: boolean
  awayUntil?: string
}

interface GroupMember {
  id: string
  userId: string
  groupId: string
  role: 'ADMIN' | 'MEMBER'
  joinedAt: string
  roleChangedAt: string
  user: User
}

interface Group {
  id: string
  name: string
  inviteToken: string
  createdById: string
}

export const GroupMembers: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const user = useAuthStore((state) => state.user)
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const [selectedMember, setSelectedMember] = useState<GroupMember | null>(null)
  const [inviteDialogOpen, setInviteDialogOpen] = useState(false)
  const [copySuccess, setCopySuccess] = useState(false)

  const [membersResult, reexecuteMembersQuery] = useQuery<{ getGroupMembers: GroupMember[] }>({
    query: GET_GROUP_MEMBERS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [groupResult] = useQuery<{ getGroup: Group }>({
    query: GET_GROUP_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  // Fetch tasks to calculate workload metrics
  const [tasksResult] = useQuery({
    query: GET_GROUP_TASKS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [, removeMemberMutation] = useMutation(REMOVE_MEMBER_MUTATION)
  const [, updateMemberRoleMutation] = useMutation(UPDATE_MEMBER_ROLE_MUTATION)
  const [, regenerateTokenMutation] = useMutation(REGENERATE_INVITE_TOKEN_MUTATION)

  const { data: membersData, fetching: fetchingMembers, error: membersError } = membersResult
  const { data: groupData, fetching: fetchingGroup } = groupResult
  const { data: tasksData } = tasksResult

  const isAdmin = groupData?.getGroup && user && groupData.getGroup.createdById === user.id
  const members = membersData?.getGroupMembers || []

  // Calculate workload metrics for each member
  const memberWorkloads = useMemo(() => {
    if (!tasksData?.getGroupTasks) return new Map()

    const tasks = tasksData.getGroupTasks
    const workloadMap = new Map()

    members.forEach((member: GroupMember) => {
      const memberTasks = tasks.filter((task: any) => task.assigneeId === member.userId)
      const activeTasks = memberTasks.filter(
        (task: any) => task.status === 'PENDING' || task.status === 'AWAITING_APPROVAL'
      )
      const completedTasks = memberTasks.filter((task: any) => task.status === 'COMPLETED')
      const totalWeight = activeTasks.reduce((sum: number, task: any) => sum + (task.weight || 1), 0)
      const completionRate =
        memberTasks.length > 0
          ? Math.round((completedTasks.length / memberTasks.length) * 100)
          : 0

      workloadMap.set(member.userId, {
        activeTasks: activeTasks.length,
        totalWeight,
        completionRate,
      })
    })

    return workloadMap
  }, [tasksData, members])

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, member: GroupMember) => {
    setAnchorEl(event.currentTarget)
    setSelectedMember(member)
  }

  const handleMenuClose = () => {
    setAnchorEl(null)
    setSelectedMember(null)
  }

  const handleRemoveMember = async () => {
    if (!selectedMember || !groupId) return

    try {
      await removeMemberMutation({
        groupId,
        userId: selectedMember.userId,
      })
      reexecuteMembersQuery({ requestPolicy: 'network-only' })
    } catch (err) {
      console.error('Failed to remove member:', err)
    }

    handleMenuClose()
  }

  const handleToggleRole = async () => {
    if (!selectedMember || !groupId) return

    const newRole = selectedMember.role === 'ADMIN' ? 'MEMBER' : 'ADMIN'

    try {
      await updateMemberRoleMutation({
        groupId,
        input: {
          userId: selectedMember.userId,
          role: newRole,
        },
      })
      reexecuteMembersQuery({ requestPolicy: 'network-only' })
    } catch (err) {
      console.error('Failed to update member role:', err)
    }

    handleMenuClose()
  }

  const handleCopyInviteLink = async () => {
    if (!groupData?.getGroup?.inviteToken) return

    const inviteLink = `${window.location.origin}/join/${groupData.getGroup.inviteToken}`

    try {
      await navigator.clipboard.writeText(inviteLink)
      setCopySuccess(true)
    } catch (err) {
      console.error('Failed to copy invite link:', err)
    }
  }

  const handleRegenerateToken = async () => {
    if (!groupId) return

    try {
      await regenerateTokenMutation({ groupId })
      // Refetch group to get new token
      window.location.reload() // Simple solution - in production use proper state management
    } catch (err) {
      console.error('Failed to regenerate token:', err)
    }
  }

  if (fetchingMembers || fetchingGroup) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4, display: 'flex', justifyContent: 'center' }}>
        <CircularProgress />
      </Container>
    )
  }

  if (membersError) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Ошибка загрузки участников: {membersError.message}</Alert>
      </Container>
    )
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 8 }}>
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <Typography variant="h4" component="h1" gutterBottom>
            Участники группы
          </Typography>
          <Typography variant="body1" color="text.secondary">
            {members.length} {members.length === 1 ? 'участник' : 'участников'}
          </Typography>
        </div>
        {isAdmin && (
          <Button
            variant="contained"
            startIcon={<PersonAddIcon />}
            onClick={() => setInviteDialogOpen(true)}
          >
            Пригласить
          </Button>
        )}
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Участник</TableCell>
              <TableCell>Роль</TableCell>
              <TableCell>Статус</TableCell>
              <TableCell align="center">Активных задач</TableCell>
              <TableCell align="center">Нагрузка (вес)</TableCell>
              <TableCell align="center">% выполнения</TableCell>
              <TableCell>Дата вступления</TableCell>
              {isAdmin && <TableCell align="right">Действия</TableCell>}
            </TableRow>
          </TableHead>
          <TableBody>
            {members.map((member) => {
              const workload = memberWorkloads.get(member.userId) || {
                activeTasks: 0,
                totalWeight: 0,
                completionRate: 0,
              }

              return (
                <TableRow key={member.id}>
                  <TableCell>
                    <Typography variant="body1">{member.user.username}</Typography>
                    {member.user.isAway && member.user.awayUntil && (
                      <Typography variant="caption" color="text.secondary">
                        Вернётся{' '}
                        {formatDistanceToNow(new Date(member.user.awayUntil), {
                          addSuffix: true,
                          locale: ru,
                        })}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={member.role === 'ADMIN' ? 'Администратор' : 'Участник'}
                      color={member.role === 'ADMIN' ? 'primary' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    {member.user.isAway ? (
                      <Chip label="Отсутствует" size="small" color="warning" />
                    ) : (
                      <Chip label="Активен" size="small" color="success" />
                    )}
                  </TableCell>
                  <TableCell align="center">
                    <Chip label={workload.activeTasks} size="small" variant="outlined" />
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      label={workload.totalWeight}
                      size="small"
                      variant="outlined"
                      color={workload.totalWeight > 10 ? 'error' : workload.totalWeight > 5 ? 'warning' : 'default'}
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2" color={workload.completionRate >= 80 ? 'success.main' : workload.completionRate >= 50 ? 'warning.main' : 'error.main'}>
                      {workload.completionRate}%
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {formatDistanceToNow(new Date(member.joinedAt), {
                        addSuffix: true,
                        locale: ru,
                      })}
                    </Typography>
                  </TableCell>
                  {isAdmin && (
                    <TableCell align="right">
                      {member.userId !== user?.id && (
                        <IconButton
                          size="small"
                          onClick={(e) => handleMenuOpen(e, member)}
                        >
                          <MoreVertIcon />
                        </IconButton>
                      )}
                    </TableCell>
                  )}
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Context Menu */}
      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={handleMenuClose}>
        <MenuItem onClick={handleToggleRole}>
          {selectedMember?.role === 'ADMIN'
            ? 'Сделать участником'
            : 'Сделать администратором'}
        </MenuItem>
        <MenuItem onClick={handleRemoveMember} sx={{ color: 'error.main' }}>
          Удалить из группы
        </MenuItem>
      </Menu>

      {/* Invite Dialog */}
      <Dialog
        open={inviteDialogOpen}
        onClose={() => setInviteDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Пригласить участника</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" paragraph sx={{ mt: 1 }}>
            Скопируйте ссылку для приглашения и отправьте её новому участнику
          </Typography>

          <TextField
            fullWidth
            value={
              groupData?.getGroup?.inviteToken
                ? `${window.location.origin}/join/${groupData.getGroup.inviteToken}`
                : ''
            }
            InputProps={{
              readOnly: true,
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton onClick={handleCopyInviteLink} edge="end">
                    <CopyIcon />
                  </IconButton>
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />

          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={handleRegenerateToken}
            fullWidth
          >
            Сгенерировать новую ссылку
          </Button>
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            Текущая ссылка станет недействительной
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setInviteDialogOpen(false)}>Закрыть</Button>
        </DialogActions>
      </Dialog>

      {/* Copy Success Snackbar */}
      <Snackbar
        open={copySuccess}
        autoHideDuration={3000}
        onClose={() => setCopySuccess(false)}
        message="Ссылка скопирована в буфер обмена"
      />
    </Container>
  )
}
