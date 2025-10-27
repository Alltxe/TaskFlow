import { useEffect, useState } from 'react'
import { ThemeProvider, CssBaseline, Box, Typography, Button } from '@mui/material'
import { Global } from '@emotion/react'
import { Provider as UrqlProvider } from 'urql'
import { theme } from './lib/theme'
import { globalStyles } from './lib/globalStyles'
import { client } from './api/client'
import { AppRouter } from './lib/router'
import { useAuthStore } from './store/authStore'

function App() {
  const [error, setError] = useState<Error | null>(null)
  const initialize = useAuthStore((state) => state.initialize)

  useEffect(() => {
    // Initialize auth state on app load
    initialize().catch((error) => {
      console.error('Failed to initialize auth:', error)
      // Don't block the app if auth initialization fails
    })
  }, [initialize])

  if (error) {
    return (
      <Box sx={{ p: 4, textAlign: 'center' }}>
        <Typography variant="h4" color="error" gutterBottom>
          Ошибка загрузки приложения
        </Typography>
        <Typography variant="body1" sx={{ mb: 2 }}>
          {error.message}
        </Typography>
        <Button variant="contained" onClick={() => window.location.reload()}>
          Перезагрузить
        </Button>
      </Box>
    )
  }

  try {
    return (
      <UrqlProvider value={client}>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <Global styles={globalStyles} />
          <AppRouter />
        </ThemeProvider>
      </UrqlProvider>
    )
  } catch (err) {
    setError(err as Error)
    return null
  }
}

export default App
