import { Box, Button, Container, Typography, Stack, Paper } from '@mui/material'
import { useNavigate } from 'react-router-dom'
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline'
import GroupsIcon from '@mui/icons-material/Groups'
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents'
import AutorenewIcon from '@mui/icons-material/Autorenew'

export function WelcomePage() {
  const navigate = useNavigate()

  const features = [
    {
      icon: <GroupsIcon sx={{ fontSize: 48 }} color="primary" />,
      title: 'Управление группами',
      description:
        'Создавайте группы для семьи, соседей или команды. Приглашайте участников и управляйте задачами вместе.',
    },
    {
      icon: <AutorenewIcon sx={{ fontSize: 48 }} color="primary" />,
      title: 'Автоматическая ротация',
      description:
        'Система автоматически распределяет задачи между участниками, учитывая загруженность и статус "Отсутствую".',
    },
    {
      icon: <CheckCircleOutlineIcon sx={{ fontSize: 48 }} color="primary" />,
      title: 'Контроль выполнения',
      description:
        'Отслеживайте прогресс задач, утверждайте выполненные работы и получайте уведомления о дедлайнах.',
    },
    {
      icon: <EmojiEventsIcon sx={{ fontSize: 48 }} color="primary" />,
      title: 'Геймификация',
      description:
        'Зарабатывайте баллы за выполненные задачи, соревнуйтесь в таблице лидеров и обменивайте баллы на награды.',
    },
  ]

  return (
    <Box
      id="welcome-page"
      sx={{
        minHeight: '100vh',
        width: '100%',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* Hero Section */}
      <Container
        id="welcome-container"
        maxWidth="lg"
        sx={{ flex: 1, display: 'flex', flexDirection: 'column', py: { xs: 4, sm: 6, md: 8 } }}
      >
        <Box
          id="welcome-hero"
          sx={{ textAlign: 'center', color: 'white', mb: { xs: 4, sm: 6, md: 8 } }}
        >
          <Typography
            id="welcome-title"
            variant="h1"
            sx={{
              fontSize: { xs: '2.5rem', md: '3.5rem' },
              fontWeight: 700,
              mb: 2,
            }}
          >
            TaskFlow
          </Typography>
          <Typography
            id="welcome-subtitle"
            variant="h5"
            sx={{
              fontSize: { xs: '1.25rem', md: '1.5rem' },
              mb: 4,
              opacity: 0.9,
            }}
          >
            Автоматизированное распределение задач
            <br />с геймификацией и ротацией исполнителей
          </Typography>
          <Stack
            id="welcome-cta"
            direction={{ xs: 'column', sm: 'row' }}
            spacing={2}
            justifyContent="center"
          >
            <Button
              id="welcome-register-button"
              data-testid="welcome-register-button"
              variant="contained"
              size="large"
              onClick={() => navigate('/register')}
              sx={{
                bgcolor: 'white',
                color: 'primary.main',
                px: 4,
                py: 1.5,
                fontSize: '1.1rem',
                '&:hover': {
                  bgcolor: 'rgba(255, 255, 255, 0.9)',
                },
              }}
            >
              Начать работу
            </Button>
            <Button
              id="welcome-login-button"
              data-testid="welcome-login-button"
              variant="outlined"
              size="large"
              onClick={() => navigate('/login')}
              sx={{
                borderColor: 'white',
                color: 'white',
                px: 4,
                py: 1.5,
                fontSize: '1.1rem',
                '&:hover': {
                  borderColor: 'white',
                  bgcolor: 'rgba(255, 255, 255, 0.1)',
                },
              }}
            >
              Войти
            </Button>
          </Stack>
        </Box>

        {/* Features Grid */}
        <Box
          id="welcome-features-grid"
          sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' },
            gap: 3,
            mb: 6,
          }}
        >
          {features.map((feature, index) => (
            <Paper
              id={`welcome-feature-${index}`}
              key={index}
              elevation={3}
              sx={{
                p: 3,
                borderRadius: 2,
                transition: 'transform 0.2s',
                '&:hover': {
                  transform: 'translateY(-4px)',
                },
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                <Box id={`welcome-feature-icon-${index}`} sx={{ flexShrink: 0 }}>
                  {feature.icon}
                </Box>
                <Box>
                  <Typography id={`welcome-feature-title-${index}`} variant="h6" gutterBottom>
                    {feature.title}
                  </Typography>
                  <Typography
                    id={`welcome-feature-desc-${index}`}
                    variant="body2"
                    color="text.secondary"
                  >
                    {feature.description}
                  </Typography>
                </Box>
              </Box>
            </Paper>
          ))}
        </Box>

        {/* Footer */}
        <Box sx={{ textAlign: 'center', color: 'white', opacity: 0.8, mt: 'auto' }}>
          <Typography variant="body2">© 2025 TaskFlow. Все права защищены.</Typography>
        </Box>
      </Container>
    </Box>
  )
}
