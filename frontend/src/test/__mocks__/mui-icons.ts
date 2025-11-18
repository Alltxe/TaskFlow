import React from 'react'

// Mock all MUI icons to avoid EMFILE error on Windows
// This proxy intercepts all icon imports and returns simple mock components

export default new Proxy(
  {},
  {
    get: (_target, prop) => {
      if (prop === '__esModule') return true
      if (prop === 'default') return {}

      // Return a simple functional component for any icon
      const MockIcon = (props: any) =>
        React.createElement('svg', {
          ...props,
          'data-testid': `mock-icon-${String(prop)}`,
          'aria-label': String(prop),
        })

      MockIcon.displayName = `Mock${String(prop)}`
      return MockIcon
    },
  }
)

// Also export named exports for common icons
export const Add = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Add' })
export const MoreVert = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-MoreVert' })
export const Group = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Group' })
export const AccessTime = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-AccessTime' })
export const Task = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Task' })
export const Settings = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Settings' })
export const ExitToApp = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-ExitToApp' })
export const Person = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Person' })
export const Email = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Email' })
export const Lock = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Lock' })
export const Visibility = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-Visibility' })
export const VisibilityOff = (props: any) =>
  React.createElement('svg', { ...props, 'data-testid': 'mock-icon-VisibilityOff' })
