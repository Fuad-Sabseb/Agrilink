import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/theme/colors.dart';

void main() {
  group('Task 8.1: AppTheme.lightTheme ColorScheme Configuration', () {
    test('Primary color should be Rich Earth Green (#3A7D44)', () {
      expect(AppColors.primary, const Color(0xFF3A7D44));
    });

    test('Secondary color should be Ethiopian Coffee Brown (#8B5A3C)', () {
      expect(AppColors.secondary, const Color(0xFF8B5A3C));
    });

    test('Tertiary color should be Sky Blue (#4A90E2)', () {
      expect(AppColors.tertiary, const Color(0xFF4A90E2));
    });

    test('Background should be Natural Cream (#F5F1E8)', () {
      expect(AppColors.background, const Color(0xFFF5F1E8));
    });

    test('Surface should be warm white (#FFFBF5)', () {
      expect(AppColors.surface, const Color(0xFFFFFBF5));
    });

    test('Primary container colors are configured', () {
      expect(AppColors.primaryVeryLight, const Color(0xFFE8F0E9));
      expect(AppColors.primaryDark, const Color(0xFF2B5E34));
    });

    test('Secondary container colors are configured', () {
      expect(AppColors.secondaryVeryLight, const Color(0xFFF3ECE4));
      expect(AppColors.secondaryDark, const Color(0xFF6B4429));
    });

    test('Tertiary container colors are configured', () {
      expect(AppColors.tertiaryVeryLight, const Color(0xFFE8F2FC));
      expect(AppColors.tertiaryDark, const Color(0xFF1E3A5F));
    });

    test('Error colors are configured', () {
      expect(AppColors.error, const Color(0xFFC0392B));
      expect(AppColors.errorDark, const Color(0xFF8B2618));
    });

    test('Text colors are configured', () {
      expect(AppColors.textPrimary, const Color(0xFF2C241E));
      expect(AppColors.textSecondary, const Color(0xFF6B6258));
      expect(AppColors.textOnPrimary, const Color(0xFFFFFFFF));
    });

    test('Surface and border colors are configured', () {
      expect(AppColors.surfaceLight, const Color(0xFFFAF6EE));
      expect(AppColors.border, const Color(0xFFDDD6C9));
    });
  });

  group('AppColors verification', () {
    test('Primary (Rich Earth Green) should be #3A7D44', () {
      expect(AppColors.primary, const Color(0xFF3A7D44));
    });

    test('Secondary (Ethiopian Coffee Brown) should be #8B5A3C', () {
      expect(AppColors.secondary, const Color(0xFF8B5A3C));
    });

    test('Tertiary (Sky Blue) should be #4A90E2', () {
      expect(AppColors.tertiary, const Color(0xFF4A90E2));
    });

    test('Background (Natural Cream) should be #F5F1E8', () {
      expect(AppColors.background, const Color(0xFFF5F1E8));
    });

    test('Surface (Warm White) should be #FFFBF5', () {
      expect(AppColors.surface, const Color(0xFFFFFBF5));
    });
  });
}
