import { type FC, useEffect, useState } from 'react'
import { Container, Typography, Box, Paper, Button, CircularProgress, Alert } from '@mui/material'
import { Group as GroupIcon, Check as CheckIcon } from '@mui/icons-material'
import { useParams, useNavigate } from 'react-router-dom'
import { useMutation } from 'urql'
import { JOIN_GROUP_MUTATION } from '@api/queries'

export const JoinGroup: FC = () => {
  const { inviteToken } = useParams<{ inviteToken: string }>()
  const navigate = useNavigate()
  const [isJoining, setIsJoining] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const [, joinGroupMutation] = useMutation(JOIN_GROUP_MUTATION)

  useEffect(() => {
    // Auto-join if user is already authenticated
    // In a real app, you might want to show group info first
  }, [inviteToken])

  const handleJoinGroup = async () => {
    if (!inviteToken) return

    setIsJoining(true)
    setError(null)

    try {
      const result = await joinGroupMutation({
        input: { inviteToken },
      })

      if (result.error) {
        setError(result.error.message)
        setIsJoining(false)
        return
      }

      if (result.data?.joinGroup) {
        setSuccess(true)
        // Navigate to the group after 2 seconds
        setTimeout(() => {
          navigate(`/group/${result.data.joinGroup.id}/tasks`)
        }, 2000)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Неизвестная ошибка')
      setIsJoining(false)
    }
  }

  return (
    <Container id="join-group-page" maxWidth="sm" sx={{ mt: 8 }}>
      <Paper id="join-group-paper" sx={{ p: 4, textAlign: 'center' }}>
        {success ? (
          <>
            <CheckIcon id="join-success-icon" sx={{ fontSize: 80, color: 'success.main', mb: 2 }} />
            <Typography id="join-success-title" variant="h5" gutterBottom>
              Вы успешно присоединились к группе!
            </Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
              Перенаправление на страницу группы...
            </Typography>
          </>
        ) : (
          <>
            <GroupIcon id="join-icon" sx={{ fontSize: 80, color: 'primary.main', mb: 2 }} />
            <Typography id="join-title" variant="h5" gutterBottom>
              Присоединиться к группе
            </Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
              Вас пригласили присоединиться к группе. Нажмите кнопку ниже, чтобы подтвердить.
            </Typography>

            {error && (
              <Alert id="join-error" severity="error" sx={{ mb: 3, textAlign: 'left' }}>
                {error}
              </Alert>
            )}

            <Box sx={{ mt: 4, display: 'flex', gap: 2, justifyContent: 'center' }}>
              <Button
                id="join-cancel-button"
                variant="outlined"
                onClick={() => navigate('/groups')}
              >
                Отмена
              </Button>
              <Button
                id="join-confirm-button"
                variant="contained"
                onClick={handleJoinGroup}
                disabled={isJoining}
                startIcon={isJoining && <CircularProgress size={20} />}
              >
                {isJoining ? 'Присоединение...' : 'Присоединиться'}
              </Button>
            </Box>
          </>
        )}
      </Paper>
    </Container>
  )
}
