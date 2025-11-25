import type { FC } from 'react'
import { useState, useMemo } from 'react'
import { useParams } from 'react-router-dom'
import {
  Container,
  Typography,
  Box,
  Fab,
  TextField,
  MenuItem,
  Paper,
  Alert,
  CircularProgress,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Stack,
} from '@mui/material'
import {
  Add as AddIcon,
  ExpandMore as ExpandMoreIcon,
  Search as SearchIcon,
} from '@mui/icons-material'
import { useQuery, useMutation } from 'urql'
import {
  GET_GROUP_REWARDS_QUERY,
  GET_POINT_BALANCE_QUERY,
  DELETE_REWARD_MUTATION,
  GET_GROUP_MEMBERS_QUERY,
} from '@api/queries'
import { useAuthStore } from '@store/authStore'
import { RewardCard } from '@components/rewards/RewardCard'
import { CreateRewardModal } from '@components/rewards/CreateRewardModal'
import { UpdateRewardModal } from '@components/rewards/UpdateRewardModal'
import { RewardRequestModal } from '@components/rewards/RewardRequestModal'
import { RequestReviewQueue } from '@components/rewards/RequestReviewQueue'
import { sortRewards, filterRewardsByCost } from '@lib/rewardHelpers'
import { showToast } from '@lib/toast'

type SortOption = 'cost-asc' | 'cost-desc' | 'name' | 'newest'

export const GroupRewards: FC = () => {
  const { groupId } = useParams<{ groupId: string }>()
  const user = useAuthStore(state => state.user)

  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [updateModalOpen, setUpdateModalOpen] = useState(false)
  const [requestModalOpen, setRequestModalOpen] = useState(false)
  const [selectedReward, setSelectedReward] = useState<any>(null)

  const [searchQuery, setSearchQuery] = useState('')
  const [sortBy, setSortBy] = useState<SortOption>('newest')
  const [minCost, setMinCost] = useState<number | ''>('')
  const [maxCost, setMaxCost] = useState<number | ''>('')

  // Fetch rewards
  const [rewardsResult, reexecuteRewardsQuery] = useQuery({
    query: GET_GROUP_REWARDS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  // Fetch point balance
  const [balanceResult] = useQuery({
    query: GET_POINT_BALANCE_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  // Fetch group members to check if current user is admin
  const [membersResult] = useQuery({
    query: GET_GROUP_MEMBERS_QUERY,
    variables: { groupId: groupId! },
    pause: !groupId,
  })

  const [, deleteReward] = useMutation(DELETE_REWARD_MUTATION)

  // Determine if current user is admin
  const isAdmin = useMemo(() => {
    if (!user || !membersResult.data?.getGroupMembers) return false
    const currentMember = membersResult.data.getGroupMembers.find((m: any) => m.userId === user.id)
    return currentMember?.role === 'ADMIN'
  }, [user, membersResult.data])

  // Filter and sort rewards
  const filteredRewards = useMemo(() => {
    if (!rewardsResult.data?.getGroupRewards) return []

    let filtered = [...rewardsResult.data.getGroupRewards]

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (reward: any) =>
          reward.name.toLowerCase().includes(query) ||
          reward.description?.toLowerCase().includes(query)
      )
    }

    // Filter by cost range
    filtered = filterRewardsByCost(
      filtered,
      minCost === '' ? undefined : Number(minCost),
      maxCost === '' ? undefined : Number(maxCost)
    )

    // Sort
    filtered = sortRewards(filtered, sortBy)

    return filtered
  }, [rewardsResult.data, searchQuery, minCost, maxCost, sortBy])

  const handleRequestReward = (rewardId: string) => {
    const reward = rewardsResult.data?.getGroupRewards.find((r: any) => r.id === rewardId)
    if (reward) {
      setSelectedReward(reward)
      setRequestModalOpen(true)
    }
  }

  const handleEditReward = (rewardId: string) => {
    const reward = rewardsResult.data?.getGroupRewards.find((r: any) => r.id === rewardId)
    if (reward) {
      setSelectedReward(reward)
      setUpdateModalOpen(true)
    }
  }

  const handleDeleteReward = async (rewardId: string) => {
    if (!window.confirm('Вы уверены, что хотите удалить эту награду?')) return

    const result = await deleteReward({ rewardId, groupId: groupId! })

    if (result.error) {
      showToast(`Ошибка удаления награды: ${result.error.message}`, 'error')
      return
    }

    showToast('Награда успешно удалена!', 'success')
    reexecuteRewardsQuery({ requestPolicy: 'network-only' })
  }

  const handleSuccess = () => {
    reexecuteRewardsQuery({ requestPolicy: 'network-only' })
  }

  if (!groupId) {
    return (
      <Container maxWidth="lg" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">Группа не найдена</Alert>
      </Container>
    )
  }

  if (rewardsResult.fetching || balanceResult.fetching || membersResult.fetching) {
    return (
      <Container maxWidth="lg" sx={{ mt: 3, mb: 8 }}>
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

  if (rewardsResult.error) {
    return (
      <Container maxWidth="lg" sx={{ mt: 3, mb: 8 }}>
        <Alert severity="error">Ошибка загрузки наград: {rewardsResult.error.message}</Alert>
      </Container>
    )
  }

  const availableBalance = balanceResult.data?.getPointBalance?.availableBalance || 0

  return (
    <Container id={`group-rewards-page-${groupId}`} maxWidth="lg" sx={{ mt: 3, mb: 8 }}>
      <Typography id="group-rewards-title" variant="h4" gutterBottom>
        Каталог наград
      </Typography>

      <Typography variant="body1" color="text.secondary" gutterBottom sx={{ mb: 4 }}>
        Используйте заработанные баллы для получения наград
      </Typography>

      {/* Admin section: Review Queue */}
      {isAdmin && (
        <Accordion sx={{ mb: 3 }}>
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="h6">Запросы на награды (Администратор)</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <RequestReviewQueue groupId={groupId} />
          </AccordionDetails>
        </Accordion>
      )}

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
          <Box sx={{ flex: '1 1 300px', minWidth: { xs: '100%', sm: '300px' } }}>
            <TextField
              id="group-rewards-search-input"
              fullWidth
              size="small"
              label="Поиск наград"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              placeholder="Название или описание..."
              InputProps={{
                startAdornment: <SearchIcon sx={{ mr: 1, color: 'text.secondary' }} />,
              }}
            />
          </Box>
          <Box sx={{ flex: '0 1 200px', minWidth: { xs: '100%', sm: '150px' } }}>
            <TextField
              id="group-rewards-sort-select"
              fullWidth
              size="small"
              select
              label="Сортировка"
              value={sortBy}
              onChange={e => setSortBy(e.target.value as SortOption)}
            >
              <MenuItem value="newest">Новые</MenuItem>
              <MenuItem value="cost-asc">Цена: по возрастанию</MenuItem>
              <MenuItem value="cost-desc">Цена: по убыванию</MenuItem>
              <MenuItem value="name">По названию</MenuItem>
            </TextField>
          </Box>
          <Box sx={{ flex: '0 1 120px', minWidth: '100px' }}>
            <TextField
              id="group-rewards-min-cost"
              fullWidth
              size="small"
              type="number"
              label="Мин. цена"
              value={minCost}
              onChange={e => setMinCost(e.target.value === '' ? '' : parseInt(e.target.value, 10))}
              inputProps={{ min: 0 }}
            />
          </Box>
          <Box sx={{ flex: '0 1 120px', minWidth: '100px' }}>
            <TextField
              id="group-rewards-max-cost"
              fullWidth
              size="small"
              type="number"
              label="Макс. цена"
              value={maxCost}
              onChange={e => setMaxCost(e.target.value === '' ? '' : parseInt(e.target.value, 10))}
              inputProps={{ min: 0 }}
            />
          </Box>
        </Stack>
      </Paper>

      {/* Rewards Grid */}
      {filteredRewards.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="body1" color="text.secondary">
            {searchQuery || minCost !== '' || maxCost !== ''
              ? 'Награды не найдены. Попробуйте изменить фильтры.'
              : isAdmin
                ? 'Награды еще не созданы. Нажмите кнопку "+" для создания первой награды.'
                : 'Награды еще не добавлены администратором.'}
          </Typography>
        </Paper>
      ) : (
        <Box
          id="group-rewards-grid"
          sx={{
            display: 'grid',
            gridTemplateColumns: {
              xs: '1fr',
              sm: 'repeat(2, 1fr)',
              md: 'repeat(3, 1fr)',
            },
            gap: 3,
          }}
        >
          {filteredRewards.map((reward: any) => (
            <RewardCard
              key={reward.id}
              reward={reward}
              availableBalance={availableBalance}
              isAdmin={isAdmin}
              onRequest={handleRequestReward}
              onEdit={handleEditReward}
              onDelete={handleDeleteReward}
            />
          ))}
        </Box>
      )}

      {/* FAB for creating rewards (admin only) */}
      {isAdmin && (
        <Fab
          id="group-create-reward-fab"
          color="primary"
          aria-label="Создать награду"
          sx={{ position: 'fixed', bottom: 24, right: 24 }}
          onClick={() => setCreateModalOpen(true)}
        >
          <AddIcon />
        </Fab>
      )}

      {/* Modals */}
      <CreateRewardModal
        open={createModalOpen}
        groupId={groupId}
        onClose={() => setCreateModalOpen(false)}
        onSuccess={handleSuccess}
      />

      <UpdateRewardModal
        open={updateModalOpen}
        reward={selectedReward}
        onClose={() => {
          setUpdateModalOpen(false)
          setSelectedReward(null)
        }}
        onSuccess={handleSuccess}
      />

      <RewardRequestModal
        open={requestModalOpen}
        reward={selectedReward}
        groupId={groupId}
        availableBalance={availableBalance}
        onClose={() => {
          setRequestModalOpen(false)
          setSelectedReward(null)
        }}
        onSuccess={handleSuccess}
      />
    </Container>
  )
}
