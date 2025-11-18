import { type FC, useState } from 'react'
import { useParams } from 'react-router-dom'
import { useQuery } from 'urql'
import {
  Container,
  Typography,
  Alert,
  Paper,
  Box,
  Divider,
  CircularProgress,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  Avatar,
  Chip,
  Tabs,
  Tab,
  TablePagination,
} from '@mui/material'
import {
  Schedule as ScheduleIcon,
  History as HistoryIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material'
import { format } from 'date-fns'
import { ru } from 'date-fns/locale'
import {
  GET_ROTATION_SCHEDULE_QUERY,
  GET_ROTATION_HISTORY_QUERY,
  GET_ROTATION_PATTERN_QUERY,
} from '@api/queries'

type TabValue = 'schedule' | 'history' | 'pattern'

/**
 * Rotation Schedule Page
 * Phase 5.1: Rotation schedule visualization
 */
export const RotationSchedule: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const [activeTab, setActiveTab] = useState<TabValue>('schedule')
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(10)

  // Fetch rotation data
  const [{ data: scheduleData, fetching: scheduleFetching }] = useQuery({
    query: GET_ROTATION_SCHEDULE_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [{ data: historyData, fetching: historyFetching }] = useQuery({
    query: GET_ROTATION_HISTORY_QUERY,
    variables: { groupId: groupId!, limit: rowsPerPage, offset: page * rowsPerPage },
    pause: !groupId || activeTab !== 'history',
  })

  const [{ data: patternData, fetching: patternFetching }] = useQuery({
    query: GET_ROTATION_PATTERN_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId || activeTab !== 'pattern',
  })

  if (!groupId) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Alert severity="error">Группа не найдена</Alert>
      </Container>
    )
  }

  const schedule = scheduleData?.getRotationSchedule || []
  const history = historyData?.getRotationHistory
  const pattern = patternData?.getRotationPattern

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'HIGH':
        return 'error'
      case 'MEDIUM':
        return 'warning'
      case 'LOW':
        return 'info'
      default:
        return 'default'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'COMPLETED':
        return 'success'
      case 'AWAITING_APPROVAL':
        return 'info'
      case 'PENDING':
        return 'warning'
      default:
        return 'default'
    }
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 8 }}>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Расписание ротации
        </Typography>
        <Typography variant="body1" color="text.secondary">
          График автоматического распределения задач между участниками
        </Typography>
      </Box>

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs value={activeTab} onChange={(_, value) => setActiveTab(value)}>
          <Tab icon={<ScheduleIcon />} label="Расписание" value="schedule" />
          <Tab icon={<HistoryIcon />} label="История" value="history" />
          <Tab icon={<SettingsIcon />} label="Паттерн" value="pattern" />
        </Tabs>
      </Paper>

      {/* Schedule Tab */}
      {activeTab === 'schedule' && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" gutterBottom>
            Предстоящие назначения
          </Typography>
          <Divider sx={{ mb: 2 }} />
          {scheduleFetching ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : schedule.length === 0 ? (
            <Alert severity="info">
              Нет запланированных назначений через ротацию. Это может быть связано с тем, что:
              <ul style={{ marginTop: 8 }}>
                <li>В группе нет повторяющихся задач</li>
                <li>Ротация отключена для группы</li>
                <li>Recurring task scheduler еще не реализован (Phase 9)</li>
              </ul>
            </Alert>
          ) : (
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Задача</TableCell>
                  <TableCell>Исполнитель</TableCell>
                  <TableCell>Дата назначения</TableCell>
                  <TableCell>Приоритет</TableCell>
                  <TableCell>Баллы</TableCell>
                  <TableCell>Тип ротации</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {schedule.map((entry: any, index: number) => (
                  <TableRow key={`${entry.taskId}-${index}`}>
                    <TableCell>{entry.taskTitle}</TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Avatar src={entry.avatarUrl || undefined} sx={{ width: 32, height: 32 }}>
                          {entry.username[0].toUpperCase()}
                        </Avatar>
                        <Typography variant="body2">{entry.username}</Typography>
                      </Box>
                    </TableCell>
                    <TableCell>
                      {format(new Date(entry.scheduledDate), 'dd MMM yyyy, HH:mm', { locale: ru })}
                    </TableCell>
                    <TableCell>
                      <Chip label={entry.priority} size="small" color={getPriorityColor(entry.priority)} />
                    </TableCell>
                    <TableCell>{entry.points}</TableCell>
                    <TableCell>{entry.rotationType}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </Paper>
      )}

      {/* History Tab */}
      {activeTab === 'history' && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" gutterBottom>
            История назначений
          </Typography>
          <Divider sx={{ mb: 2 }} />
          {historyFetching ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : !history || history.items.length === 0 ? (
            <Alert severity="info">
              Нет истории назначений через ротацию. Задачи будут отображаться здесь после того, как
              они будут назначены автоматической системой ротации.
            </Alert>
          ) : (
            <>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Задача</TableCell>
                    <TableCell>Исполнитель</TableCell>
                    <TableCell>Дата назначения</TableCell>
                    <TableCell>Дата завершения</TableCell>
                    <TableCell>Статус</TableCell>
                    <TableCell>Баллы</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {history.items.map((entry: any) => (
                    <TableRow key={entry.taskId}>
                      <TableCell>{entry.taskTitle}</TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Avatar src={entry.avatarUrl || undefined} sx={{ width: 32, height: 32 }}>
                            {entry.username[0].toUpperCase()}
                          </Avatar>
                          <Typography variant="body2">{entry.username}</Typography>
                        </Box>
                      </TableCell>
                      <TableCell>
                        {format(new Date(entry.assignedAt), 'dd MMM yyyy, HH:mm', { locale: ru })}
                      </TableCell>
                      <TableCell>
                        {entry.completedAt
                          ? format(new Date(entry.completedAt), 'dd MMM yyyy, HH:mm', { locale: ru })
                          : '—'}
                      </TableCell>
                      <TableCell>
                        <Chip label={entry.status} size="small" color={getStatusColor(entry.status)} />
                      </TableCell>
                      <TableCell>{entry.pointsEarned}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
              <TablePagination
                component="div"
                count={history.total}
                page={page}
                onPageChange={(_, newPage) => setPage(newPage)}
                rowsPerPage={rowsPerPage}
                onRowsPerPageChange={(e) => {
                  setRowsPerPage(parseInt(e.target.value, 10))
                  setPage(0)
                }}
                labelRowsPerPage="Строк на странице:"
              />
            </>
          )}
        </Paper>
      )}

      {/* Pattern Tab */}
      {activeTab === 'pattern' && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" gutterBottom>
            Схема ротации группы
          </Typography>
          <Divider sx={{ mb: 2 }} />
          {patternFetching ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : !pattern ? (
            <Alert severity="info">Информация о схеме ротации недоступна</Alert>
          ) : (
            <Box>
              <Box sx={{ mb: 3 }}>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Тип ротации
                </Typography>
                <Chip label={pattern.rotationType} color="primary" />
              </Box>

              {pattern.lastRotationAt && (
                <Box sx={{ mb: 3 }}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Последнее назначение
                  </Typography>
                  <Typography variant="body1">
                    {format(new Date(pattern.lastRotationAt), 'dd MMMM yyyy, HH:mm', { locale: ru })}
                  </Typography>
                </Box>
              )}

              {pattern.nextRotationAt && (
                <Box sx={{ mb: 3 }}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Следующее назначение
                  </Typography>
                  <Typography variant="body1">
                    {format(new Date(pattern.nextRotationAt), 'dd MMMM yyyy, HH:mm', { locale: ru })}
                  </Typography>
                </Box>
              )}

              <Divider sx={{ my: 3 }} />

              <Box sx={{ mb: 3 }}>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Активные участники ({pattern.activeMembers.length})
                </Typography>
                <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mt: 1 }}>
                  {pattern.activeMembers.map((member: any) => (
                    <Box
                      key={member.id}
                      sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1, border: 1, borderColor: 'divider', borderRadius: 1 }}
                    >
                      <Avatar src={member.avatarUrl || undefined} sx={{ width: 40, height: 40 }}>
                        {member.username[0].toUpperCase()}
                      </Avatar>
                      <Typography variant="body2">{member.username}</Typography>
                    </Box>
                  ))}
                </Box>
              </Box>

              {pattern.awayMembers.length > 0 && (
                <Box>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Участники в отъезде ({pattern.awayMembers.length})
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mt: 1 }}>
                    {pattern.awayMembers.map((member: any) => (
                      <Box
                        key={member.id}
                        sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1, border: 1, borderColor: 'warning.main', borderRadius: 1 }}
                      >
                        <Avatar src={member.avatarUrl || undefined} sx={{ width: 40, height: 40 }}>
                          {member.username[0].toUpperCase()}
                        </Avatar>
                        <Box>
                          <Typography variant="body2">{member.username}</Typography>
                          {member.awayUntil && (
                            <Typography variant="caption" color="text.secondary">
                              до {format(new Date(member.awayUntil), 'dd MMM', { locale: ru })}
                            </Typography>
                          )}
                        </Box>
                      </Box>
                    ))}
                  </Box>
                </Box>
              )}
            </Box>
          )}
        </Paper>
      )}
    </Container>
  )
}
