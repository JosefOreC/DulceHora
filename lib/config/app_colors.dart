import 'package:flutter/material.dart';

/// Color scheme for DulceHora pastry shop app
/// Inspired by pastry colors: warm pinks, browns, creams, and sweet tones
class AppColors {
  // Primary Colors - Yellow/Orange theme
  static const Color primary = Color(0xFFFFA726); // Orange
  static const Color primaryLight = Color(0xFFFFD54F); // Light Yellow
  static const Color primaryDark = Color(0xFFF57C00); // Dark Orange

  // Secondary Colors - Black tones
  static const Color secondary = Color(0xFF212121); // Black
  static const Color secondaryLight = Color(0xFF424242); // Dark gray
  static const Color secondaryDark = Color(0xFF000000); // Pure black

  // Accent Colors
  static const Color accent = Color(0xFFFFEB3B); // Bright Yellow
  static const Color accentLight = Color(0xFFFFF59D); // Very light yellow

  // Background Colors
  static const Color background = Color(0xFFFFFBF5); // Warm white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFFFF8E1); // Very light yellow

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Almost black
  static const Color textSecondary = Color(0xFF757575); // Gray
  static const Color textHint = Color(0xFF9E9E9E); // Light gray
  static const Color textOnPrimary = Color(0xFF212121); // Black on orange

  // Status Colors
  static const Color success = Color(0xFF66BB6A); // Green for completed orders
  static const Color warning = Color(0xFFFF9800); // Orange for pending
  static const Color error = Color(0xFFEF5350); // Red for errors/cancelled
  static const Color info = Color(0xFFFFB74D); // Light orange for information

  // Special Colors
  static const Color divider = Color(0xFFE0E0E0); // Light gray divider
  static const Color shadow = Color(0x1A000000); // Subtle shadow
  static const Color overlay = Color(0x80000000); // Semi-transparent overlay

  // Gradient Colors for premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Order Status Colors
  static const Color statusPending = Color(0xFFFFA726); // Orange
  static const Color statusInProduction = Color(0xFF42A5F5); // Blue
  static const Color statusReady = Color(0xFF66BB6A); // Green
  static const Color statusDelivered = Color(0xFF9C27B0); // Purple
  static const Color statusCancelled = Color(0xFFEF5350); // Red

  // Occasion Colors (for product recommendations)
  static const Color occasionBirthday = Color(0xFFFF4081); // Bright pink
  static const Color occasionWedding = Color(0xFFFFFFFF); // White/elegant
  static const Color occasionAnniversary = Color(0xFFE91E63); // Romantic pink
  static const Color occasionGraduation = Color(0xFF2196F3); // Blue
  static const Color occasionBabyShower = Color(0xFF81C784); // Soft green
  static const Color occasionCorporate = Color(
    0xFF607D8B,
  ); // Professional gray-blue
}
