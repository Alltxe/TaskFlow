import {
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Box,
  Avatar,
  Menu,
  MenuItem,
  Badge,
  useMediaQuery,
  useTheme,
  Button,
  Chip,
  Tooltip,
  CircularProgress,
} from '@mui/material'
import {
  Menu as MenuIcon,
  Notifications as NotificationsIcon,
  AccountCircle,
  Dashboard as DashboardIcon,
  Group as GroupIcon,
  Stars as StarsIcon,
} from '@mui/icons-material'
import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { useQuery } from 'urql'
import { useAuthStore } from '../../store/authStore'
import { useUIStore } from '../../store/uiStore'
import { MY_STATISTICS_QUERY } from '@api/queries'
import { formatPointsCompact } from '@lib/formatPoints'

export function Header() {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))
  const navigate = useNavigate()
  const location = useLocation()

  const user = useAuthStore(state => state.user)
  const logout = useAuthStore(state => state.logout)
  const toggleSidebar = useUIStore(state => state.toggleSidebar)

  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const [notificationAnchor, setNotificationAnchor] = useState<null | HTMLElement>(null)

  // Fetch user statistics for points display
  const [statisticsResult] = useQuery({
    query: MY_STATISTICS_QUERY,
    variables: { groupId: null }, // null for overall stats
  })

  const menuItems = [
    { text: 'Дашборд', icon: <DashboardIcon />, path: '/dashboard' },
    { text: 'Группы', icon: <GroupIcon />, path: '/groups' },
    // { text: 'Мои задачи', icon: <TaskIcon />, path: '/tasks' },
    // { text: 'Награды', icon: <RewardsIcon />, path: '/rewards' },
    // { text: 'Рейтинг', icon: <LeaderboardIcon />, path: '/leaderboard' },
  ]

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget)
  }

  const handleProfileMenuClose = () => {
    setAnchorEl(null)
  }

  const handleNotificationOpen = (event: React.MouseEvent<HTMLElement>) => {
    setNotificationAnchor(event.currentTarget)
  }

  const handleNotificationClose = () => {
    setNotificationAnchor(null)
  }

  const handleLogout = async () => {
    handleProfileMenuClose()
    await logout()
    navigate('/login')
  }

  return (
    <AppBar
      id="header-appbar"
      position="sticky"
      color="default"
      elevation={1}
      sx={{
        bgcolor: 'background.paper',
        borderBottom: '1px solid',
        borderColor: 'divider',
        zIndex: theme.zIndex.appBar,
      }}
    >
      <Toolbar>
        {isMobile && (
          <IconButton
            id="header-toggle-sidebar"
            edge="start"
            onClick={toggleSidebar}
            sx={{ mr: 2 }}
          >
            <MenuIcon />
          </IconButton>
        )}

        <Typography id="header-title" variant="h6" component="div" sx={{ mr: 4 }}>
          TaskFlow
        </Typography>

        {/* Horizontal Navigation Menu - Desktop */}
        {!isMobile && (
          <Box id="header-nav" sx={{ display: 'flex', gap: 1, flexGrow: 1 }}>
            {menuItems.map(item => (
              <Button
                key={item.path}
                startIcon={item.icon}
                onClick={() => navigate(item.path)}
                sx={{
                  color: location.pathname === item.path ? 'primary.main' : 'text.primary',
                  fontWeight: location.pathname === item.path ? 600 : 400,
                  textTransform: 'none',
                  '&:hover': {
                    bgcolor: 'action.hover',
                  },
                }}
              >
                {item.text}
              </Button>
            ))}
          </Box>
        )}

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          {/* Notifications */}
          <IconButton
            id="header-notifications-button"
            onClick={handleNotificationOpen}
            size="large"
          >
            <Badge badgeContent={3} color="error">
              <NotificationsIcon />
            </Badge>
          </IconButton>

          <Menu
            anchorEl={notificationAnchor}
            open={Boolean(notificationAnchor)}
            onClose={handleNotificationClose}
            anchorOrigin={{
              vertical: 'bottom',
              horizontal: 'right',
            }}
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
          >
            <MenuItem onClick={handleNotificationClose}>
              <Typography variant="body2">Новая задача назначена</Typography>
            </MenuItem>
            <MenuItem onClick={handleNotificationClose}>
              <Typography variant="body2">Задача требует утверждения</Typography>
            </MenuItem>
            <MenuItem onClick={handleNotificationClose}>
              <Typography variant="body2">Приближается дедлайн</Typography>
            </MenuItem>
          </Menu>

          {/* Points Badge */}
          {statisticsResult.fetching ? (
            <CircularProgress size={20} sx={{ mx: 1 }} />
          ) : statisticsResult.data?.myStatistics ? (
            <Tooltip title="История транзакций баллов">
              <Chip
                id="header-points-chip"
                icon={<StarsIcon />}
                label={formatPointsCompact(statisticsResult.data.myStatistics.currentPointBalance)}
                color="primary"
                variant="outlined"
                onClick={() => navigate('/profile')}
                sx={{
                  cursor: 'pointer',
                  fontWeight: 600,
                  '&:hover': {
                    bgcolor: 'primary.50',
                  },
                }}
              />
            </Tooltip>
          ) : null}

          {/* Profile Menu */}
          <IconButton id="header-profile-button" onClick={handleProfileMenuOpen} size="large">
            {user?.avatarUrl ? (
              <Avatar src={user.avatarUrl} sx={{ width: 32, height: 32 }} />
            ) : (
              <AccountCircle />
            )}
          </IconButton>

          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleProfileMenuClose}
            anchorOrigin={{
              vertical: 'bottom',
              horizontal: 'right',
            }}
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
          >
            <MenuItem
              id="menuitem-profile"
              onClick={() => {
                handleProfileMenuClose()
                navigate('/profile')
              }}
            >
              Профиль
            </MenuItem>
            <MenuItem id="menuitem-logout" onClick={handleLogout}>
              Выйти
            </MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  )
}
