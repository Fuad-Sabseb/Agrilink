import 'package:agrolink/constants/app_colors.dart';
import 'package:agrolink/core/widgets/agri_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgriButton Widget Tests', () {
    testWidgets('AgriButton renders with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('AgriButton.primary creates primary button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.primary(
              text: 'Primary Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('AgriButton.secondary creates secondary button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.secondary(
              text: 'Secondary Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('AgriButton.text creates text button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.text(
              text: 'Text Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('AgriButton shows CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('AgriButton displays icon when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Icon Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Icon Button'), findsOneWidget);
    });

    testWidgets('AgriButton is disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('AgriButton is disabled when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('AgriButton calls onPressed when tapped',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Tap Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AgriButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('AgriButton has minimum touch target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Check the button style has minimum size constraints
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final minimumSize = button.style?.minimumSize?.resolve({});
      expect(minimumSize?.width, equals(48.0));
      expect(minimumSize?.height, equals(48.0));
    });

    testWidgets('AgriButton applies custom color when provided',
        (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Custom Color Button',
              customColor: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      final backgroundColor =
          buttonStyle?.backgroundColor?.resolve({WidgetState.pressed});

      expect(backgroundColor, equals(customColor));
    });

    testWidgets('AgriButton uses AppColors.primary by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Default Color Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style;
      final backgroundColor =
          buttonStyle?.backgroundColor?.resolve({WidgetState.pressed});

      expect(backgroundColor, equals(AppColors.primary));
    });

    testWidgets('AgriButton has proper semantic label for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Accessible Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify the button is wrapped in Semantics widget
      expect(find.byType(Semantics), findsWidgets);
      
      // Verify that a button exists with the correct text
      expect(find.text('Accessible Button'), findsOneWidget);
    });

    testWidgets('Primary button has correct border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.primary(
              text: 'Primary Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final shape = button.style?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      final roundedShape = shape as RoundedRectangleBorder;
      expect(roundedShape.borderRadius, equals(BorderRadius.circular(12.0)));
    });

    testWidgets('Secondary button has border outline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.secondary(
              text: 'Secondary Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final borderSide = button.style?.side?.resolve({});
      expect(borderSide?.width, equals(1.5));
    });

    testWidgets('Text button has no background or border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton.text(
              text: 'Text Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Loading state does not allow button interaction',
        (WidgetTester tester) async {
      int pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AgriButton));
      await tester.pump();

      expect(pressCount, equals(0));
    });

    testWidgets('Button with icon and loading shows only progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgriButton(
              text: 'Icon Loading Button',
              icon: Icons.add,
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.text('Icon Loading Button'), findsNothing);
    });
  });
}
