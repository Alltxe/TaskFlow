import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useAuthStore } from './authStore'
import { client } from '../api/client'

// Mock urql client
vi.mock('../api/client', () => ({
  client: {
    mutation: vi.fn(),
    query: vi.fn(),
  },
}))

describe('authStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useAuthStore.setState({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
    })
    vi.clearAllMocks()
  })

  describe('login', () => {
    it('should set user and tokens on successful login', async () => {
      const mockUser = {
        id: '1',
        email: 'test@example.com',
        username: 'testuser',
        isAway: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }

      const mockResponse = {
        data: {
          login: {
            accessToken: 'mock-access-token',
            refreshToken: 'mock-refresh-token',
            user: mockUser,
          },
        },
        error: null,
      }

      vi.mocked(client.mutation).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue(mockResponse),
      } as any)

      const { login } = useAuthStore.getState()
      await login('test@example.com', 'password123')

      const state = useAuthStore.getState()
      expect(state.user).toEqual(mockUser)
      expect(state.accessToken).toBe('mock-access-token')
      expect(state.refreshToken).toBe('mock-refresh-token')
      expect(state.isAuthenticated).toBe(true)
    })

    it('should throw error on failed login', async () => {
      const mockResponse = {
        data: null,
        error: { message: 'Invalid credentials' },
      }

      vi.mocked(client.mutation).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue(mockResponse),
      } as any)

      const { login } = useAuthStore.getState()
      await expect(login('test@example.com', 'wrong')).rejects.toThrow('Invalid credentials')
    })
  })

  describe('register', () => {
    it('should set user and tokens on successful registration', async () => {
      const mockUser = {
        id: '2',
        email: 'new@example.com',
        username: 'newuser',
        isAway: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }

      const mockResponse = {
        data: {
          register: {
            accessToken: 'mock-access-token',
            refreshToken: 'mock-refresh-token',
            user: mockUser,
          },
        },
        error: null,
      }

      vi.mocked(client.mutation).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue(mockResponse),
      } as any)

      const { register } = useAuthStore.getState()
      await register('new@example.com', 'newuser', 'password123')

      const state = useAuthStore.getState()
      expect(state.user).toEqual(mockUser)
      expect(state.isAuthenticated).toBe(true)
    })

    it('should throw error on duplicate email', async () => {
      const mockResponse = {
        data: null,
        error: { message: 'Email already exists' },
      }

      vi.mocked(client.mutation).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue(mockResponse),
      } as any)

      const { register } = useAuthStore.getState()
      await expect(register('existing@example.com', 'user', 'pass')).rejects.toThrow()
    })
  })

  describe('logout', () => {
    it('should clear user data and tokens', async () => {
      // Set up authenticated state
      useAuthStore.setState({
        user: {
          id: '1',
          email: 'test@example.com',
          username: 'testuser',
          isAway: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        accessToken: 'token',
        refreshToken: 'refresh',
        isAuthenticated: true,
      })

      vi.mocked(client.mutation).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue({ data: { logout: true } }),
      } as any)

      const { logout } = useAuthStore.getState()
      await logout()

      const state = useAuthStore.getState()
      expect(state.user).toBeNull()
      expect(state.accessToken).toBeNull()
      expect(state.refreshToken).toBeNull()
      expect(state.isAuthenticated).toBe(false)
    })
  })

  describe('updateUser', () => {
    it('should update user data', () => {
      useAuthStore.setState({
        user: {
          id: '1',
          email: 'test@example.com',
          username: 'oldname',
          isAway: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        isAuthenticated: true,
      })

      const { updateUser } = useAuthStore.getState()
      updateUser({ username: 'newname', isAway: true })

      const state = useAuthStore.getState()
      expect(state.user?.username).toBe('newname')
      expect(state.user?.isAway).toBe(true)
      expect(state.user?.email).toBe('test@example.com')
    })

    it('should not update if user is null', () => {
      const { updateUser } = useAuthStore.getState()
      updateUser({ username: 'newname' })

      const state = useAuthStore.getState()
      expect(state.user).toBeNull()
    })
  })

  describe('initialize', () => {
    it('should fetch user data if access token exists', async () => {
      useAuthStore.setState({
        accessToken: 'existing-token',
      })

      const mockUser = {
        id: '1',
        email: 'test@example.com',
        username: 'testuser',
        isAway: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }

      vi.mocked(client.query).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue({
          data: { me: mockUser },
          error: null,
        }),
      } as any)

      const { initialize } = useAuthStore.getState()
      await initialize()

      const state = useAuthStore.getState()
      expect(state.user).toEqual(mockUser)
      expect(state.isAuthenticated).toBe(true)
    })

    it('should clear auth state on expired token', async () => {
      useAuthStore.setState({
        accessToken: 'expired-token',
        user: {
          id: '1',
          email: 'test@example.com',
          username: 'testuser',
          isAway: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        isAuthenticated: true,
      })

      vi.mocked(client.query).mockReturnValue({
        toPromise: vi.fn().mockResolvedValue({
          data: null,
          error: { message: 'Unauthorized' },
        }),
      } as any)

      const { initialize } = useAuthStore.getState()
      await initialize()

      const state = useAuthStore.getState()
      expect(state.user).toBeNull()
      expect(state.accessToken).toBeNull()
      expect(state.isAuthenticated).toBe(false)
    })

    it('should do nothing if no access token', async () => {
      const { initialize } = useAuthStore.getState()
      await initialize()

      expect(client.query).not.toHaveBeenCalled()
    })
  })
})
