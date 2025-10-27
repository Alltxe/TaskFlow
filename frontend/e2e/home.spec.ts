import { test, expect } from '@playwright/test'

test.describe('Home Page', () => {
  test('should display coming soon message', async ({ page }) => {
    await page.goto('/')
    
    await expect(page.getByRole('heading', { name: /TaskFlow/i })).toBeVisible()
    await expect(page.getByText(/Coming Soon/i)).toBeVisible()
  })
})
