import 'package:flutter/material.dart';

/// App-wide color palette for TaskFlow mobile app
/// Supports both light and dark themes with Material Design 3
class AppColors {
  AppColors._();

  // Primary Colors (Task management theme - Blue-based)
  static const Color primaryLight = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2); // Darker Blue
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001D36);

  // Secondary Colors (Gamification theme - Purple-based)
  static const Color secondaryLight = Color(0xFF9C27B0); // Purple
  static const Color secondaryDark = Color(0xFF7B1FA2); // Darker Purple
  static const Color secondaryContainer = Color(0xFFE1BEE7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF2E004E);

  // Tertiary Colors (Rewards theme - Amber-based)
  static const Color tertiaryLight = Color(0xFFFFC107); // Amber
  static const Color tertiaryDark = Color(0xFFFFA000); // Darker Amber
  static const Color tertiaryContainer = Color(0xFFFFECB3);
  static const Color onTertiary = Color(0xFF000000);
  static const Color onTertiaryContainer = Color(0xFF261900);

  // Error Colors
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFB71C1C);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Success Colors (Task completion)
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF00210B);

  // Warning Colors (Deadlines approaching)
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarning = Color(0xFF000000);
  static const Color onWarningContainer = Color(0xFF2A1800);

  // Background Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // Outline Colors
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantLight = Color(0xFFCAC4D0);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // Surface Tint
  static const Color surfaceTintLight = primaryLight;
  static const Color surfaceTintDark = primaryDark;

  // Task Priority Colors
  static const Color priorityLow = Color(0xFF64B5F6); // Light Blue
  static const Color priorityMedium = Color(0xFFFFB74D); // Orange
  static const Color priorityHigh = Color(0xFFFF7043); // Deep Orange
  static const Color priorityCritical = Color(0xFFE53935); // Red

  // Task Status Colors
  static const Color statusCreated = Color(0xFF90CAF9); // Light Blue
  static const Color statusAssigned = Color(0xFF64B5F6); // Blue
  static const Color statusInProgress = Color(0xFFFFA726); // Orange
  static const Color statusAwaitingApproval = Color(0xFFAB47BC); // Purple
  static const Color statusCompleted = Color(0xFF66BB6A); // Green
  static const Color statusRejected = Color(0xFFEF5350); // Red
  static const Color statusOverdue = Color(0xFFD32F2F); // Dark Red

  // Point/Reward Colors
  static const Color pointsGold = Color(0xFFFFD700); // Gold
  static const Color pointsSilver = Color(0xFFC0C0C0); // Silver
  static const Color pointsBronze = Color(0xFFCD7F32); // Bronze

  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // Divider Colors
  static const Color dividerLight = Color(0x1F000000);
  static const Color dividerDark = Color(0x1FFFFFFF);
}
