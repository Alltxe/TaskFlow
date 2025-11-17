import type { FC } from 'react'
import { useState } from 'react'
import {
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Box,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
  Alert,
} from '@mui/material'
import {
  Check as CheckIcon,
  Close as CloseIcon,
} from '@mui/icons-material'
import { useQuery, useMutation } from 'urql'
import { GET_GROUP_REWARD_REQUESTS_QUERY, APPROVE_REWARD_REQUEST_MUTATION } from '@api/queries'
import { formatPoints } from '@lib/formatPoints'
import { getRewardStatusColor, getRewardStatusLabel } from '@lib/rewardHelpers'
import { showToast } from '@lib/toast'
import { format } from 'date-fns'
import { ru } from 'date-fns/locale'

export interface RequestReviewQueueProps {
  groupId: string
}

export const RequestReviewQueue: FC<RequestReviewQueueProps> = ({ groupId }) => {
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false)
  const [selectedRequestId, setSelectedRequestId] = useState<string | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')

  const [requestsResult, reexecuteQuery] = useQuery({
    query: GET_GROUP_REWARD_REQUESTS_QUERY,
    variables: { groupId },
  })

  const [, approveRequest] = useMutation(APPROVE_REWARD_REQUEST_MUTATION)

  const { data, fetching, error } = requestsResult

  const handleApprove = async (requestId: string) => {
    const result = await approveRequest({
      input: {
        requestId,
        approve: true,
      },
    })

    if (result.error) {
      showToast(`Ошибка одобрения: ${result.error.message}`, 'error')
      return
    }

    showToast('Запрос награды одобрен! Баллы списаны с пользователя.', 'success')
    reexecuteQuery({ requestPolicy: 'network-only' })
  }

  const handleRejectClick = (requestId: string) => {
    setSelectedRequestId(requestId)
    setRejectDialogOpen(true)
  }

  const handleRejectConfirm = async () => {
    if (!selectedRequestId) return

    const result = await approveRequest({
      input: {
        requestId: selectedRequestId,
        approve: false,
        rejectionReason: rejectionReason.trim() || 'Запрос отклонен администратором',
      },
    })

    if (result.error) {
      showToast(`Ошибка отклонения: ${result.error.message}`, 'error')
      return
    }

    showToast('Запрос награды отклонен. Баллы возвращены пользователю.', 'success')
    setRejectDialogOpen(false)
    setSelectedRequestId(null)
    setRejectionReason('')
    reexecuteQuery({ requestPolicy: 'network-only' })
  }

  if (fetching) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Alert severity="error">
        Ошибка загрузки запросов наград: {error.message}
      </Alert>
    )
  }

  const requests = data?.getGroupRewardRequests || []
  const pendingRequests = requests.filter((req: any) => req.status === 'RESERVED')

  if (pendingRequests.length === 0) {
    return (
      <Paper sx={{ p: 3, textAlign: 'center' }}>
        <Typography variant="body1" color="text.secondary">
          Нет ожидающих запросов наград
        </Typography>
      </Paper>
    )
  }

  return (
    <>
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Пользователь</TableCell>
              <TableCell>Награда</TableCell>
              <TableCell>Стоимость</TableCell>
              <TableCell>Дата запроса</TableCell>
              <TableCell>Статус</TableCell>
              <TableCell align="right">Действия</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {pendingRequests.map((request: any) => (
              <TableRow key={request.id}>
                <TableCell>ID: {request.userId}</TableCell>
                <TableCell>ID награды: {request.rewardId}</TableCell>
                <TableCell>
                  <Chip
                    label={formatPoints(request.pointsSpent)}
                    size="small"
                    color="primary"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>
                  {format(new Date(request.requestedAt), 'dd MMM yyyy, HH:mm', { locale: ru })}
                </TableCell>
                <TableCell>
                  <Chip
                    label={getRewardStatusLabel(request.status)}
                    color={getRewardStatusColor(request.status)}
                    size="small"
                  />
                </TableCell>
                <TableCell align="right">
                  <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                    <Button
                      size="small"
                      variant="contained"
                      color="success"
                      startIcon={<CheckIcon />}
                      onClick={() => handleApprove(request.id)}
                    >
                      Одобрить
                    </Button>
                    <Button
                      size="small"
                      variant="outlined"
                      color="error"
                      startIcon={<CloseIcon />}
                      onClick={() => handleRejectClick(request.id)}
                    >
                      Отклонить
                    </Button>
                  </Box>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Reject Dialog */}
      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Отклонить запрос награды</DialogTitle>
        <DialogContent>
          <TextField
            label="Причина отклонения (необязательно)"
            value={rejectionReason}
            onChange={(e) => setRejectionReason(e.target.value)}
            fullWidth
            multiline
            rows={3}
            placeholder="Укажите причину отклонения..."
            sx={{ mt: 2 }}
          />
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setRejectDialogOpen(false)}>Отмена</Button>
          <Button onClick={handleRejectConfirm} variant="contained" color="error">
            Отклонить запрос
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}
