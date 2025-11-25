import { type FC, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Stepper,
  Step,
  StepLabel,
  TextField,
  FormControl,
  FormLabel,
  RadioGroup,
  FormControlLabel,
  Radio,
  Switch,
  Typography,
  Box,
  Alert,
  Paper,
} from '@mui/material'
import { useMutation } from 'urql'
import { CREATE_GROUP_MUTATION } from '@api/queries'
import { useNavigate } from 'react-router-dom'

interface CreateGroupWizardProps {
  open: boolean
  onClose: () => void
}

interface GroupFormData {
  name: string
  description: string
  requiresApproval: boolean
  rotationType: 'ROUND_ROBIN' | 'RANDOM' | 'LOAD_BALANCING' | 'DISABLED'
  gamificationEnabled: boolean
}

const steps = [
  'Название группы',
  'Режим управления',
  'Режим ротации',
  'Геймификация',
  'Подтверждение',
]

export const CreateGroupWizard: FC<CreateGroupWizardProps> = ({ open, onClose }) => {
  const navigate = useNavigate()
  const [activeStep, setActiveStep] = useState(0)
  const [formData, setFormData] = useState<GroupFormData>({
    name: '',
    description: '',
    requiresApproval: true,
    rotationType: 'ROUND_ROBIN',
    gamificationEnabled: true,
  })

  const [, createGroupMutation] = useMutation(CREATE_GROUP_MUTATION)
  const [error, setError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleNext = () => {
    setActiveStep(prevActiveStep => prevActiveStep + 1)
  }

  const handleBack = () => {
    setActiveStep(prevActiveStep => prevActiveStep - 1)
  }

  const handleReset = () => {
    setActiveStep(0)
    setFormData({
      name: '',
      description: '',
      requiresApproval: true,
      rotationType: 'ROUND_ROBIN',
      gamificationEnabled: true,
    })
    setError(null)
    setIsSubmitting(false)
  }

  const handleSubmit = async () => {
    setError(null)
    setIsSubmitting(true)

    try {
      const result = await createGroupMutation({
        input: {
          name: formData.name,
          description: formData.description || undefined,
          requiresApproval: formData.requiresApproval,
          rotationType: formData.rotationType,
          gamificationEnabled: formData.gamificationEnabled,
        },
      })

      if (result.error) {
        setError(result.error.message)
        setIsSubmitting(false)
        return
      }

      if (result.data?.createGroup) {
        // Success - navigate to the new group
        const groupId = result.data.createGroup.id
        handleReset()
        onClose()
        navigate(`/group/${groupId}/tasks`)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Неизвестная ошибка')
      setIsSubmitting(false)
    }
  }

  const handleClose = () => {
    if (!isSubmitting) {
      handleReset()
      onClose()
    }
  }

  const isStepValid = () => {
    switch (activeStep) {
      case 0:
        return formData.name.trim().length >= 3
      default:
        return true
    }
  }

  const renderStepContent = () => {
    switch (activeStep) {
      case 0:
        return (
          <Box sx={{ pt: 2 }}>
            <TextField
              id="create-group-name-input"
              fullWidth
              label="Название группы"
              value={formData.name}
              onChange={e => setFormData({ ...formData, name: e.target.value })}
              helperText="Минимум 3 символа"
              required
              autoFocus
              sx={{ mb: 3 }}
            />
            <TextField
              id="create-group-desc-input"
              fullWidth
              label="Описание (необязательно)"
              value={formData.description}
              onChange={e => setFormData({ ...formData, description: e.target.value })}
              multiline
              rows={3}
              helperText="Краткое описание назначения группы"
            />
          </Box>
        )

      case 1:
        return (
          <Box sx={{ pt: 2 }}>
            <FormControl component="fieldset">
              <FormLabel component="legend" sx={{ mb: 2 }}>
                Режим управления задачами
              </FormLabel>
              <FormControlLabel
                id="create-group-requires-approval"
                control={
                  <Switch
                    checked={formData.requiresApproval}
                    onChange={e => setFormData({ ...formData, requiresApproval: e.target.checked })}
                  />
                }
                label="Требуется проверка выполнения задач"
              />
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1, ml: 4 }}>
                Если включено, администратор должен одобрить выполненные задачи перед начислением
                очков
              </Typography>
            </FormControl>
          </Box>
        )

      case 2:
        return (
          <Box sx={{ pt: 2 }}>
            <FormControl component="fieldset">
              <FormLabel component="legend" sx={{ mb: 2 }}>
                Режим ротации исполнителей
              </FormLabel>
              <RadioGroup
                id="create-group-rotation-group"
                value={formData.rotationType}
                onChange={e =>
                  setFormData({
                    ...formData,
                    rotationType: e.target.value as GroupFormData['rotationType'],
                  })
                }
              >
                <FormControlLabel
                  id="create-group-rotation-ROUND_ROBIN"
                  value="ROUND_ROBIN"
                  control={<Radio />}
                  label="Циклическая ротация"
                />
                <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
                  Задачи распределяются по очереди среди участников
                </Typography>

                <FormControlLabel
                  id="create-group-rotation-RANDOM"
                  value="RANDOM"
                  control={<Radio />}
                  label="Случайная ротация"
                />
                <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
                  Случайный выбор исполнителя для каждой задачи
                </Typography>

                <FormControlLabel
                  id="create-group-rotation-LOAD_BALANCING"
                  value="LOAD_BALANCING"
                  control={<Radio />}
                  label="Балансировка нагрузки"
                />
                <Typography variant="body2" color="text.secondary" sx={{ ml: 4, mb: 2 }}>
                  Автоматическое выравнивание количества задач между участниками
                </Typography>

                <FormControlLabel
                  id="create-group-rotation-DISABLED"
                  value="DISABLED"
                  control={<Radio />}
                  label="Без ротации"
                />
                <Typography variant="body2" color="text.secondary" sx={{ ml: 4 }}>
                  Задачи назначаются вручную администратором
                </Typography>
              </RadioGroup>
            </FormControl>
          </Box>
        )

      case 3:
        return (
          <Box sx={{ pt: 2 }}>
            <FormControl component="fieldset">
              <FormLabel component="legend" sx={{ mb: 2 }}>
                Система геймификации
              </FormLabel>
              <FormControlLabel
                id="create-group-gamification"
                control={
                  <Switch
                    checked={formData.gamificationEnabled}
                    onChange={e =>
                      setFormData({ ...formData, gamificationEnabled: e.target.checked })
                    }
                  />
                }
                label="Включить очки и награды"
              />
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1, ml: 4 }}>
                Участники будут получать очки за выполнение задач и смогут обменивать их на награды.
                Также будет доступна таблица лидеров.
              </Typography>
            </FormControl>
          </Box>
        )

      case 4:
        return (
          <Box sx={{ pt: 2 }}>
            <Paper variant="outlined" sx={{ p: 3, bgcolor: 'background.default' }}>
              <Typography variant="h6" gutterBottom>
                Проверьте настройки группы
              </Typography>

              <Box sx={{ mt: 3 }}>
                <Typography
                  id="create-group-review-name-label"
                  variant="subtitle2"
                  color="text.secondary"
                >
                  Название
                </Typography>
                <Typography id="create-group-review-name" variant="body1" gutterBottom>
                  {formData.name}
                </Typography>

                {formData.description && (
                  <>
                    <Typography
                      id="create-group-review-desc-label"
                      variant="subtitle2"
                      color="text.secondary"
                      sx={{ mt: 2 }}
                    >
                      Описание
                    </Typography>
                    <Typography id="create-group-review-desc" variant="body1" gutterBottom>
                      {formData.description}
                    </Typography>
                  </>
                )}

                <Typography
                  id="create-group-review-requires-approval-label"
                  variant="subtitle2"
                  color="text.secondary"
                  sx={{ mt: 2 }}
                >
                  Режим управления
                </Typography>
                <Typography id="create-group-review-requires-approval" variant="body1" gutterBottom>
                  {formData.requiresApproval ? 'С проверкой выполнения' : 'Без проверки выполнения'}
                </Typography>

                <Typography
                  id="create-group-review-rotation-label"
                  variant="subtitle2"
                  color="text.secondary"
                  sx={{ mt: 2 }}
                >
                  Режим ротации
                </Typography>
                <Typography id="create-group-review-rotation" variant="body1" gutterBottom>
                  {formData.rotationType === 'ROUND_ROBIN' && 'Циклическая ротация'}
                  {formData.rotationType === 'RANDOM' && 'Случайная ротация'}
                  {formData.rotationType === 'LOAD_BALANCING' && 'Балансировка нагрузки'}
                  {formData.rotationType === 'DISABLED' && 'Без ротации'}
                </Typography>

                <Typography
                  id="create-group-review-gamification-label"
                  variant="subtitle2"
                  color="text.secondary"
                  sx={{ mt: 2 }}
                >
                  Геймификация
                </Typography>
                <Typography id="create-group-review-gamification" variant="body1">
                  {formData.gamificationEnabled ? 'Включена' : 'Выключена'}
                </Typography>
              </Box>
            </Paper>

            {error && (
              <Alert severity="error" sx={{ mt: 2 }}>
                {error}
              </Alert>
            )}
          </Box>
        )

      default:
        return null
    }
  }

  return (
    <Dialog
      id="create-group-dialog"
      open={open}
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
      disableEscapeKeyDown={isSubmitting}
    >
      <DialogTitle id="create-group-dialog-title">Создать новую группу</DialogTitle>
      <DialogContent>
        <Stepper id="create-group-stepper" activeStep={activeStep} sx={{ pt: 3, pb: 4 }}>
          {steps.map(label => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>

        {renderStepContent()}
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 3 }}>
        <Button id="create-group-cancel" onClick={handleClose} disabled={isSubmitting}>
          Отмена
        </Button>
        <Box sx={{ flex: '1 1 auto' }} />
        <Button
          id="create-group-back"
          disabled={activeStep === 0 || isSubmitting}
          onClick={handleBack}
        >
          Назад
        </Button>
        {activeStep === steps.length - 1 ? (
          <Button
            id="create-group-submit"
            variant="contained"
            onClick={handleSubmit}
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Создание...' : 'Создать группу'}
          </Button>
        ) : (
          <Button
            id="create-group-next"
            variant="contained"
            onClick={handleNext}
            disabled={!isStepValid()}
          >
            Далее
          </Button>
        )}
      </DialogActions>
    </Dialog>
  )
}
