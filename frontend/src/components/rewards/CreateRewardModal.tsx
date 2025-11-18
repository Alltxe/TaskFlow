import type { FC } from 'react'
import { useState } from 'react'
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
import { CREATE_REWARD_MUTATION } from '@api/queries'
import { isValidRewardCost } from '@lib/rewardHelpers'
import { showToast } from '@lib/toast'

export interface CreateRewardModalProps {
  open: boolean
  groupId: string
  onClose: () => void
  onSuccess?: () => void
}

export const CreateRewardModal: FC<CreateRewardModalProps> = ({
  open,
  groupId,
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

  const [, createReward] = useMutation(CREATE_REWARD_MUTATION)

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
    if (!validateForm()) return

    const result = await createReward({
      input: {
        groupId,
        name: name.trim(),
        description: description.trim() || null,
        cost: Number(cost),
        imageUrl: imageUrl.trim() || null,
      },
    })

    if (result.error) {
      showToast(`Ошибка создания награды: ${result.error.message}`, 'error')
      return
    }

    showToast('Награда успешно создана!', 'success')
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

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>Создать награду</DialogTitle>

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
          Создать
        </Button>
      </DialogActions>
    </Dialog>
  )
}
