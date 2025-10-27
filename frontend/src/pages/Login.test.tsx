import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { BrowserRouter } from 'react-router-dom'
import { LoginPage } from './Login'
import { useAuthStore } from '../store/authStore'

// Mock useNavigate
const mockNavigate = vi.fn()
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom')
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  }
})

// Mock authStore
vi.mock('../store/authStore', () => ({
  useAuthStore: vi.fn(),
}))

describe('LoginPage', () => {
  const mockLogin = vi.fn()

  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(useAuthStore).mockReturnValue(mockLogin)
  })

  const renderLogin = () => {
    return render(
      <BrowserRouter>
        <LoginPage />
      </BrowserRouter>
    )
  }

  it('should render login form', () => {
    renderLogin()

    expect(screen.getByText('Вход в TaskFlow')).toBeInTheDocument()
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/пароль/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /войти/i })).toBeInTheDocument()
  })

  it('should show validation errors for empty fields', async () => {
    const user = userEvent.setup()
    renderLogin()

    const submitButton = screen.getByRole('button', { name: /войти/i })
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/email обязателен/i)).toBeInTheDocument()
      expect(screen.getByText(/пароль обязателен/i)).toBeInTheDocument()
    })

    expect(mockLogin).not.toHaveBeenCalled()
  })

  it('should show validation error for invalid email', async () => {
    const user = userEvent.setup()
    renderLogin()

    const emailInput = screen.getByLabelText(/email/i)
    await user.type(emailInput, 'invalid-email')
    await user.tab() // Trigger onBlur

    await waitFor(() => {
      expect(screen.getByText(/некорректный формат email/i)).toBeInTheDocument()
    })
  })

  it('should show validation error for short password', async () => {
    const user = userEvent.setup()
    renderLogin()

    const passwordInput = screen.getByLabelText(/пароль/i)
    await user.type(passwordInput, '12345')
    await user.tab()

    await waitFor(() => {
      expect(screen.getByText(/минимум 6 символов/i)).toBeInTheDocument()
    })
  })

  it('should call login with correct credentials', async () => {
    const user = userEvent.setup()
    mockLogin.mockResolvedValue(undefined)
    renderLogin()

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/пароль/i)
    const submitButton = screen.getByRole('button', { name: /войти/i })

    await user.type(emailInput, 'test@example.com')
    await user.type(passwordInput, 'password123')
    await user.click(submitButton)

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123')
    })
  })

  it('should navigate to dashboard on successful login', async () => {
    const user = userEvent.setup()
    mockLogin.mockResolvedValue(undefined)
    renderLogin()

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/пароль/i)
    const submitButton = screen.getByRole('button', { name: /войти/i })

    await user.type(emailInput, 'test@example.com')
    await user.type(passwordInput, 'password123')
    await user.click(submitButton)

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/dashboard')
    })
  })

  it('should show error message on failed login', async () => {
    const user = userEvent.setup()
    mockLogin.mockRejectedValue(new Error('Invalid credentials'))
    renderLogin()

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/пароль/i)
    const submitButton = screen.getByRole('button', { name: /войти/i })

    await user.type(emailInput, 'test@example.com')
    await user.type(passwordInput, 'wrongpassword')
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument()
    })
  })

  it('should toggle password visibility', async () => {
    const user = userEvent.setup()
    renderLogin()

    const passwordInput = screen.getByLabelText(/пароль/i) as HTMLInputElement
    expect(passwordInput.type).toBe('password')

    const toggleButton = screen.getByRole('button', { name: '' }) // Icon button
    await user.click(toggleButton)

    expect(passwordInput.type).toBe('text')

    await user.click(toggleButton)
    expect(passwordInput.type).toBe('password')
  })

  it('should have link to registration page', () => {
    renderLogin()

    const registerLink = screen.getByRole('link', { name: /зарегистрироваться/i })
    expect(registerLink).toHaveAttribute('href', '/register')
  })

  it('should disable form during submission', async () => {
    const user = userEvent.setup()
    mockLogin.mockImplementation(() => new Promise((resolve) => setTimeout(resolve, 1000)))
    renderLogin()

    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/пароль/i)
    const submitButton = screen.getByRole('button', { name: /войти/i })

    await user.type(emailInput, 'test@example.com')
    await user.type(passwordInput, 'password123')
    await user.click(submitButton)

    expect(submitButton).toBeDisabled()
    expect(emailInput).toBeDisabled()
    expect(passwordInput).toBeDisabled()
  })
})
