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

export function RegisterPage() {
  const navigate = useNavigate()
  const register = useAuthStore((state) => state.register)
  
  const [email, setEmail] = useState('')
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  
  const [emailError, setEmailError] = useState('')
  const [usernameError, setUsernameError] = useState('')
  const [passwordError, setPasswordError] = useState('')
  const [confirmPasswordError, setConfirmPasswordError] = useState('')

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

  const validateUsername = (username: string) => {
    if (!username) {
      setUsernameError('Имя пользователя обязательно')
      return false
    }
    if (username.length < 3) {
      setUsernameError('Имя должно содержать минимум 3 символа')
      return false
    }
    if (username.length > 30) {
      setUsernameError('Имя должно содержать максимум 30 символов')
      return false
    }
    setUsernameError('')
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

  const validateConfirmPassword = (confirmPass: string) => {
    if (!confirmPass) {
      setConfirmPasswordError('Подтверждение пароля обязательно')
      return false
    }
    if (confirmPass !== password) {
      setConfirmPasswordError('Пароли не совпадают')
      return false
    }
    setConfirmPasswordError('')
    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    const isEmailValid = validateEmail(email)
    const isUsernameValid = validateUsername(username)
    const isPasswordValid = validatePassword(password)
    const isConfirmPasswordValid = validateConfirmPassword(confirmPassword)

    if (!isEmailValid || !isUsernameValid || !isPasswordValid || !isConfirmPasswordValid) {
      return
    }

    setLoading(true)

    try {
      await register(email, username, password)
      navigate('/dashboard')
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : 'Ошибка регистрации. Возможно, пользователь с таким email уже существует.'
      )
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
              Регистрация в TaskFlow
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Создайте аккаунт для начала работы
            </Typography>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError('')}>
              {error}
            </Alert>
          )}

          <form onSubmit={handleSubmit}>
            <TextField
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
              fullWidth
              label="Имя пользователя"
              type="text"
              value={username}
              onChange={(e) => {
                setUsername(e.target.value)
                if (usernameError) validateUsername(e.target.value)
              }}
              onBlur={() => validateUsername(username)}
              error={!!usernameError}
              helperText={usernameError}
              margin="normal"
              autoComplete="username"
              disabled={loading}
            />

            <TextField
              fullWidth
              label="Пароль"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => {
                setPassword(e.target.value)
                if (passwordError) validatePassword(e.target.value)
                if (confirmPassword && confirmPasswordError) {
                  validateConfirmPassword(confirmPassword)
                }
              }}
              onBlur={() => validatePassword(password)}
              error={!!passwordError}
              helperText={passwordError}
              margin="normal"
              autoComplete="new-password"
              disabled={loading}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
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

            <TextField
              fullWidth
              label="Подтверждение пароля"
              type={showConfirmPassword ? 'text' : 'password'}
              value={confirmPassword}
              onChange={(e) => {
                setConfirmPassword(e.target.value)
                if (confirmPasswordError) validateConfirmPassword(e.target.value)
              }}
              onBlur={() => validateConfirmPassword(confirmPassword)}
              error={!!confirmPasswordError}
              helperText={confirmPasswordError}
              margin="normal"
              autoComplete="new-password"
              disabled={loading}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      edge="end"
                      disabled={loading}
                    >
                      {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{ mt: 3, mb: 2, py: 1.5 }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Зарегистрироваться'}
            </Button>

            <Box sx={{ textAlign: 'center', mt: 2 }}>
              <Typography variant="body2" color="text.secondary">
                Уже есть аккаунт?{' '}
                <Link component={RouterLink} to="/login" underline="hover">
                  Войти
                </Link>
              </Typography>
            </Box>
          </form>
        </Paper>
      </Container>
    </Box>
  )
}
