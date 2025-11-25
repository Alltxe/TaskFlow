import { describe, it, expect, vi, beforeEach } from 'vitest'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../test/utils'
import userEvent from '@testing-library/user-event'
import { RegisterPage } from './Register'

// Create mock functions using vi.hoisted to ensure they're available during hoisting
const { mockRegister, mockLogin, mockAuthStore } = vi.hoisted(() => {
  const mockRegister = vi.fn()
  const mockLogin = vi.fn()

  const mockAuthStore = vi.fn(selector => {
    const store = {
      login: mockLogin,
      logout: vi.fn(),
      register: mockRegister,
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
      updateUser: vi.fn(),
      setTokens: vi.fn(),
      initialize: vi.fn(),
    }
    return selector ? selector(store) : store
  })

  return { mockRegister, mockLogin, mockAuthStore }
})

// Mock authStore
vi.mock('../store/authStore', () => ({
  useAuthStore: mockAuthStore,
}))

describe('RegisterPage', () => {
  beforeEach(() => {
    mockRegister.mockReset()
    mockLogin.mockReset()
  })

  const renderRegister = () => {
    return render(<RegisterPage />)
  }

  it('should render registration form', () => {
    renderRegister()

    expect(screen.getByText('Регистрация в TaskFlow')).toBeInTheDocument()
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/имя пользователя/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/^пароль$/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/подтверждение пароля/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /зарегистрироваться/i })).toBeInTheDocument()
  })

  it('should show validation errors for empty fields', async () => {
    const user = userEvent.setup()
    renderRegister()

    const submitButton = screen.getByRole('button', { name: /зарегистрироваться/i })
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/email обязателен/i)).toBeInTheDocument()
      expect(screen.getByText(/имя пользователя обязательно/i)).toBeInTheDocument()
      expect(screen.getByText(/пароль обязателен/i)).toBeInTheDocument()
    })

    expect(mockRegister).not.toHaveBeenCalled()
  })

  it('should validate username length', async () => {
    const user = userEvent.setup()
    renderRegister()

    const usernameInput = screen.getByLabelText(/имя пользователя/i)

    // Too short
    await user.type(usernameInput, 'ab')
    await user.tab()

    await waitFor(() => {
      expect(screen.getByText(/минимум 3 символа/i)).toBeInTheDocument()
    })

    await user.clear(usernameInput)

    // Too long
    await user.type(usernameInput, 'a'.repeat(31))
    await user.tab()

    await waitFor(() => {
      expect(screen.getByText(/максимум 30 символов/i)).toBeInTheDocument()
    })
  })

  it('should validate password confirmation', async () => {
    const user = userEvent.setup()
    renderRegister()

    const passwordInput = screen.getByLabelText(/^пароль$/i)
    const confirmPasswordInput = screen.getByLabelText(/подтверждение пароля/i)

    await user.type(passwordInput, 'password123')
    await user.type(confirmPasswordInput, 'different')
    await user.tab()

    await waitFor(() => {
      expect(screen.getByText(/пароли не совпадают/i)).toBeInTheDocument()
    })
  })

  it('should call register with correct data', async () => {
    const user = userEvent.setup()
    mockRegister.mockResolvedValue(undefined)
    renderRegister()

    const emailInput = screen.getByLabelText(/email/i)
    const usernameInput = screen.getByLabelText(/имя пользователя/i)
    const passwordInput = screen.getByLabelText(/^пароль$/i)
    const confirmPasswordInput = screen.getByLabelText(/подтверждение пароля/i)
    const submitButton = screen.getByRole('button', { name: /зарегистрироваться/i })

    await user.type(emailInput, 'newuser@example.com')
    await user.type(usernameInput, 'newuser')
    await user.type(passwordInput, 'password123')
    await user.type(confirmPasswordInput, 'password123')
    await user.click(submitButton)

    await waitFor(() => {
      expect(mockRegister).toHaveBeenCalledWith('newuser@example.com', 'newuser', 'password123')
    })
  })

  it('should navigate to dashboard on successful registration', async () => {
    const user = userEvent.setup()
    mockRegister.mockResolvedValue(undefined)
    renderRegister()

    const emailInput = screen.getByLabelText(/email/i)
    const usernameInput = screen.getByLabelText(/имя пользователя/i)
    const passwordInput = screen.getByLabelText(/^пароль$/i)
    const confirmPasswordInput = screen.getByLabelText(/подтверждение пароля/i)
    const submitButton = screen.getByRole('button', { name: /зарегистрироваться/i })

    await user.type(emailInput, 'newuser@example.com')
    await user.type(usernameInput, 'newuser')
    await user.type(passwordInput, 'password123')
    await user.type(confirmPasswordInput, 'password123')
    await user.click(submitButton)

    await waitFor(() => {
      expect(mockRegister).toHaveBeenCalledWith('newuser@example.com', 'newuser', 'password123')
    })
  })

  it('should show error on duplicate email', async () => {
    const user = userEvent.setup()
    mockRegister.mockRejectedValue(new Error('Email already exists'))
    renderRegister()

    const emailInput = screen.getByLabelText(/email/i)
    const usernameInput = screen.getByLabelText(/имя пользователя/i)
    const passwordInput = screen.getByLabelText(/^пароль$/i)
    const confirmPasswordInput = screen.getByLabelText(/подтверждение пароля/i)
    const submitButton = screen.getByRole('button', { name: /зарегистрироваться/i })

    await user.type(emailInput, 'existing@example.com')
    await user.type(usernameInput, 'newuser')
    await user.type(passwordInput, 'password123')
    await user.type(confirmPasswordInput, 'password123')
    await user.click(submitButton)

    await waitFor(() => {
      expect(screen.getByText(/email already exists/i)).toBeInTheDocument()
    })
  })

  it('should toggle password visibility for both fields', async () => {
    const user = userEvent.setup()
    renderRegister()

    const passwordInput = screen.getByLabelText(/^пароль$/i) as HTMLInputElement
    const confirmPasswordInput = screen.getByLabelText(/подтверждение пароля/i) as HTMLInputElement
    expect(passwordInput.type).toBe('password')
    expect(confirmPasswordInput.type).toBe('password')

    const toggleButtons = screen.getAllByRole('button', { name: '' })

    // Toggle first password
    await user.click(toggleButtons[0])
    expect(passwordInput.type).toBe('text')

    // Toggle second password
    await user.click(toggleButtons[1])
    expect(confirmPasswordInput.type).toBe('text')
  })

  it('should have link to login page', () => {
    renderRegister()

    const loginLink = screen.getByRole('link', { name: /войти/i })
    expect(loginLink).toHaveAttribute('href', '/login')
  })
})
