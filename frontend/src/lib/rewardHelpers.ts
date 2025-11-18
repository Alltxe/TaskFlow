/**
 * Utility functions for reward-related operations in the TaskFlow application
 */

/**
 * Check if user can afford a reward based on available balance
 * @param availableBalance - User's available points (not reserved)
 * @param rewardCost - Cost of the reward in points
 * @returns true if user has enough available balance
 */
export function canAffordReward(availableBalance: number, rewardCost: number): boolean {
  return availableBalance >= rewardCost
}

/**
 * Calculate new available balance after requesting a reward
 * Points are reserved (not deducted) until admin approves
 * @param currentBalance - Current available balance
 * @param rewardCost - Cost of the reward
 * @returns New available balance after reservation
 */
export function calculateNewBalance(currentBalance: number, rewardCost: number): number {
  return currentBalance - rewardCost
}

/**
 * Get status badge color for reward request status
 * @param status - Reward transaction status
 * @returns MUI color for Chip component
 */
export function getRewardStatusColor(
  status: string
): 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning' {
  switch (status.toUpperCase()) {
    case 'RESERVED':
      return 'warning'
    case 'APPROVED':
      return 'success'
    case 'REJECTED':
      return 'error'
    default:
      return 'default'
  }
}

/**
 * Get Russian label for reward request status
 * @param status - Reward transaction status
 * @returns Localized status label
 */
export function getRewardStatusLabel(status: string): string {
  switch (status.toUpperCase()) {
    case 'RESERVED':
      return 'Ожидает одобрения'
    case 'APPROVED':
      return 'Одобрено'
    case 'REJECTED':
      return 'Отклонено'
    default:
      return status
  }
}

/**
 * Check if reward is affordable and provide user-friendly message
 * @param availableBalance - User's available points
 * @param rewardCost - Cost of the reward
 * @returns Object with canAfford boolean and optional message
 */
export function checkRewardAffordability(
  availableBalance: number,
  rewardCost: number
): { canAfford: boolean; message?: string } {
  if (availableBalance >= rewardCost) {
    return { canAfford: true }
  }

  const shortage = rewardCost - availableBalance
  return {
    canAfford: false,
    message: `Не хватает ${shortage} ${getPointsWord(shortage)} для запроса этой награды`,
  }
}

/**
 * Get the correct Russian word form for "points" based on the number
 * Same logic as formatPoints.ts
 * @param count - The number of points
 * @returns The correct word form
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
 * Validate reward cost (must be positive integer)
 * @param cost - Reward cost to validate
 * @returns true if cost is valid
 */
export function isValidRewardCost(cost: number): boolean {
  return Number.isInteger(cost) && cost > 0
}

/**
 * Sort rewards by different criteria
 * @param rewards - Array of rewards
 * @param sortBy - Sort criteria
 * @returns Sorted array
 */
export function sortRewards<T extends { cost: number; name: string; createdAt: string }>(
  rewards: T[],
  sortBy: 'cost-asc' | 'cost-desc' | 'name' | 'newest'
): T[] {
  const sorted = [...rewards]

  switch (sortBy) {
    case 'cost-asc':
      return sorted.sort((a, b) => a.cost - b.cost)
    case 'cost-desc':
      return sorted.sort((a, b) => b.cost - a.cost)
    case 'name':
      return sorted.sort((a, b) => a.name.localeCompare(b.name, 'ru'))
    case 'newest':
      return sorted.sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      )
    default:
      return sorted
  }
}

/**
 * Filter rewards by cost range
 * @param rewards - Array of rewards
 * @param minCost - Minimum cost (inclusive)
 * @param maxCost - Maximum cost (inclusive)
 * @returns Filtered array
 */
export function filterRewardsByCost<T extends { cost: number }>(
  rewards: T[],
  minCost?: number,
  maxCost?: number
): T[] {
  return rewards.filter((reward) => {
    if (minCost !== undefined && reward.cost < minCost) return false
    if (maxCost !== undefined && reward.cost > maxCost) return false
    return true
  })
}
