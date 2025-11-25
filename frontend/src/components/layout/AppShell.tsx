import type { ReactNode } from 'react'
import { Box, useMediaQuery, useTheme } from '@mui/material'
import { Header } from './Header'
import { Sidebar } from './Sidebar'

interface AppShellProps {
  children: ReactNode
}

export function AppShell({ children }: AppShellProps) {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))

  return (
    <Box id="app-shell" sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* Show Sidebar only on mobile */}
      {isMobile && <Sidebar />}
      <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <Header />
        <Box
          id="main-content"
          component="main"
          sx={{
            flex: 1,
            bgcolor: 'background.default',
            pt: { xs: 3, sm: 3 },
            px: { xs: 2, sm: 3 },
            pb: { xs: 2, sm: 3 },
          }}
        >
          {children}
        </Box>
      </Box>
    </Box>
  )
}
