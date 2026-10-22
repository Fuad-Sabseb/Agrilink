import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/theme/typography.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for AppTypography system
/// Validates:
/// - Noto Sans font family is used across all text styles
/// - Afaan Oromoo and Amharic character support
/// - Proper fallback behavior
void main() {
  group('AppTypography Font Family Tests', () {
    test('Base text style uses GoogleFonts.notoSans', () {
      // Access a public style to verify the base configuration
      final style = AppTypography.bodyLarge;
      
      // GoogleFonts.notoSans returns a TextStyle with specific font family
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      
      expect(style.fontFamily, expectedFont);
    });

    test('All display styles use Noto Sans font family', () {
      final displayStyles = [
        AppTypography.displayLarge,
        AppTypography.displayMedium,
        AppTypography.displaySmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in displayStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Display style should use Noto Sans font family',
        );
      }
    });

    test('All headline styles use Noto Sans font family', () {
      final headlineStyles = [
        AppTypography.headlineLarge,
        AppTypography.headlineMedium,
        AppTypography.headlineSmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in headlineStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Headline style should use Noto Sans font family',
        );
      }
    });

    test('All title styles use Noto Sans font family', () {
      final titleStyles = [
        AppTypography.titleLarge,
        AppTypography.titleMedium,
        AppTypography.titleSmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in titleStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Title style should use Noto Sans font family',
        );
      }
    });

    test('All body styles use Noto Sans font family', () {
      final bodyStyles = [
        AppTypography.bodyLarge,
        AppTypography.bodyMedium,
        AppTypography.bodySmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in bodyStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Body style should use Noto Sans font family',
        );
      }
    });

    test('All label styles use Noto Sans font family', () {
      final labelStyles = [
        AppTypography.labelLarge,
        AppTypography.labelMedium,
        AppTypography.labelSmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in labelStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Label style should use Noto Sans font family',
        );
      }
    });

    test('Specialized styles use Noto Sans font family', () {
      final specializedStyles = [
        AppTypography.caption,
        AppTypography.overline,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in specializedStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Specialized style should use Noto Sans font family',
        );
      }
    });

    test('Numeric styles use Noto Sans font family', () {
      final numericStyles = [
        AppTypography.priceLarge,
        AppTypography.priceMedium,
        AppTypography.priceSmall,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in numericStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Numeric style should use Noto Sans font family',
        );
      }
    });

    test('Button styles use Noto Sans font family', () {
      final buttonStyles = [
        AppTypography.buttonPrimary,
        AppTypography.buttonSecondary,
        AppTypography.buttonText,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in buttonStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Button style should use Noto Sans font family',
        );
      }
    });

    test('Navigation styles use Noto Sans font family', () {
      final navStyles = [
        AppTypography.navLabel,
        AppTypography.appBarTitle,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in navStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Navigation style should use Noto Sans font family',
        );
      }
    });

    test('Form field styles use Noto Sans font family', () {
      final formStyles = [
        AppTypography.inputText,
        AppTypography.inputLabel,
        AppTypography.inputHint,
        AppTypography.inputError,
      ];

      final expectedFont = GoogleFonts.notoSans().fontFamily;

      for (final style in formStyles) {
        expect(
          style.fontFamily,
          expectedFont,
          reason: 'Form field style should use Noto Sans font family',
        );
      }
    });

    test('Role badge style uses Noto Sans font family', () {
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      
      expect(
        AppTypography.roleBadge.fontFamily,
        expectedFont,
        reason: 'Role badge style should use Noto Sans font family',
      );
    });
  });

  group('Afaan Oromoo Character Support Tests', () {
    testWidgets('Text widget renders Afaan Oromoo characters correctly',
        (WidgetTester tester) async {
      // Common Afaan Oromoo characters including extended Latin
      const afaanOromooText = 'Buna, Qamadii, Raammuu, Dhiheenyaa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              afaanOromooText,
              style: AppTypography.bodyLarge,
            ),
          ),
        ),
      );

      // Verify the text is rendered
      expect(find.text(afaanOromooText), findsOneWidget);
      
      // Verify the style is applied
      final textWidget = tester.widget<Text>(find.text(afaanOromooText));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });

    testWidgets('Text widget renders Afaan Oromoo with diacritics',
        (WidgetTester tester) async {
      // Afaan Oromoo uses extended Latin with various diacritics
      const textWithDiacritics = 'Galata, Dhugaa, Akkamitti';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              textWithDiacritics,
              style: AppTypography.headlineMedium,
            ),
          ),
        ),
      );

      expect(find.text(textWithDiacritics), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text(textWithDiacritics));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });
  });

  group('Amharic Character Support Tests', () {
    testWidgets('Text widget renders Amharic script correctly',
        (WidgetTester tester) async {
      // Common Amharic text (Ethiopic script)
      const amharicText = 'ገበያ፣ አርሶ አደር፣ ዋጋ፣ እርሻ';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              amharicText,
              style: AppTypography.bodyLarge,
            ),
          ),
        ),
      );

      // Verify the text is rendered
      expect(find.text(amharicText), findsOneWidget);
      
      // Verify the style is applied
      final textWidget = tester.widget<Text>(find.text(amharicText));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });

    testWidgets('Text widget renders complex Amharic phrases',
        (WidgetTester tester) async {
      // More complex Amharic text with various Ethiopic characters
      const complexAmharic = 'እንኳን ደህና መጣህ። የገበያ ዋጋ ምንድነው?';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              complexAmharic,
              style: AppTypography.titleLarge,
            ),
          ),
        ),
      );

      expect(find.text(complexAmharic), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text(complexAmharic));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });
  });

  group('Mixed Language Support Tests', () {
    testWidgets('Text widget renders mixed English and Amharic',
        (WidgetTester tester) async {
      const mixedText = 'Market ገበያ Price ዋጋ';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              mixedText,
              style: AppTypography.bodyMedium,
            ),
          ),
        ),
      );

      expect(find.text(mixedText), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text(mixedText));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });

    testWidgets('Text widget renders mixed English and Afaan Oromoo',
        (WidgetTester tester) async {
      const mixedText = 'Price Gatii Market Gabaa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              mixedText,
              style: AppTypography.bodyMedium,
            ),
          ),
        ),
      );

      expect(find.text(mixedText), findsOneWidget);
      
      final textWidget = tester.widget<Text>(find.text(mixedText));
      final expectedFont = GoogleFonts.notoSans().fontFamily;
      expect(textWidget.style?.fontFamily, expectedFont);
    });
  });

  group('Fallback Behavior Tests', () {
    test('Utility methods maintain Noto Sans font family', () {
      final baseStyle = AppTypography.bodyLarge;
      final expectedFont = GoogleFonts.notoSans().fontFamily;

      // Test withColor maintains font family
      final coloredStyle = AppTypography.withColor(baseStyle, Colors.red);
      expect(coloredStyle.fontFamily, expectedFont);

      // Test withWeight maintains font family
      final weightedStyle = AppTypography.withWeight(baseStyle, FontWeight.w700);
      expect(weightedStyle.fontFamily, expectedFont);

      // Test withSize maintains font family
      final sizedStyle = AppTypography.withSize(baseStyle, 20);
      expect(sizedStyle.fontFamily, expectedFont);
    });

    testWidgets('Fallback fonts are available when needed',
        (WidgetTester tester) async {
      // Test with special characters that might need fallback
      const specialChars = '₹ € ¥ ₦ ℃ ® © ™';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              specialChars,
              style: AppTypography.bodyLarge,
            ),
          ),
        ),
      );

      // Should render without crashing (fallback fonts handle special chars)
      expect(find.text(specialChars), findsOneWidget);
    });

    test('All text styles have non-null font families', () {
      final allStyles = [
        AppTypography.displayLarge,
        AppTypography.displayMedium,
        AppTypography.displaySmall,
        AppTypography.headlineLarge,
        AppTypography.headlineMedium,
        AppTypography.headlineSmall,
        AppTypography.titleLarge,
        AppTypography.titleMedium,
        AppTypography.titleSmall,
        AppTypography.bodyLarge,
        AppTypography.bodyMedium,
        AppTypography.bodySmall,
        AppTypography.labelLarge,
        AppTypography.labelMedium,
        AppTypography.labelSmall,
        AppTypography.caption,
        AppTypography.overline,
        AppTypography.priceLarge,
        AppTypography.priceMedium,
        AppTypography.priceSmall,
        AppTypography.buttonPrimary,
        AppTypography.buttonSecondary,
        AppTypography.buttonText,
        AppTypography.navLabel,
        AppTypography.appBarTitle,
        AppTypography.roleBadge,
        AppTypography.inputText,
        AppTypography.inputLabel,
        AppTypography.inputHint,
        AppTypography.inputError,
      ];

      for (final style in allStyles) {
        expect(
          style.fontFamily,
          isNotNull,
          reason: 'Every text style should have a font family defined',
        );
      }
    });
  });

  group('Typography Configuration Validation', () {
    test('GoogleFonts package is correctly configured', () {
      // This test verifies that GoogleFonts.notoSans() returns a valid TextStyle
      final notoSansStyle = GoogleFonts.notoSans();
      
      expect(notoSansStyle, isNotNull);
      expect(notoSansStyle.fontFamily, isNotNull);
      expect(notoSansStyle.fontFamily, isNotEmpty);
    });

    test('Base text style has proper default properties', () {
      final style = AppTypography.bodyLarge;
      
      // Verify base properties are set
      expect(style.fontFamily, isNotNull);
      expect(style.fontSize, isNotNull);
      expect(style.fontWeight, isNotNull);
      expect(style.height, isNotNull);
    });

    test('All styles are properly instantiated', () {
      // Verify no style throws an error when accessed
      expect(() => AppTypography.displayLarge, returnsNormally);
      expect(() => AppTypography.displayMedium, returnsNormally);
      expect(() => AppTypography.displaySmall, returnsNormally);
      expect(() => AppTypography.headlineLarge, returnsNormally);
      expect(() => AppTypography.headlineMedium, returnsNormally);
      expect(() => AppTypography.headlineSmall, returnsNormally);
      expect(() => AppTypography.titleLarge, returnsNormally);
      expect(() => AppTypography.titleMedium, returnsNormally);
      expect(() => AppTypography.titleSmall, returnsNormally);
      expect(() => AppTypography.bodyLarge, returnsNormally);
      expect(() => AppTypography.bodyMedium, returnsNormally);
      expect(() => AppTypography.bodySmall, returnsNormally);
      expect(() => AppTypography.labelLarge, returnsNormally);
      expect(() => AppTypography.labelMedium, returnsNormally);
      expect(() => AppTypography.labelSmall, returnsNormally);
      expect(() => AppTypography.caption, returnsNormally);
      expect(() => AppTypography.overline, returnsNormally);
      expect(() => AppTypography.priceLarge, returnsNormally);
      expect(() => AppTypography.priceMedium, returnsNormally);
      expect(() => AppTypography.priceSmall, returnsNormally);
      expect(() => AppTypography.buttonPrimary, returnsNormally);
      expect(() => AppTypography.buttonSecondary, returnsNormally);
      expect(() => AppTypography.buttonText, returnsNormally);
      expect(() => AppTypography.navLabel, returnsNormally);
      expect(() => AppTypography.appBarTitle, returnsNormally);
      expect(() => AppTypography.roleBadge, returnsNormally);
      expect(() => AppTypography.inputText, returnsNormally);
      expect(() => AppTypography.inputLabel, returnsNormally);
      expect(() => AppTypography.inputHint, returnsNormally);
      expect(() => AppTypography.inputError, returnsNormally);
    });
  });
}
