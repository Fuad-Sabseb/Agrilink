import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/theme/contrast_checker.dart';

void main() {
  group('ContrastChecker', () {
    test('Black on white meets normal text AA', () {
      expect(
        ContrastChecker.meetsNormalTextAA(Colors.black, Colors.white),
        isTrue,
      );
    });

    test('Black on white has 21:1 ratio', () {
      final ratio = ContrastChecker.contrastRatio(Colors.black, Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('White on white fails contrast', () {
      expect(
        ContrastChecker.meetsNormalTextAA(Colors.white, Colors.white),
        isFalse,
      );
    });

    test('Get accessible foreground returns correct color', () {
      expect(
        ContrastChecker.getAccessibleForeground(Colors.white),
        Colors.black,
      );
      expect(
        ContrastChecker.getAccessibleForeground(Colors.black),
        Colors.white,
      );
    });
  });
}
