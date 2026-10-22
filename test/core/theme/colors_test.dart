import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/theme/colors.dart';

void main() {
  group('AppColors Role Helper Methods', () {
    group('getRoleColor', () {
      test('returns correct color for farmer role', () {
        expect(AppColors.getRoleColor('farmer'), equals(AppColors.roleFarmer));
        expect(AppColors.getRoleColor('Farmer'), equals(AppColors.roleFarmer));
        expect(AppColors.getRoleColor('FARMER'), equals(AppColors.roleFarmer));
      });

      test('returns correct color for buyer role', () {
        expect(AppColors.getRoleColor('buyer'), equals(AppColors.roleBuyer));
        expect(AppColors.getRoleColor('Buyer'), equals(AppColors.roleBuyer));
        expect(AppColors.getRoleColor('BUYER'), equals(AppColors.roleBuyer));
      });

      test('returns correct color for transporter role', () {
        expect(AppColors.getRoleColor('transporter'), equals(AppColors.roleTransporter));
        expect(AppColors.getRoleColor('Transporter'), equals(AppColors.roleTransporter));
        expect(AppColors.getRoleColor('TRANSPORTER'), equals(AppColors.roleTransporter));
      });

      test('returns correct color for bureau role', () {
        expect(AppColors.getRoleColor('bureau'), equals(AppColors.roleBureau));
        expect(AppColors.getRoleColor('Bureau'), equals(AppColors.roleBureau));
        expect(AppColors.getRoleColor('bureau officer'), equals(AppColors.roleBureau));
        expect(AppColors.getRoleColor('Bureau Officer'), equals(AppColors.roleBureau));
      });

      test('returns primary color as fallback for unknown role', () {
        expect(AppColors.getRoleColor('unknown'), equals(AppColors.primary));
        expect(AppColors.getRoleColor(''), equals(AppColors.primary));
        expect(AppColors.getRoleColor('invalid_role'), equals(AppColors.primary));
      });
    });

    group('getRoleColorLight', () {
      test('returns correct light color for farmer role', () {
        expect(AppColors.getRoleColorLight('farmer'), equals(AppColors.primaryLight));
        expect(AppColors.getRoleColorLight('Farmer'), equals(AppColors.primaryLight));
        expect(AppColors.getRoleColorLight('FARMER'), equals(AppColors.primaryLight));
      });

      test('returns correct light color for buyer role', () {
        expect(AppColors.getRoleColorLight('buyer'), equals(AppColors.secondaryLight));
        expect(AppColors.getRoleColorLight('Buyer'), equals(AppColors.secondaryLight));
        expect(AppColors.getRoleColorLight('BUYER'), equals(AppColors.secondaryLight));
      });

      test('returns correct light color for transporter role', () {
        expect(AppColors.getRoleColorLight('transporter'), equals(AppColors.goldLight));
        expect(AppColors.getRoleColorLight('Transporter'), equals(AppColors.goldLight));
        expect(AppColors.getRoleColorLight('TRANSPORTER'), equals(AppColors.goldLight));
      });

      test('returns correct light color for bureau role', () {
        expect(AppColors.getRoleColorLight('bureau'), equals(AppColors.primaryVeryLight));
        expect(AppColors.getRoleColorLight('Bureau'), equals(AppColors.primaryVeryLight));
        expect(AppColors.getRoleColorLight('bureau officer'), equals(AppColors.primaryVeryLight));
        expect(AppColors.getRoleColorLight('Bureau Officer'), equals(AppColors.primaryVeryLight));
      });

      test('returns primaryLight color as fallback for unknown role', () {
        expect(AppColors.getRoleColorLight('unknown'), equals(AppColors.primaryLight));
        expect(AppColors.getRoleColorLight(''), equals(AppColors.primaryLight));
        expect(AppColors.getRoleColorLight('invalid_role'), equals(AppColors.primaryLight));
      });
    });

    group('Role Color Mappings', () {
      test('farmer role maps to #3A7D44', () {
        expect(AppColors.getRoleColor('farmer'), equals(const Color(0xFF3A7D44)));
      });

      test('buyer role maps to #8B5A3C', () {
        expect(AppColors.getRoleColor('buyer'), equals(const Color(0xFF8B5A3C)));
      });

      test('transporter role maps to #D4AF37', () {
        expect(AppColors.getRoleColor('transporter'), equals(const Color(0xFFD4AF37)));
      });

      test('bureau role maps to #4A90E2', () {
        expect(AppColors.getRoleColor('bureau'), equals(const Color(0xFF4A90E2)));
      });
    });
  });
}
