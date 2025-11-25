import type { FC } from 'react'
import { useParams } from 'react-router-dom'
import {
  Container,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Box,
  Chip,
  CircularProgress,
  Alert,
  useTheme,
  useMediaQuery,
  Card,
  CardContent,
} from '@mui/material'
import { EmojiEvents as TrophyIcon } from '@mui/icons-material'
import { useQuery } from 'urql'
import { GET_GROUP_LEADERBOARD_QUERY } from '@api/queries'
import { useAuthStore } from '@store/authStore'
import { formatPoints } from '@lib/formatPoints'

export const Leaderboard: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const user = useAuthStore(state => state.user)
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'))

  const [leaderboardResult] = useQuery({
    query: GET_GROUP_LEADERBOARD_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const { data, fetching, error } = leaderboardResult

  const getTrophyIcon = (rank: number) => {
    const colors = {
      1: '#FFD700', // Gold
      2: '#C0C0C0', // Silver
      3: '#CD7F32', // Bronze
    }

    if (rank <= 3) {
      return (
        <TrophyIcon
          sx={{
            color: colors[rank as keyof typeof colors],
            fontSize: 32,
          }}
        />
      )
    }
    return null
  }

  const getRankBadgeColor = (
    rank: number
  ): 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning' => {
    if (rank === 1) return 'warning' // Gold
    if (rank === 2) return 'default' // Silver
    if (rank === 3) return 'error' // Bronze
    return 'default'
  }

  if (!groupId) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">Группа не найдена</Alert>
      </Container>
    )
  }

  if (fetching) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            minHeight: '60vh',
          }}
        >
          <CircularProgress />
        </Box>
      </Container>
    )
  }

  if (error) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">Ошибка загрузки рейтинга: {error.message}</Alert>
      </Container>
    )
  }

  const leaderboardEntries = data?.getGroupLeaderboard || []

  if (leaderboardEntries.length === 0) {
    return (
      <Container maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Typography variant="h4" gutterBottom>
          Рейтинг группы
        </Typography>
        <Paper sx={{ p: 4, textAlign: 'center', mt: 3 }}>
          <Typography variant="body1" color="text.secondary">
            Рейтинг пуст. Выполняйте задачи, чтобы заработать баллы!
          </Typography>
        </Paper>
      </Container>
    )
  }

  // Mobile view (cards)
  if (isMobile) {
    return (
      <Container id={`leaderboard-page-${groupId}`} maxWidth="md" sx={{ mt: 3, mb: 8 }}>
        <Typography variant="h4" gutterBottom>
          Рейтинг группы
        </Typography>
        <Typography variant="body2" color="text.secondary" gutterBottom sx={{ mb: 3 }}>
          Рейтинг основан на общем количестве заработанных баллов
        </Typography>

        <Box id="leaderboard-mobile-list" sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {leaderboardEntries.map((entry: any) => {
            const isCurrentUser = entry.user.id === user?.id
            return (
              <Card
                id={`leaderboard-entry-card-${entry.user.id}`}
                key={entry.user.id}
                sx={{
                  border: isCurrentUser ? '2px solid' : '1px solid',
                  borderColor: isCurrentUser ? 'primary.main' : 'divider',
                  bgcolor: isCurrentUser ? 'primary.50' : 'background.paper',
                }}
              >
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    {getTrophyIcon(entry.rank)}
                    <Chip
                      id={`leaderboard-rank-${entry.user.id}`}
                      label={`#${entry.rank}`}
                      color={getRankBadgeColor(entry.rank)}
                      size="small"
                    />
                    <Box sx={{ flexGrow: 1 }}>
                      <Typography variant="body1" fontWeight={isCurrentUser ? 600 : 400}>
                        {entry.user.username}
                        {isCurrentUser && ' (Вы)'}
                      </Typography>
                      <Typography
                        id={`leaderboard-points-${entry.user.id}`}
                        variant="body2"
                        color="primary"
                        fontWeight={600}
                      >
                        {formatPoints(entry.pointsEarned)}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            )
          })}
        </Box>
      </Container>
    )
  }

  // Desktop view (table)
  return (
    <Container id={`leaderboard-page-${groupId}`} maxWidth="md" sx={{ mt: 3, mb: 8 }}>
      <Typography variant="h4" gutterBottom>
        Рейтинг группы
      </Typography>
      <Typography variant="body2" color="text.secondary" gutterBottom sx={{ mb: 3 }}>
        Рейтинг основан на общем количестве заработанных баллов
      </Typography>

      <TableContainer id="leaderboard-table" component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell width="80px" align="center">
                Место
              </TableCell>
              <TableCell width="80px"></TableCell>
              <TableCell>Пользователь</TableCell>
              <TableCell align="right">Баллы</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {leaderboardEntries.map((entry: any) => {
              const isCurrentUser = entry.user.id === user?.id
              return (
                <TableRow
                  id={`leaderboard-row-${entry.user.id}`}
                  key={entry.user.id}
                  sx={{
                    bgcolor: isCurrentUser ? 'primary.50' : 'inherit',
                    borderLeft: isCurrentUser ? '4px solid' : 'none',
                    borderLeftColor: 'primary.main',
                    '&:hover': {
                      bgcolor: isCurrentUser ? 'primary.100' : 'action.hover',
                    },
                  }}
                >
                  <TableCell align="center">
                    <Chip
                      id={`leaderboard-rank-${entry.user.id}`}
                      label={`#${entry.rank}`}
                      color={getRankBadgeColor(entry.rank)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell align="center">{getTrophyIcon(entry.rank)}</TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Typography variant="body1" fontWeight={isCurrentUser ? 600 : 400}>
                        {entry.user.username}
                      </Typography>
                      {isCurrentUser && <Chip label="Вы" size="small" color="primary" />}
                    </Box>
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body1" fontWeight={600} color="primary.main">
                      {formatPoints(entry.pointsEarned)}
                    </Typography>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </TableContainer>
    </Container>
  )
}
