import 'package:flutter/material.dart';

/// Color scheme for DulceHora pastry shop app
/// Inspired by pastry colors: warm pinks, browns, creams, and sweet tones
class AppColors {
  // Primary Colors - Warm pastry tones
  static const Color primary = Color(
    0xFFE91E63,
  ); // Sweet pink (like strawberry frosting)
  static const Color primaryLight = Color(0xFFF8BBD0); // Light pink
  static const Color primaryDark = Color(0xFFC2185B); // Deep pink

  // Secondary Colors - Chocolate and caramel tones
  static const Color secondary = Color(0xFF8D6E63); // Chocolate brown
  static const Color secondaryLight = Color(0xFFBCAAA4); // Light brown
  static const Color secondaryDark = Color(0xFF5D4037); // Dark chocolate

  // Accent Colors
  static const Color accent = Color(0xFFFFB74D); // Golden caramel
  static const Color accentLight = Color(0xFFFFE0B2); // Light caramel

  // Background Colors
  static const Color background = Color(0xFFFFFBF5); // Cream/vanilla
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFFFF3E0); // Light cream

  // Text Colors
  static const Color textPrimary = Color(
    0xFF3E2723,
  ); // Dark brown (like dark chocolate)
  static const Color textSecondary = Color(0xFF6D4C41); // Medium brown
  static const Color textHint = Color(0xFF9E9E9E); // Gray
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White text on primary color

  // Status Colors
  static const Color success = Color(0xFF66BB6A); // Green for completed orders
  static const Color warning = Color(0xFFFFA726); // Orange for pending
  static const Color error = Color(0xFFEF5350); // Red for errors/cancelled
  static const Color info = Color(0xFF42A5F5); // Blue for information

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
