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
} from '@mui/material'
import {
  Menu as MenuIcon,
  Notifications as NotificationsIcon,
  AccountCircle,
} from '@mui/icons-material'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '../../store/authStore'
import { useUIStore } from '../../store/uiStore'

export function Header() {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))
  const navigate = useNavigate()
  
  const user = useAuthStore((state) => state.user)
  const logout = useAuthStore((state) => state.logout)
  const toggleSidebar = useUIStore((state) => state.toggleSidebar)
  
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const [notificationAnchor, setNotificationAnchor] = useState<null | HTMLElement>(null)

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
      position="sticky"
      color="default"
      elevation={1}
      sx={{
        bgcolor: 'background.paper',
        borderBottom: '1px solid',
        borderColor: 'divider',
      }}
    >
      <Toolbar>
        {isMobile && (
          <IconButton
            edge="start"
            onClick={toggleSidebar}
            sx={{ mr: 2 }}
          >
            <MenuIcon />
          </IconButton>
        )}

        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          TaskFlow
        </Typography>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          {/* Notifications */}
          <IconButton onClick={handleNotificationOpen} size="large">
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

          {/* Profile Menu */}
          <IconButton onClick={handleProfileMenuOpen} size="large">
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
            <MenuItem onClick={() => { handleProfileMenuClose(); navigate('/profile') }}>
              Профиль
            </MenuItem>
            <MenuItem onClick={handleLogout}>Выйти</MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  )
}
