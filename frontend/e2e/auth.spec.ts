import { test, expect } from '@playwright/test'

test.describe('Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173/')
  })

  test('should navigate from welcome to login page', async ({ page }) => {
    await page.click('text=Войти')
    await expect(page).toHaveURL('/login')
    await expect(page.locator('h1')).toContainText('Вход в TaskFlow')
  })

  test('should navigate from welcome to register page', async ({ page }) => {
    await page.click('text=Начать работу')
    await expect(page).toHaveURL('/register')
    await expect(page.locator('h1')).toContainText('Регистрация в TaskFlow')
  })

  test('should show validation errors on login with empty fields', async ({ page }) => {
    await page.goto('http://localhost:5173/login')
    await page.click('button:has-text("Войти")')
    
    await expect(page.locator('text=Email обязателен')).toBeVisible()
    await expect(page.locator('text=Пароль обязателен')).toBeVisible()
  })

  test('should show validation error for invalid email on login', async ({ page }) => {
    await page.goto('http://localhost:5173/login')
    
    const emailInput = page.locator('input[type="email"]')
    await emailInput.fill('invalid-email')
    await page.fill('input[type="password"]', 'password123')
    await emailInput.evaluate((el) => (el as HTMLInputElement).blur())
    
    await expect(page.locator('text=Некорректный формат email')).toBeVisible()
  })

  test('should toggle password visibility', async ({ page }) => {
    await page.goto('http://localhost:5173/login')
    
    const passwordInput = page.locator('input[type="password"]').first()
    await expect(passwordInput).toHaveAttribute('type', 'password')
    
    // Click toggle button
    await page.click('button[aria-label="toggle password visibility"]').catch(() => {
      // If aria-label is not set, try clicking the icon button near password input
      return page.locator('input[type="password"]').first().locator('..').locator('button').click()
    })
    
    await expect(passwordInput).toHaveAttribute('type', 'text')
  })

  test('should navigate to register from login page', async ({ page }) => {
    await page.goto('http://localhost:5173/login')
    await page.click('a:has-text("Зарегистрироваться")')
    
    await expect(page).toHaveURL('/register')
  })

  test('should show validation errors on register with empty fields', async ({ page }) => {
    await page.goto('http://localhost:5173/register')
    await page.click('button:has-text("Зарегистрироваться")')
    
    await expect(page.locator('text=Email обязателен')).toBeVisible()
    await expect(page.locator('text=Имя пользователя обязательно')).toBeVisible()
    await expect(page.locator('text=Пароль обязателен')).toBeVisible()
  })

  test('should validate username length on register', async ({ page }) => {
    await page.goto('http://localhost:5173/register')
    
    // Too short
    const usernameInput = page.locator('input[type="text"]')
    await usernameInput.fill('ab')
    await usernameInput.evaluate((el) => (el as HTMLInputElement).blur())
    
    await expect(page.locator('text=минимум 3 символа')).toBeVisible()
    
    // Too long
    await usernameInput.fill('a'.repeat(31))
    await usernameInput.evaluate((el) => (el as HTMLInputElement).blur())
    
    await expect(page.locator('text=максимум 30 символов')).toBeVisible()
  })

  test('should validate password confirmation on register', async ({ page }) => {
    await page.goto('http://localhost:5173/register')
    
    const passwordInputs = page.locator('input[type="password"]')
    await passwordInputs.nth(0).fill('password123')
    await passwordInputs.nth(1).fill('different')
    await passwordInputs.nth(1).evaluate((el) => (el as HTMLInputElement).blur())
    
    await expect(page.locator('text=Пароли не совпадают')).toBeVisible()
  })

  test('should navigate to login from register page', async ({ page }) => {
    await page.goto('http://localhost:5173/register')
    await page.click('a:has-text("Войти")')
    
    await expect(page).toHaveURL('/login')
  })

  // Note: These tests require backend to be running
  test.skip('should login successfully with valid credentials', async ({ page }) => {
    await page.goto('http://localhost:5173/login')
    
    await page.fill('input[type="email"]', 'test@example.com')
    await page.fill('input[type="password"]', 'password123')
    await page.click('button:has-text("Войти")')
    
    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('text=Добро пожаловать')).toBeVisible()
  })

  test.skip('should register successfully and redirect to dashboard', async ({ page }) => {
    await page.goto('http://localhost:5173/register')
    
    const timestamp = Date.now()
    await page.fill('input[type="email"]', `user${timestamp}@example.com`)
    await page.fill('input[type="text"]', `user${timestamp}`)
    const passwordInputs = page.locator('input[type="password"]')
    await passwordInputs.nth(0).fill('password123')
    await passwordInputs.nth(1).fill('password123')
    await page.click('button:has-text("Зарегистрироваться")')
    
    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('text=Добро пожаловать')).toBeVisible()
  })
})
