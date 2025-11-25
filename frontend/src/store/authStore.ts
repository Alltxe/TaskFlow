import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { client } from '../api/client'
import { LOGIN_MUTATION, REGISTER_MUTATION, LOGOUT_MUTATION, ME_QUERY } from '../api/queries'

interface User {
  id: string
  email: string
  username: string
  avatarUrl?: string | null
  isAway: boolean
  awayUntil?: string | null
  createdAt: string
  updatedAt: string
}

interface AuthState {
  user: User | null
  accessToken: string | null
  refreshToken: string | null
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  register: (email: string, username: string, password: string) => Promise<void>
  logout: () => Promise<void>
  updateUser: (user: Partial<User>) => void
  setTokens: (accessToken: string, refreshToken: string) => void
  initialize: () => Promise<void>
}

// Auth store with persistence
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,

      login: async (email: string, password: string) => {
        const result = await client
          .mutation(LOGIN_MUTATION, {
            input: { email, password },
          })
          .toPromise()

        if (result.error) {
          throw new Error(result.error.message || 'Ошибка входа')
        }

        if (result.data?.login) {
          const { accessToken, refreshToken, user } = result.data.login
          set({
            user,
            accessToken,
            refreshToken,
            isAuthenticated: true,
          })
        }
      },

      register: async (email: string, username: string, password: string) => {
        const result = await client
          .mutation(REGISTER_MUTATION, {
            input: { email, username, password },
          })
          .toPromise()

        if (result.error) {
          throw new Error(result.error.message || 'Ошибка регистрации')
        }

        if (result.data?.register) {
          const { accessToken, refreshToken, user } = result.data.register
          set({
            user,
            accessToken,
            refreshToken,
            isAuthenticated: true,
          })
        }
      },

      logout: async () => {
        const { refreshToken } = get()

        if (refreshToken) {
          try {
            await client.mutation(LOGOUT_MUTATION, { refreshToken }).toPromise()
          } catch (error) {
            console.error('Logout error:', error)
          }
        }

        set({
          user: null,
          accessToken: null,
          refreshToken: null,
          isAuthenticated: false,
        })
      },

      updateUser: (userData: Partial<User>) => {
        set(state => ({
          user: state.user ? { ...state.user, ...userData } : null,
        }))
      },

      setTokens: (accessToken: string, refreshToken: string) => {
        set({ accessToken, refreshToken })
      },

      initialize: async () => {
        const { accessToken } = get()

        if (!accessToken) {
          return
        }

        try {
          const result = await client.query(ME_QUERY, {}).toPromise()

          if (result.error) {
            // Token expired or invalid - clear auth state
            set({
              user: null,
              accessToken: null,
              refreshToken: null,
              isAuthenticated: false,
            })
            return
          }

          if (result.data?.me) {
            set({
              user: result.data.me,
              isAuthenticated: true,
            })
          }
        } catch (error) {
          console.error('Initialize error:', error)
          set({
            user: null,
            accessToken: null,
            refreshToken: null,
            isAuthenticated: false,
          })
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: state => ({
        user: state.user,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
)
