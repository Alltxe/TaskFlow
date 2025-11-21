import { useState } from 'react'
import {
  Box,
  Button,
  Container,
  TextField,
  Typography,
  Paper,
  Link,
  Alert,
  CircularProgress,
  InputAdornment,
  IconButton,
} from '@mui/material'
import { useNavigate, Link as RouterLink } from 'react-router-dom'
import { Visibility, VisibilityOff } from '@mui/icons-material'
import { useAuthStore } from '../store/authStore'

export function LoginPage() {
  const navigate = useNavigate()
  const login = useAuthStore((state) => state.login)
  
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  
  const [emailError, setEmailError] = useState('')
  const [passwordError, setPasswordError] = useState('')

  const validateEmail = (email: string) => {
    if (!email) {
      setEmailError('Email обязателен')
      return false
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      setEmailError('Некорректный формат email')
      return false
    }
    setEmailError('')
    return true
  }

  const validatePassword = (password: string) => {
    if (!password) {
      setPasswordError('Пароль обязателен')
      return false
    }
    if (password.length < 6) {
      setPasswordError('Пароль должен содержать минимум 6 символов')
      return false
    }
    setPasswordError('')
    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    const isEmailValid = validateEmail(email)
    const isPasswordValid = validatePassword(password)

    if (!isEmailValid || !isPasswordValid) {
      return
    }

    setLoading(true)

    try {
      await login(email, password)
      navigate('/dashboard')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка входа. Проверьте email и пароль.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Box
      sx={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        py: 4,
      }}
    >
      <Container maxWidth="sm">
        <Paper elevation={3} sx={{ p: 4, borderRadius: 2 }}>
          <Box sx={{ mb: 3, textAlign: 'center' }}>
            <Typography variant="h4" component="h1" gutterBottom fontWeight={600}>
              Вход в TaskFlow
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Войдите в свой аккаунт для продолжения
            </Typography>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError('')}>
              {error}
            </Alert>
          )}

          <form onSubmit={handleSubmit} data-testid="login-form">
            <TextField
              data-testid="login-email-input"
              fullWidth
              label="Email"
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value)
                if (emailError) validateEmail(e.target.value)
              }}
              onBlur={() => validateEmail(email)}
              error={!!emailError}
              helperText={emailError}
              margin="normal"
              autoComplete="email"
              autoFocus
              disabled={loading}
            />

            <TextField
              data-testid="login-password-input"
              fullWidth
              label="Пароль"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => {
                setPassword(e.target.value)
                if (passwordError) validatePassword(e.target.value)
              }}
              onBlur={() => validatePassword(password)}
              error={!!passwordError}
              helperText={passwordError}
              margin="normal"
              autoComplete="current-password"
              disabled={loading}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      data-testid="login-password-toggle"
                      onClick={() => setShowPassword(!showPassword)}
                      edge="end"
                      disabled={loading}
                    >
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />

            <Button
              data-testid="login-submit-button"
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{ mt: 3, mb: 2, py: 1.5 }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Войти'}
            </Button>

            <Box sx={{ textAlign: 'center', mt: 2 }}>
              <Typography variant="body2" color="text.secondary">
                Нет аккаунта?{' '}
                <Link data-testid="login-register-link" component={RouterLink} to="/register" underline="hover">
                  Зарегистрироваться
                </Link>
              </Typography>
            </Box>
          </form>
        </Paper>
      </Container>
    </Box>
  )
}
