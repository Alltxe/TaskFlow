import { test, expect } from '@playwright/test'

test.describe('Groups Management', () => {
  test.beforeEach(async ({ page }) => {
    // Note: These tests require backend and authentication
    // For now, we'll navigate directly to test UI components
    await page.goto('http://localhost:5173/login')
  })

  test.describe('Groups List Page', () => {
    test('should display Groups page in navigation', async ({ page }) => {
      await page.goto('http://localhost:5173/groups')
      await expect(page).toHaveURL('/groups')
    })

    test('should show empty state when user has no groups', async ({ page }) => {
      await page.goto('http://localhost:5173/groups')
      
      // Check for empty state messaging
      await expect(page.locator('text=/нет групп|создайте первую группу/i')).toBeVisible()
      await expect(page.locator('button:has-text("Создать группу")')).toBeVisible()
    })

    test('should open Create Group wizard when clicking Create button', async ({ page }) => {
      await page.goto('http://localhost:5173/groups')
      
      // Click Create Group button (FAB or primary button)
      await page.click('button:has-text("Создать группу")')
      
      // Wizard should open
      await expect(page.locator('text=/создание группы|новая группа/i')).toBeVisible()
    })

    test.skip('should display group cards with correct information', async ({ page }) => {
      // Requires backend with test data
      await page.goto('http://localhost:5173/groups')
      
      // Check for group card elements
      const groupCard = page.locator('[data-testid="group-card"]').first()
      await expect(groupCard).toBeVisible()
      
      // Verify card content
      await expect(groupCard.locator('[data-testid="group-name"]')).toBeVisible()
      await expect(groupCard.locator('[data-testid="member-count"]')).toBeVisible()
      await expect(groupCard.locator('[data-testid="task-count"]')).toBeVisible()
      await expect(groupCard.locator('button:has-text("Открыть группу")')).toBeVisible()
    })

    test.skip('should navigate to group tasks when clicking Open Group', async ({ page }) => {
      // Requires backend with test data
      await page.goto('http://localhost:5173/groups')
      
      const groupCard = page.locator('[data-testid="group-card"]').first()
      const groupId = await groupCard.getAttribute('data-group-id')
      
      await groupCard.click('button:has-text("Открыть группу")')
      
      await expect(page).toHaveURL(`/group/${groupId}/tasks`)
    })

    test.skip('should show group menu on kebab icon click', async ({ page }) => {
      // Requires backend with test data
      await page.goto('http://localhost:5173/groups')
      
      const groupCard = page.locator('[data-testid="group-card"]').first()
      await groupCard.locator('[aria-label="group menu"]').click()
      
      // Menu should be visible
      await expect(page.locator('text="Покинуть группу"')).toBeVisible()
    })
  })

  test.describe('Create Group Wizard', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('http://localhost:5173/groups')
      await page.click('button:has-text("Создать группу")')
    })

    test('should display Step 1: Group Name', async ({ page }) => {
      await expect(page.locator('text=/название группы|шаг 1/i')).toBeVisible()
      await expect(page.locator('input[name="name"]')).toBeVisible()
      await expect(page.locator('button:has-text("Далее")')).toBeVisible()
      await expect(page.locator('button:has-text("Отмена")')).toBeVisible()
    })

    test('should validate group name on Step 1', async ({ page }) => {
      // Try to proceed with empty name
      await page.click('button:has-text("Далее")')
      
      await expect(page.locator('text=/название обязательно|введите название/i')).toBeVisible()
    })

    test('should proceed to Step 2: Control Mode after entering name', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      
      await expect(page.locator('text=/режим контроля|шаг 2/i')).toBeVisible()
      await expect(page.locator('text=/требуется подтверждение/i')).toBeVisible()
    })

    test('should navigate back to Step 1 from Step 2', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      
      await page.click('button:has-text("Назад")')
      
      await expect(page.locator('text=/название группы|шаг 1/i')).toBeVisible()
      // Name should be preserved
      await expect(page.locator('input[name="name"]')).toHaveValue('Test Group')
    })

    test('should proceed to Step 3: Rotation Mode', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      
      await expect(page.locator('text=/режим ротации|шаг 3/i')).toBeVisible()
      await expect(page.locator('text=/циклическая|случайная|отключена/i')).toBeVisible()
    })

    test('should select rotation mode option', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      
      // Select cyclic rotation
      await page.click('input[value="CYCLIC"]')
      await expect(page.locator('input[value="CYCLIC"]')).toBeChecked()
      
      await page.click('button:has-text("Далее")')
      
      // Should proceed to Step 4
      await expect(page.locator('text=/геймификация|шаг 4/i')).toBeVisible()
    })

    test('should proceed to Step 4: Gamification', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      
      await expect(page.locator('text=/геймификация|шаг 4/i')).toBeVisible()
      await expect(page.locator('text=/очки и награды/i')).toBeVisible()
    })

    test('should toggle gamification setting', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      
      // Toggle gamification
      const toggle = page.locator('[role="switch"]')
      const initialState = await toggle.getAttribute('aria-checked')
      
      await toggle.click()
      
      const newState = await toggle.getAttribute('aria-checked')
      expect(newState).not.toBe(initialState)
    })

    test('should proceed to Step 5: Review and Confirm', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      
      await expect(page.locator('text=/обзор и подтверждение|шаг 5/i')).toBeVisible()
      await expect(page.locator('text=Test Group')).toBeVisible()
    })

    test('should display all settings in review step', async ({ page }) => {
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      
      // Verify all settings are displayed
      await expect(page.locator('text=Test Group')).toBeVisible()
      await expect(page.locator('text=/циклическая/i')).toBeVisible()
      await expect(page.locator('button:has-text("Создать группу")')).toBeVisible()
    })

    test('should close wizard on cancel', async ({ page }) => {
      await page.click('button:has-text("Отмена")')
      
      // Wizard should be closed
      await expect(page.locator('text=/создание группы/i')).not.toBeVisible()
      // Should be back on Groups page
      await expect(page).toHaveURL('/groups')
    })

    test.skip('should create group successfully and redirect', async ({ page }) => {
      // Requires backend
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Создать группу")')
      
      // Should show success message
      await expect(page.locator('text=/группа создана|успешно/i')).toBeVisible()
      
      // Should redirect to group tasks page
      await expect(page).toHaveURL(/\/group\/.*\/tasks/)
    })

    test.skip('should handle creation error gracefully', async ({ page }) => {
      // Requires backend with error scenario
      await page.fill('input[name="name"]', 'Test Group')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('input[value="CYCLIC"]')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Далее")')
      await page.click('button:has-text("Создать группу")')
      
      // Should show error message
      await expect(page.locator('text=/ошибка|не удалось/i')).toBeVisible()
      
      // Wizard should remain open
      await expect(page.locator('text=/создание группы/i')).toBeVisible()
    })
  })

  test.describe('Group Navigation', () => {
    test.skip('should display group navigation tabs', async ({ page }) => {
      // Requires backend with group data
      const groupId = 'test-group-id'
      await page.goto(`http://localhost:5173/group/${groupId}/tasks`)
      
      await expect(page.locator('text="Задачи"')).toBeVisible()
      await expect(page.locator('text="Участники"')).toBeVisible()
      await expect(page.locator('text="Настройки"')).toBeVisible()
    })

    test.skip('should highlight active tab', async ({ page }) => {
      // Requires backend with group data
      const groupId = 'test-group-id'
      await page.goto(`http://localhost:5173/group/${groupId}/tasks`)
      
      const tasksTab = page.locator('a:has-text("Задачи")')
      await expect(tasksTab).toHaveClass(/active|selected/)
    })

    test.skip('should navigate between tabs', async ({ page }) => {
      // Requires backend with group data
      const groupId = 'test-group-id'
      await page.goto(`http://localhost:5173/group/${groupId}/tasks`)
      
      await page.click('text="Участники"')
      await expect(page).toHaveURL(`/group/${groupId}/members`)
      
      await page.click('text="Настройки"')
      await expect(page).toHaveURL(`/group/${groupId}/settings`)
      
      await page.click('text="Задачи"')
      await expect(page).toHaveURL(`/group/${groupId}/tasks`)
    })

    test.skip('should hide admin tabs for non-admin users', async ({ page }) => {
      // Requires backend with non-admin user
      const groupId = 'test-group-id'
      await page.goto(`http://localhost:5173/group/${groupId}/tasks`)
      
      await expect(page.locator('text="Настройки"')).not.toBeVisible()
    })

    test.skip('should show admin tabs for admin users', async ({ page }) => {
      // Requires backend with admin user
      const groupId = 'test-group-id'
      await page.goto(`http://localhost:5173/group/${groupId}/tasks`)
      
      await expect(page.locator('text="Настройки"')).toBeVisible()
      await expect(page.locator('text="Очередь проверки"')).toBeVisible()
    })
  })

  test.describe('Leave Group', () => {
    test.skip('should show confirmation dialog when leaving group', async ({ page }) => {
      // Requires backend with group data
      await page.goto('http://localhost:5173/groups')
      
      const groupCard = page.locator('[data-testid="group-card"]').first()
      await groupCard.locator('[aria-label="group menu"]').click()
      await page.click('text="Покинуть группу"')
      
      await expect(page.locator('text=/вы уверены|подтвердите/i')).toBeVisible()
      await expect(page.locator('button:has-text("Покинуть")')).toBeVisible()
      await expect(page.locator('button:has-text("Отмена")')).toBeVisible()
    })

    test.skip('should leave group on confirmation', async ({ page }) => {
      // Requires backend with group data
      await page.goto('http://localhost:5173/groups')
      
      const groupCard = page.locator('[data-testid="group-card"]').first()
      const groupName = await groupCard.locator('[data-testid="group-name"]').textContent()
      
      await groupCard.locator('[aria-label="group menu"]').click()
      await page.click('text="Покинуть группу"')
      await page.click('button:has-text("Покинуть")')
      
      // Should show success message
      await expect(page.locator('text=/вы покинули группу|успешно/i')).toBeVisible()
      
      // Group should be removed from list
      await expect(page.locator(`text="${groupName}"`)).not.toBeVisible()
    })

    test.skip('should cancel leave group action', async ({ page }) => {
      // Requires backend with group data
      await page.goto('http://localhost:5173/groups')
      
      const groupCard = page.locator('[data-testid="group-card"]').first()
      await groupCard.locator('[aria-label="group menu"]').click()
      await page.click('text="Покинуть группу"')
      await page.click('button:has-text("Отмена")')
      
      // Dialog should close
      await expect(page.locator('text=/вы уверены/i')).not.toBeVisible()
      
      // Should remain on groups page
      await expect(page).toHaveURL('/groups')
    })
  })
})
