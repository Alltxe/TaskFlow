import { Box, Typography, Button, Card, CardContent, CardActions } from '@mui/material'
import { Add as AddIcon, Group as GroupIcon } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '../store/authStore'

export function DashboardPage() {
  const navigate = useNavigate()
  const user = useAuthStore((state) => state.user)

  // Temporary mock data - will be replaced with actual GraphQL query
  const groups = [
    { id: '1', name: 'Семья', memberCount: 4, lastActivity: '2 часа назад' },
    { id: '2', name: 'Соседи', memberCount: 6, lastActivity: '1 день назад' },
  ]

  return (
    <Box>
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" gutterBottom fontWeight={600}>
            Добро пожаловать, {user?.username}!
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Управляйте своими группами и задачами
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          size="large"
          onClick={() => navigate('/groups/create')}
        >
          Создать группу
        </Button>
      </Box>

      {groups.length === 0 ? (
        <Box
          sx={{
            textAlign: 'center',
            py: 8,
            px: 2,
            bgcolor: 'background.paper',
            borderRadius: 2,
            border: '2px dashed',
            borderColor: 'divider',
          }}
        >
          <GroupIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
          <Typography variant="h6" gutterBottom>
            У вас пока нет групп
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
            Создайте группу или присоединитесь к существующей
          </Typography>
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => navigate('/groups/create')}>
            Создать первую группу
          </Button>
        </Box>
      ) : (
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: {
              xs: '1fr',
              sm: 'repeat(2, 1fr)',
              md: 'repeat(3, 1fr)',
            },
            gap: 3,
          }}
        >
          {groups.map((group) => (
            <Card
              key={group.id}
              sx={{
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                transition: 'transform 0.2s, box-shadow 0.2s',
                '&:hover': {
                  transform: 'translateY(-4px)',
                  boxShadow: 4,
                },
              }}
            >
              <CardContent sx={{ flex: 1 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                  <GroupIcon color="primary" sx={{ fontSize: 40 }} />
                  <Box>
                    <Typography variant="h6" fontWeight={600}>
                      {group.name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {group.memberCount} участников
                    </Typography>
                  </Box>
                </Box>
                <Typography variant="body2" color="text.secondary">
                  Последняя активность: {group.lastActivity}
                </Typography>
              </CardContent>
              <CardActions>
                <Button size="small" onClick={() => navigate(`/group/${group.id}`)}>
                  Открыть
                </Button>
                <Button size="small" color="secondary">
                  Настройки
                </Button>
              </CardActions>
            </Card>
          ))}
        </Box>
      )}
    </Box>
  )
}


