import { type FC } from 'react'
import {
  Container,
  Typography,
  Box,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button,
  IconButton,
  Menu,
  MenuItem,
  Fab,
  Chip,
  CircularProgress,
  Alert,
} from '@mui/material'
import {
  Add as AddIcon,
  MoreVert as MoreVertIcon,
  Group as GroupIcon,
  AccessTime as AccessTimeIcon,
  Task as TaskIcon,
} from '@mui/icons-material'
import { useQuery } from 'urql'
import { GET_USER_GROUPS_QUERY } from '@api/queries'
import { useNavigate } from 'react-router-dom'
import { useState } from 'react'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'
import { CreateGroupWizard } from '@components/groups'

interface Group {
  id: string
  name: string
  description?: string
  inviteToken: string
  requiresApproval: boolean
  rotationType: string
  gamificationEnabled: boolean
  createdAt: string
  updatedAt: string
  createdById: string
}

export const Groups: FC = () => {
  const navigate = useNavigate()
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const [selectedGroup, setSelectedGroup] = useState<string | null>(null)
  const [createDialogOpen, setCreateDialogOpen] = useState(false)

  const [result] = useQuery<{ getUserGroups: Group[] }>({
    query: GET_USER_GROUPS_QUERY,
  })

  const { data, fetching, error } = result

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, groupId: string) => {
    event.stopPropagation()
    setAnchorEl(event.currentTarget)
    setSelectedGroup(groupId)
  }

  const handleMenuClose = () => {
    setAnchorEl(null)
    setSelectedGroup(null)
  }

  const handleGroupClick = (groupId: string) => {
    navigate(`/group/${groupId}/tasks`)
  }

  const handleCreateGroup = () => {
    setCreateDialogOpen(true)
  }

  const handleLeaveGroup = () => {
    // TODO: Implement leave group mutation
    console.log('Leave group:', selectedGroup)
    handleMenuClose()
  }

  const handleGroupSettings = () => {
    if (selectedGroup) {
      navigate(`/group/${selectedGroup}/settings`)
    }
    handleMenuClose()
  }

  if (fetching) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4, display: 'flex', justifyContent: 'center' }}>
        <CircularProgress />
      </Container>
    )
  }

  if (error) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Ошибка загрузки групп: {error.message}</Alert>
      </Container>
    )
  }

  const groups = data?.getUserGroups || []

  return (
    <Container id="groups-page" maxWidth="lg" sx={{ mt: 4, mb: 8 }}>
      <Box sx={{ mb: 4 }}>
        <Typography id="groups-title" variant="h4" component="h1" gutterBottom>
          Мои группы
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Управляйте вашими группами и задачами
        </Typography>
      </Box>

      {groups.length === 0 ? (
        <Box
          sx={{
            textAlign: 'center',
            py: 8,
            px: 2,
          }}
        >
          <GroupIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
          <Typography variant="h5" gutterBottom>
            У вас пока нет групп
          </Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Создайте свою первую группу для совместного управления задачами
          </Typography>
          <Button
            id="groups-create-button"
            variant="contained"
            size="large"
            startIcon={<AddIcon />}
            onClick={handleCreateGroup}
            sx={{ mt: 2 }}
          >
            Создать группу
          </Button>
        </Box>
      ) : (
        <Grid container spacing={3}>
          {groups.map(group => (
            <Grid size={{ xs: 12, sm: 6, md: 4 }} key={group.id}>
              <Card
                id={`group-card-${group.id}`}
                sx={{
                  height: '100%',
                  display: 'flex',
                  flexDirection: 'column',
                  cursor: 'pointer',
                  transition: 'transform 0.2s, box-shadow 0.2s',
                  '&:hover': {
                    transform: 'translateY(-4px)',
                    boxShadow: 4,
                  },
                }}
                onClick={() => handleGroupClick(group.id)}
              >
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                    <Typography id={`group-name-${group.id}`} variant="h6" component="h2" noWrap>
                      {group.name}
                    </Typography>
                    <IconButton
                      id={`group-card-menu-${group.id}`}
                      size="small"
                      onClick={e => handleMenuOpen(e, group.id)}
                      sx={{ ml: 1 }}
                    >
                      <MoreVertIcon />
                    </IconButton>
                  </Box>

                  {group.description && (
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
                      {group.description}
                    </Typography>
                  )}

                  <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mb: 2 }}>
                    {group.gamificationEnabled && (
                      <Chip label="Геймификация" size="small" color="primary" />
                    )}
                    {group.requiresApproval && (
                      <Chip label="С проверкой" size="small" variant="outlined" />
                    )}
                    {group.rotationType !== 'DISABLED' && (
                      <Chip label="Ротация" size="small" variant="outlined" />
                    )}
                  </Box>

                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mt: 'auto' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <GroupIcon fontSize="small" color="action" />
                      <Typography variant="body2" color="text.secondary">
                        {/* TODO: Get actual member count */}- чел.
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <TaskIcon fontSize="small" color="action" />
                      <Typography variant="body2" color="text.secondary">
                        {/* TODO: Get actual task count */}- зад.
                      </Typography>
                    </Box>
                  </Box>

                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 1 }}>
                    <AccessTimeIcon fontSize="small" color="action" />
                    <Typography variant="caption" color="text.secondary">
                      Обновлено{' '}
                      {formatDistanceToNow(new Date(group.updatedAt), {
                        addSuffix: true,
                        locale: ru,
                      })}
                    </Typography>
                  </Box>
                </CardContent>

                <CardActions>
                  <Button
                    size="small"
                    onClick={e => {
                      e.stopPropagation()
                      handleGroupClick(group.id)
                    }}
                    id={`group-open-button-${group.id}`}
                  >
                    Открыть группу
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* Floating Action Button */}
      {groups.length > 0 && (
        <Fab
          id="groups-create-fab"
          color="primary"
          aria-label="add"
          sx={{
            position: 'fixed',
            bottom: 24,
            right: 24,
          }}
          onClick={handleCreateGroup}
        >
          <AddIcon />
        </Fab>
      )}

      {/* Context Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
        onClick={e => e.stopPropagation()}
      >
        <MenuItem id="menuitem-group-settings" onClick={handleGroupSettings}>
          Настройки группы
        </MenuItem>
        <MenuItem id="menuitem-group-leave" onClick={handleLeaveGroup}>
          Покинуть группу
        </MenuItem>
      </Menu>

      {/* Create Group Wizard */}
      <CreateGroupWizard open={createDialogOpen} onClose={() => setCreateDialogOpen(false)} />
    </Container>
  )
}
