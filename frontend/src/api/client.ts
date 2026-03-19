import { createClient, fetchExchange, subscriptionExchange } from 'urql'
import { cacheExchange } from '@urql/exchange-graphcache'
import { createClient as createWSClient } from 'graphql-ws'

// API URLs
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3100/graphql'
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:3100/graphql'

// Function to get access token from localStorage
// We'll use authStore's persisted state
const getAccessToken = (): string | null => {
  try {
    const authStorage = localStorage.getItem('auth-storage')
    if (authStorage) {
      const parsed = JSON.parse(authStorage)
      return parsed?.state?.accessToken || null
    }
  } catch (error) {
    console.error('Error reading auth token:', error)
  }
  return null
}

// WebSocket client for subscriptions
const wsClient = createWSClient({
  url: WS_URL,
  connectionParams: () => {
    const token = getAccessToken()
    return {
      authorization: token ? `Bearer ${token}` : '',
      'ngrok-skip-browser-warning': 'true',
    }
  },
})

// URQL client configuration
export const client = createClient({
  url: API_URL,
  exchanges: [
    cacheExchange({
      // Cache configuration
      keys: {
        UserType: data => data.id as string,
        GroupType: data => data.id as string,
        GroupMemberType: data => data.id as string,
        TaskType: data => data.id as string,
        UserStatistics: () => null, // Don't cache statistics
      },
      updates: {
        Mutation: {
          login: (_result, _args, cache) => {
            // Invalidate all queries after login
            cache.invalidate('Query')
          },
          register: (_result, _args, cache) => {
            cache.invalidate('Query')
          },
          logout: (_result, _args, cache) => {
            // Clear entire cache on logout
            cache.invalidate('Query')
          },
        },
      },
    }),
    fetchExchange,
    subscriptionExchange({
      forwardSubscription(request) {
        const input = { ...request, query: request.query || '' }
        return {
          subscribe(sink) {
            const unsubscribe = wsClient.subscribe(input, sink)
            return { unsubscribe }
          },
        }
      },
    }),
  ],
  fetchOptions: () => {
    const token = getAccessToken()
    return {
      headers: {
        authorization: token ? `Bearer ${token}` : '',
        'ngrok-skip-browser-warning': 'true',
      },
    }
  },
})

// Legacy exports for backward compatibility
export const urqlClient = client

// Helper function to set auth token (deprecated - use authStore instead)
export const setAuthToken = (token: string | null) => {
  console.warn('setAuthToken is deprecated. Use authStore.setTokens() instead.')
  if (token) {
    localStorage.setItem('authToken', token)
  } else {
    localStorage.removeItem('authToken')
  }
}

// Helper function to get auth token
export const getAuthToken = (): string | null => {
  return getAccessToken()
}
