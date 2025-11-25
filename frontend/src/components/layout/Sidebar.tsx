import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Box,
  Typography,
  Divider,
  useMediaQuery,
  useTheme,
} from '@mui/material'
import {
  Dashboard as DashboardIcon,
  Group as GroupIcon,
  Person as PersonIcon,
} from '@mui/icons-material'
import { useNavigate, useLocation } from 'react-router-dom'
import { useUIStore } from '../../store/uiStore'

const DRAWER_WIDTH = 240

export function Sidebar() {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))
  const navigate = useNavigate()
  const location = useLocation()

  const sidebarOpen = useUIStore(state => state.sidebarOpen)
  const toggleSidebar = useUIStore(state => state.toggleSidebar)

  const menuItems = [
    { text: 'Дашборд', icon: <DashboardIcon />, path: '/dashboard' },
    { text: 'Группы', icon: <GroupIcon />, path: '/groups' },
    // { text: 'Мои задачи', icon: <TaskIcon />, path: '/tasks' },
    // { text: 'Награды', icon: <RewardsIcon />, path: '/rewards' },
    // { text: 'Рейтинг', icon: <LeaderboardIcon />, path: '/leaderboard' },
    { text: 'Профиль', icon: <PersonIcon />, path: '/profile' },
  ]

  const handleNavigate = (path: string) => {
    navigate(path)
    if (isMobile) {
      toggleSidebar()
    }
  }

  const drawerContent = (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Box id="sidebar-brand" sx={{ p: 2 }}>
        <Typography variant="h6" fontWeight={600} color="primary">
          TaskFlow
        </Typography>
        <Typography variant="caption" color="text.secondary">
          Управление задачами
        </Typography>
      </Box>

      <Divider />

      <List id="sidebar-menu" sx={{ flex: 1, pt: 2 }}>
        {menuItems.map(item => (
          <ListItem key={item.path} disablePadding sx={{ mb: 0.5 }}>
            <ListItemButton
              id={`sidebar-item-${item.path.replace('/', '')}`}
              selected={location.pathname === item.path}
              onClick={() => handleNavigate(item.path)}
              sx={{
                mx: 1,
                borderRadius: 1,
                '&.Mui-selected': {
                  bgcolor: 'primary.main',
                  color: 'white',
                  '&:hover': {
                    bgcolor: 'primary.dark',
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'white',
                  },
                },
              }}
            >
              <ListItemIcon sx={{ minWidth: 40 }}>{item.icon}</ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  )

  return (
    <>
      {/* Mobile drawer */}
      {isMobile ? (
        <Drawer
          id="sidebar-drawer"
          anchor="left"
          open={sidebarOpen}
          onClose={toggleSidebar}
          sx={{
            '& .MuiDrawer-paper': {
              width: DRAWER_WIDTH,
              boxSizing: 'border-box',
            },
          }}
        >
          {drawerContent}
        </Drawer>
      ) : (
        /* Desktop drawer */
        <Drawer
          id="sidebar-drawer"
          variant="permanent"
          sx={{
            width: DRAWER_WIDTH,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: DRAWER_WIDTH,
              boxSizing: 'border-box',
              borderRight: '1px solid',
              borderColor: 'divider',
            },
          }}
        >
          {drawerContent}
        </Drawer>
      )}
    </>
  )
}
