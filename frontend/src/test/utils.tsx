import { render, type RenderOptions } from '@testing-library/react'
import { type ReactElement } from 'react'
import { ThemeProvider } from '@mui/material'
import { Provider as UrqlProvider } from 'urql'
import { theme } from '@/lib/theme'
import { urqlClient } from '@/api/client'

// Custom render function that includes providers
export function renderWithProviders(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <UrqlProvider value={urqlClient}>
        <ThemeProvider theme={theme}>{children}</ThemeProvider>
      </UrqlProvider>
    )
  }

  return render(ui, { wrapper: Wrapper, ...options })
}

// Re-export everything from testing library
export * from '@testing-library/react'
export { renderWithProviders as render }
