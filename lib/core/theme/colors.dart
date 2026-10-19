import 'package:flutter/material.dart';

/// AgriLink Color Palette — Earth-Tones Agricultural (Bold Approach)
/// A modern, premium agricultural technology design inspired by
/// fertile soil, green crops, Ethiopian coffee culture, and golden harvests.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // EXACT PALETTE: EARTH-TONES AGRICULTURAL (BOLD APPROACH)
  // ============================================================================

  // Primary — Rich Earth Green
  static const Color primary = Color(0xFF3A7D44);
  static const Color primaryDark = Color(0xFF2B5E34);
  static const Color primaryLight = Color(0xFF5C9B65);
  static const Color primaryVeryLight = Color(0xFFE8F0E9);

  // Secondary — Ethiopian Coffee Brown
  static const Color secondary = Color(0xFF8B5A3C);
  static const Color secondaryLight = Color(0xFFA67C52);

  // Tertiary — Sky Blue
  static const Color tertiary = Color(0xFF4A90E2);

  // Accent — Golden Harvest
  static const Color accent = Color(0xFFD4AF37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color amber = Color(0xFFE09F3E);
  static const Color goldLight = Color(0xFFFBF4DD);

  // Background — Natural Cream & Warm White Surface
  static const Color background = Color(0xFFF5F1E8);
  static const Color surface = Color(0xFFFFFBF5);
  static const Color surfaceLight = Color(0xFFFAF6EE);
  static const Color border = Color(0xFFDDD6C9);
  static const Color disabled = Color(0xFFC4BCB0);

  // Success — Fresh Growth
  static const Color success = Color(0xFF7CB342);

  // ============================================================================
  // SEMANTIC COLORS - Status & Feedback
  // ============================================================================
  static const Color warning = Color(0xFFE07A24);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF4A90E2); // Sky Blue

  // ============================================================================
  // TEXT COLORS - High Contrast for Accessibility (Deep Earth & Warm Neutrals)
  // ============================================================================
  static const Color textPrimary = Color(0xFF2C241E);
  static const Color textSecondary = Color(0xFF6B6258);
  static const Color textTertiary = Color(0xFF948A7E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================================================
  // ROLE-SPECIFIC COLORS
  // ============================================================================
  static const Color roleFarmer = Color(0xFF3A7D44); // Primary Earth Green
  static const Color roleBuyer = Color(0xFF8B5A3C); // Coffee Brown
  static const Color roleTransporter = Color(0xFFD4AF37); // Golden Harvest
  static const Color roleBureau = Color(0xFF4A90E2); // Sky Blue

  // ============================================================================
  // GRADIENT DEFINITIONS
  // ============================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5C048), accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // OPACITY VARIANTS
  // ============================================================================
  static const Color shadow12 = Color(0x1A2C241E);
  static const Color overlay8 = Color(0x142C241E);
  static const Color shimmer50 = Color(0x80FFFBF5);

  // ============================================================================
  // COMMODITY-SPECIFIC COLORS (Agricultural price indicators)
  // ============================================================================
  static const Color commodityCoffee = Color(0xFF8B5A3C);
  static const Color commodityMaize = Color(0xFFD4AF37);
  static const Color commodityTeff = Color(0xFFA67C52);
  static const Color commodityWheat = Color(0xFFE5B84B);
  static const Color commodityPotato = Color(0xFF93684B);

  // ============================================================================
  // CHART & GRAPH COLORS (Cohesive Earth-Tones)
  // ============================================================================
  static const List<Color> chartColors = [
    Color(0xFF3A7D44), // Primary Green
    Color(0xFF8B5A3C), // Coffee Brown
    Color(0xFF4A90E2), // Sky Blue
    Color(0xFFD4AF37), // Golden Harvest
    Color(0xFF7CB342), // Fresh Growth
    Color(0xFFA67C52), // Light Coffee
  ];
}
