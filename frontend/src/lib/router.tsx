import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { WelcomePage } from '@pages/Welcome'
import { LoginPage } from '@pages/Login'
import { RegisterPage } from '@pages/Register'
import { DashboardPage } from '@pages/Dashboard'
import { Groups as GroupsPage } from '@pages/Groups'
import { GroupSettings as GroupSettingsPage } from '@pages/GroupSettings'
import { GroupMembers as GroupMembersPage } from '@pages/GroupMembers'
import { GroupTasks as GroupTasksPage } from '@pages/GroupTasks'
import { JoinGroup as JoinGroupPage } from '@pages/JoinGroup'
import { Profile as ProfilePage } from '@pages/Profile'
import { RotationSchedule as RotationSchedulePage } from '@pages/RotationSchedule'
import { GroupRewards as GroupRewardsPage } from '@pages/GroupRewards'
import { Leaderboard as LeaderboardPage } from '@pages/Leaderboard'
import { NotFoundPage } from '@pages/NotFound'
import { ProtectedRoute } from '@lib/ProtectedRoute'
import { AppShell, GroupLayout } from '../components/layout'

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
  {
    path: '/groups',
    element: (
      <AppShell>
        <ProtectedRoute>
          <GroupsPage />
        </ProtectedRoute>
      </AppShell>
    ),
  },
  {
    path: '/group/:groupId',
    element: (
      <AppShell>
        <ProtectedRoute>
          <GroupLayout />
        </ProtectedRoute>
      </AppShell>
    ),
    children: [
      {
        path: 'tasks',
        element: <GroupTasksPage />,
      },
      {
        path: 'settings',
        element: <GroupSettingsPage />,
      },
      {
        path: 'members',
        element: <GroupMembersPage />,
      },
      {
        path: 'rotation',
        element: <RotationSchedulePage />,
      },
      {
        path: 'rewards',
        element: <GroupRewardsPage />,
      },
      {
        path: 'leaderboard',
        element: <LeaderboardPage />,
      },
    ],
  },
  {
    path: '/join/:inviteToken',
    element: (
      <AppShell>
        <ProtectedRoute>
          <JoinGroupPage />
        </ProtectedRoute>
      </AppShell>
    ),
  },
  {
    path: '/profile',
    element: (
      <AppShell>
        <ProtectedRoute>
          <ProfilePage />
        </ProtectedRoute>
      </AppShell>
    ),
  },
  {
    path: '*',
    element: <NotFoundPage />,
  },
])

export function AppRouter() {
  return <RouterProvider router={router} />
}
