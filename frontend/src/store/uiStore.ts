import { create } from 'zustand'

interface UIState {
  sidebarOpen: boolean
  currentModal: string | null
  theme: 'light' | 'dark'
  toggleSidebar: () => void
  openSidebar: () => void
  closeSidebar: () => void
  openModal: (modalId: string) => void
  closeModal: () => void
  setTheme: (theme: 'light' | 'dark') => void
}

export const useUIStore = create<UIState>(set => ({
  sidebarOpen: true,
  currentModal: null,
  theme: 'light',

  toggleSidebar: () => set(state => ({ sidebarOpen: !state.sidebarOpen })),
  openSidebar: () => set({ sidebarOpen: true }),
  closeSidebar: () => set({ sidebarOpen: false }),

  openModal: modalId => set({ currentModal: modalId }),
  closeModal: () => set({ currentModal: null }),

  setTheme: theme => set({ theme }),
}))
