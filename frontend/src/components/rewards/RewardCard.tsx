import type { FC } from 'react'
import {
  Card,
  CardContent,
  CardActions,
  Typography,
  Button,
  Chip,
  IconButton,
  Box,
  CardMedia,
} from '@mui/material'
import { Edit as EditIcon, Delete as DeleteIcon, Stars as StarsIcon } from '@mui/icons-material'
import { formatPoints } from '@lib/formatPoints'
import { canAffordReward } from '@lib/rewardHelpers'

export interface RewardCardProps {
  reward: {
    id: string
    name: string
    description?: string | null
    cost: number
    imageUrl?: string | null
  }
  availableBalance: number
  isAdmin: boolean
  onRequest?: (rewardId: string) => void
  onEdit?: (rewardId: string) => void
  onDelete?: (rewardId: string) => void
}

export const RewardCard: FC<RewardCardProps> = ({
  reward,
  availableBalance,
  isAdmin,
  onRequest,
  onEdit,
  onDelete,
}) => {
  const affordable = canAffordReward(availableBalance, reward.cost)

  return (
    <Card
      id={`reward-card-${reward.id}`}
      sx={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        transition: 'transform 0.2s, box-shadow 0.2s',
        border: affordable ? '2px solid' : '1px solid',
        borderColor: affordable ? 'success.main' : 'divider',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: 4,
        },
      }}
    >
      {reward.imageUrl && (
        <CardMedia
          component="img"
          height="140"
          image={reward.imageUrl}
          alt={reward.name}
          sx={{ objectFit: 'cover' }}
        />
      )}

      <CardContent sx={{ flexGrow: 1 }}>
        <Box
          sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}
        >
          <Typography id={`reward-title-${reward.id}`} variant="h6" component="h3" gutterBottom>
            {reward.name}
          </Typography>
          {isAdmin && (
            <Box>
              <IconButton
                size="small"
                onClick={() => onEdit?.(reward.id)}
                aria-label="Редактировать награду"
                id={`reward-action-edit-${reward.id}`}
              >
                <EditIcon fontSize="small" />
              </IconButton>
              <IconButton
                size="small"
                onClick={() => onDelete?.(reward.id)}
                color="error"
                aria-label="Удалить награду"
                id={`reward-action-delete-${reward.id}`}
              >
                <DeleteIcon fontSize="small" />
              </IconButton>
            </Box>
          )}
        </Box>

        {reward.description && (
          <Typography
            variant="body2"
            color="text.secondary"
            sx={{
              mb: 2,
              display: '-webkit-box',
              WebkitLineClamp: 3,
              WebkitBoxOrient: 'vertical',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {reward.description}
          </Typography>
        )}

        <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', mt: 'auto' }}>
          <Chip
            id={`reward-cost-${reward.id}`}
            icon={<StarsIcon />}
            label={formatPoints(reward.cost)}
            color={affordable ? 'success' : 'default'}
            size="small"
            sx={{ fontWeight: 600 }}
          />
          {affordable && (
            <Chip
              id={`reward-available-${reward.id}`}
              label="Доступно"
              color="success"
              size="small"
              variant="outlined"
            />
          )}
        </Box>
      </CardContent>

      {!isAdmin && (
        <CardActions sx={{ p: 2, pt: 0 }}>
          <Button
            id={`reward-action-request-${reward.id}`}
            variant="contained"
            fullWidth
            disabled={!affordable}
            onClick={() => onRequest?.(reward.id)}
            startIcon={<StarsIcon />}
          >
            {affordable ? 'Запросить награду' : 'Недостаточно баллов'}
          </Button>
        </CardActions>
      )}
    </Card>
  )
}
