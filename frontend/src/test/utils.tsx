import { render, type RenderOptions } from '@testing-library/react'
import { type ReactElement } from 'react'
import { ThemeProvider } from '@mui/material'
import { Provider as UrqlProvider, type Client } from 'urql'
import { MemoryRouter, type MemoryRouterProps } from 'react-router-dom'
import { theme } from '@/lib/theme'
import { urqlClient } from '@/api/client'

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  urqlClient?: Client
  routerProps?: MemoryRouterProps
}

// Custom render function that includes providers
export function renderWithProviders(
  ui: ReactElement,
  options?: CustomRenderOptions
) {
  const { urqlClient: customUrqlClient, routerProps, ...renderOptions } = options || {}

  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <MemoryRouter {...routerProps}>
        <UrqlProvider value={customUrqlClient || urqlClient}>
          <ThemeProvider theme={theme}>{children}</ThemeProvider>
        </UrqlProvider>
      </MemoryRouter>
    )
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

// Re-export everything from testing library
export * from '@testing-library/react'
export { renderWithProviders as render }
