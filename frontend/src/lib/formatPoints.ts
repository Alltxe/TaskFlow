/**
 * Utility functions for formatting point values in the TaskFlow application
 */

/**
 * Format points with localized number formatting
 * @param points - The number of points to format
 * @returns Formatted string like "1,250 баллов"
 */
export function formatPoints(points: number): string {
  const formatted = new Intl.NumberFormat('ru-RU').format(points)
  return `${formatted} ${getPointsWord(points)}`
}

/**
 * Format point difference with +/- sign
 * @param amount - The amount of points (positive or negative)
 * @returns Formatted string like "+50 баллов" or "-20 баллов"
 */
export function formatPointsDiff(amount: number): string {
  const sign = amount >= 0 ? '+' : ''
  const formatted = new Intl.NumberFormat('ru-RU').format(amount)
  return `${sign}${formatted} ${getPointsWord(Math.abs(amount))}`
}

/**
 * Get the correct Russian word form for "points" based on the number
 * Russian has different forms: "балл" (1), "балла" (2-4), "баллов" (5+, 0)
 * @param count - The number of points
 * @returns The correct word form: "балл", "балла", or "баллов"
 */
function getPointsWord(count: number): string {
  const absCount = Math.abs(count) % 100
  const lastDigit = absCount % 10

  if (absCount >= 11 && absCount <= 19) {
    return 'баллов'
  }

  if (lastDigit === 1) {
    return 'балл'
  }

  if (lastDigit >= 2 && lastDigit <= 4) {
    return 'балла'
  }

  return 'баллов'
}

/**
 * Format points for compact display (e.g., in badges)
 * @param points - The number of points
 * @returns Compact string like "1.2K" for 1250 or "250" for small numbers
 */
export function formatPointsCompact(points: number): string {
  if (points >= 1000000) {
    return `${(points / 1000000).toFixed(1)}M`
  }
  if (points >= 1000) {
    return `${(points / 1000).toFixed(1)}K`
  }
  return points.toString()
}

/**
 * Calculate point multiplier display string
 * @param multiplier - The multiplier value (e.g., 1.5 for Up-for-Grabs bonus)
 * @returns Formatted string like "×1.5"
 */
export function formatMultiplier(multiplier: number): string {
  return `×${multiplier.toFixed(1)}`
}

/**
 * Calculate final points with multiplier
 * @param basePoints - Base points before multiplier
 * @param multiplier - Multiplier value
 * @returns Final points amount (rounded)
 */
export function calculateFinalPoints(basePoints: number, multiplier: number): number {
  return Math.round(basePoints * multiplier)
}
