import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { WelcomePage } from '@pages/Welcome'
import { LoginPage } from '@pages/Login'
import { RegisterPage } from '@pages/Register'
import { DashboardPage } from '@pages/Dashboard'
import { NotFoundPage } from '@pages/NotFound'
import { ProtectedRoute } from '@lib/ProtectedRoute'
import { AppShell } from '../components/layout'

// Define all application routes
export const router = createBrowserRouter([
  {
    path: '/',
    element: <WelcomePage />,
  },
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/register',
    element: <RegisterPage />,
  },
  {
    path: '/dashboard',
    element: (
      <AppShell>
        <ProtectedRoute>
          <DashboardPage />
        </ProtectedRoute>
      </AppShell>
    ),
  },
  // Group routes will be added later
  // {
  //   path: '/group/:id',
  //   element: <AppShell><ProtectedRoute><GroupLayout /></ProtectedRoute></AppShell>,
  //   children: [
  //     { path: 'tasks', element: <GroupTasksPage /> },
  //     { path: 'rewards', element: <RewardsPage /> },
  //     { path: 'leaderboard', element: <LeaderboardPage /> },
  //     { path: 'review', element: <ReviewQueuePage /> },
  //     { path: 'members', element: <MembersPage /> },
  //     { path: 'settings', element: <GroupSettingsPage /> },
  //   ],
  // },
  // {
  //   path: '/profile',
  //   element: <AppShell><ProtectedRoute><ProfilePage /></ProtectedRoute></AppShell>,
  // },
  {
    path: '*',
    element: <NotFoundPage />,
  },
])

export function AppRouter() {
  return <RouterProvider router={router} />
}

