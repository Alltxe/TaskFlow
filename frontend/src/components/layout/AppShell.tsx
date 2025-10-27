import type { ReactNode } from 'react'
import { Box, Container, useMediaQuery, useTheme } from '@mui/material'
import { Header } from './Header'
import { Sidebar } from './Sidebar'

interface AppShellProps {
  children: ReactNode
}

export function AppShell({ children }: AppShellProps) {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* Show Sidebar only on mobile */}
      {isMobile && <Sidebar />}
      <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <Header />
        <Box
          component="main"
          sx={{
            flex: 1,
            bgcolor: 'background.default',
            p: 3,
          }}
        >
          <Container maxWidth="xl">{children}</Container>
        </Box>
      </Box>
    </Box>
  )
}


