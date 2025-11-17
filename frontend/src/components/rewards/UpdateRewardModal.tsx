import type { FC } from 'react'
import { useState, useEffect } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Box,
} from '@mui/material'
import { useMutation } from 'urql'
import { UPDATE_REWARD_MUTATION } from '@api/queries'
import { isValidRewardCost } from '@lib/rewardHelpers'
import { showToast } from '@lib/toast'

export interface UpdateRewardModalProps {
  open: boolean
  reward: {
    id: string
    name: string
    description?: string | null
    cost: number
    imageUrl?: string | null
  } | null
  onClose: () => void
  onSuccess?: () => void
}

export const UpdateRewardModal: FC<UpdateRewardModalProps> = ({
  open,
  reward,
  onClose,
  onSuccess,
}) => {
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [cost, setCost] = useState<number | ''>('')
  const [imageUrl, setImageUrl] = useState('')

  const [errors, setErrors] = useState<{
    name?: string
    cost?: string
  }>({})

  const [, updateReward] = useMutation(UPDATE_REWARD_MUTATION)

  // Pre-fill form when reward changes
  useEffect(() => {
    if (reward) {
      setName(reward.name)
      setDescription(reward.description || '')
      setCost(reward.cost)
      setImageUrl(reward.imageUrl || '')
      setErrors({})
    }
  }, [reward])

  const validateForm = (): boolean => {
    const newErrors: typeof errors = {}

    if (!name.trim()) {
      newErrors.name = 'Название обязательно'
    } else if (name.trim().length < 3) {
      newErrors.name = 'Название должно содержать минимум 3 символа'
    }

    if (cost === '' || cost === 0) {
      newErrors.cost = 'Стоимость обязательна'
    } else if (!isValidRewardCost(Number(cost))) {
      newErrors.cost = 'Стоимость должна быть положительным целым числом'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!reward || !validateForm()) return

    const result = await updateReward({
      input: {
        rewardId: reward.id,
        name: name.trim(),
        description: description.trim() || null,
        cost: Number(cost),
        imageUrl: imageUrl.trim() || null,
      },
    })

    if (result.error) {
      showToast(`Ошибка обновления награды: ${result.error.message}`, 'error')
      return
    }

    showToast('Награда успешно обновлена!', 'success')
    handleClose()
    onSuccess?.()
  }

  const handleClose = () => {
    setName('')
    setDescription('')
    setCost('')
    setImageUrl('')
    setErrors({})
    onClose()
  }

  if (!reward) return null

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>Редактировать награду</DialogTitle>

      <DialogContent>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
          <TextField
            label="Название награды"
            value={name}
            onChange={(e) => setName(e.target.value)}
            error={!!errors.name}
            helperText={errors.name}
            fullWidth
            required
            autoFocus
          />

          <TextField
            label="Описание"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            fullWidth
            multiline
            rows={3}
            placeholder="Опишите награду (необязательно)"
          />

          <TextField
            label="Стоимость (в баллах)"
            value={cost}
            onChange={(e) => {
              const value = e.target.value
              if (value === '') {
                setCost('')
              } else {
                const num = parseInt(value, 10)
                if (!isNaN(num) && num >= 0) {
                  setCost(num)
                }
              }
            }}
            error={!!errors.cost}
            helperText={errors.cost || 'Введите количество баллов'}
            fullWidth
            required
            type="number"
            inputProps={{ min: 1, step: 1 }}
          />

          <TextField
            label="URL изображения"
            value={imageUrl}
            onChange={(e) => setImageUrl(e.target.value)}
            fullWidth
            placeholder="https://example.com/image.jpg (необязательно)"
          />
        </Box>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={handleClose}>Отмена</Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={!name.trim() || cost === '' || cost === 0}
        >
          Сохранить
        </Button>
      </DialogActions>
    </Dialog>
  )
}
