import { describe, it, expect, vi, beforeEach } from 'vitest'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../test/utils'
import userEvent from '@testing-library/user-event'
import { fromValue } from 'wonka'
import { CreateGroupWizard } from './CreateGroupWizard'

const mockClient = {
  executeMutation: vi.fn(() =>
    fromValue({
      data: {
        createGroup: {
          id: 'new-group-id',
          name: 'New Group',
          description: 'Test description',
          inviteToken: 'token123',
          requiresApproval: true,
          rotationType: 'ROUND_ROBIN',
          gamificationEnabled: true,
          createdAt: '2025-11-15T10:00:00.000Z',
          createdById: 'user1',
        },
      },
    })
  ),
}

const renderWizard = (props = {}, client = mockClient) => {
  return render(<CreateGroupWizard open={true} onClose={vi.fn()} {...props} />, {
    urqlClient: client as any,
  })
}

describe('CreateGroupWizard', () => {
  beforeEach(() => {
    mockClient.executeMutation.mockClear()
  })

  it('renders first step with group name input', () => {
    renderWizard()

    expect(screen.getByText('Создать новую группу')).toBeInTheDocument()
    expect(screen.getByLabelText(/Название группы/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/Описание/i)).toBeInTheDocument()
  })

  it('shows stepper with all steps', () => {
    renderWizard()

    // Use getAllByText for duplicate labels (stepper + form)
    expect(screen.getAllByText('Название группы').length).toBeGreaterThan(0)
    expect(screen.getByText('Режим управления')).toBeInTheDocument()
    expect(screen.getByText('Режим ротации')).toBeInTheDocument()
    expect(screen.getByText('Геймификация')).toBeInTheDocument()
    expect(screen.getByText('Подтверждение')).toBeInTheDocument()
  })

  it('validates group name (minimum 3 characters)', async () => {
    const user = userEvent.setup()
    renderWizard()

    const nextButton = screen.getByRole('button', { name: /далее/i })
    expect(nextButton).toBeDisabled()

    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'Te')
    expect(nextButton).toBeDisabled()

    await user.type(nameInput, 'st')
    expect(nextButton).toBeEnabled()
  })

  it('navigates through wizard steps', async () => {
    const user = userEvent.setup()
    renderWizard()

    // Step 1: Enter name
    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'Test Group')

    const nextButton = screen.getByRole('button', { name: /далее/i })
    await user.click(nextButton)

    // Step 2: Control mode
    await waitFor(() => {
      expect(screen.getByText(/Режим управления задачами/i)).toBeInTheDocument()
    })

    await user.click(nextButton)

    // Step 3: Rotation mode
    await waitFor(() => {
      expect(screen.getByText(/Режим ротации исполнителей/i)).toBeInTheDocument()
    })

    await user.click(nextButton)

    // Step 4: Gamification
    await waitFor(() => {
      expect(screen.getByText(/Система геймификации/i)).toBeInTheDocument()
    })

    await user.click(nextButton)

    // Step 5: Review
    await waitFor(() => {
      expect(screen.getByText(/Проверьте настройки группы/i)).toBeInTheDocument()
    })
  })

  it('allows navigation backwards', async () => {
    const user = userEvent.setup()
    renderWizard()

    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'Test Group')

    const nextButton = screen.getByRole('button', { name: /далее/i })
    await user.click(nextButton)

    await waitFor(() => {
      expect(screen.getByText(/Режим управления задачами/i)).toBeInTheDocument()
    })

    const backButton = screen.getByRole('button', { name: /назад/i })
    expect(backButton).toBeEnabled()

    await user.click(backButton)

    await waitFor(() => {
      expect(screen.getByLabelText(/Название группы/i)).toBeInTheDocument()
    })
  })

  it('displays review with all entered data', async () => {
    const user = userEvent.setup()
    renderWizard()

    // Fill in name
    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'My Test Group')

    const descInput = screen.getByLabelText(/Описание/i)
    await user.type(descInput, 'My test description')

    // Navigate through all steps
    const nextButton = screen.getByRole('button', { name: /далее/i })
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)

    // Check review step
    await waitFor(() => {
      expect(screen.getByText('My Test Group')).toBeInTheDocument()
      expect(screen.getByText('My test description')).toBeInTheDocument()
      expect(screen.getByText('С проверкой выполнения')).toBeInTheDocument()
      expect(screen.getByText('Циклическая ротация')).toBeInTheDocument()
      expect(screen.getByText('Включена')).toBeInTheDocument()
    })
  })

  it('submits form and navigates on success', async () => {
    const user = userEvent.setup()
    const onClose = vi.fn()
    renderWizard({ onClose })

    // Fill in name
    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'Test Group')

    // Navigate to final step
    const nextButton = screen.getByRole('button', { name: /далее/i })
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)

    // Submit
    const createButton = screen.getByRole('button', { name: /создать группу/i })
    await user.click(createButton)

    await waitFor(() => {
      expect(mockClient.executeMutation).toHaveBeenCalled()
      expect(onClose).toHaveBeenCalled()
    })
  })

  it('handles submission errors', async () => {
    const user = userEvent.setup()
    const errorClient = {
      executeMutation: vi.fn(() =>
        fromValue({
          error: {
            message: 'Failed to create group',
          },
        })
      ),
    }

    renderWizard({}, errorClient)

    const nameInput = screen.getByLabelText(/Название группы/i)
    await user.type(nameInput, 'Test Group')

    const nextButton = screen.getByRole('button', { name: /далее/i })
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)
    await user.click(nextButton)

    const createButton = screen.getByRole('button', { name: /создать группу/i })
    await user.click(createButton)

    await waitFor(() => {
      expect(screen.getByText(/Failed to create group/i)).toBeInTheDocument()
    })
  })
})
