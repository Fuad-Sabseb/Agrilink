import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/widgets/action_card.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/theme/tokens.dart';

void main() {
  group('ActionCard Widget Tests', () {
    testWidgets('renders with required properties', (WidgetTester tester) async {
      // Track if onTap was called
      bool wasTapped = false;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Test Action',
              description: 'This is a test description',
              icon: Icons.add,
              primaryColor: AppColors.primary,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Test Action'), findsOneWidget);

      // Verify description is displayed
      expect(find.text('This is a test description'), findsOneWidget);

      // Verify icon is displayed
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the card
      await tester.tap(find.byType(ActionCard));
      await tester.pump();

      // Verify onTap was called
      expect(wasTapped, true);
    });

    testWidgets('renders in highlight mode with elevated styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Hero Action',
              description: 'This is a highlighted action',
              icon: Icons.analytics_outlined,
              primaryColor: AppColors.primary,
              isHighlight: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Hero Action'), findsOneWidget);

      // Verify "Learn more" text is displayed for highlighted cards
      expect(find.text('Learn more'), findsOneWidget);

      // Verify arrow icon for highlighted cards
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      // Verify the main icon is displayed
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('does not show "Learn more" in standard mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Standard Action',
              description: 'This is a standard action',
              icon: Icons.add,
              primaryColor: AppColors.primary,
              isHighlight: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify "Learn more" is NOT displayed for standard cards
      expect(find.text('Learn more'), findsNothing);

      // Verify arrow icon is NOT displayed for standard cards
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('applies correct primary color to icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Colored Action',
              description: 'This action has a custom color',
              icon: Icons.work_outline,
              primaryColor: AppColors.roleTransporter,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the Icon widget
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.work_outline));

      // Verify the icon color matches the primary color
      expect(iconWidget.color, AppColors.roleTransporter);
    });

    testWidgets('has minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Touch Target Test',
              description: 'Testing minimum touch target',
              icon: Icons.touch_app,
              primaryColor: AppColors.primary,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the ConstrainedBox - there may be multiple, find the one with our constraints
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      
      // Look for the ConstrainedBox with minHeight constraint
      final targetBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.minHeight == AppTokens.minTouchTarget,
        orElse: () => throw Exception('ConstrainedBox with minTouchTarget not found'),
      );

      // Verify minimum height constraint
      expect(
        targetBox.constraints.minHeight,
        AppTokens.minTouchTarget,
      );
    });

    testWidgets('is accessible and interactive',
        (WidgetTester tester) async {
      bool wasTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Accessible Action',
              description: 'Accessibility test',
              icon: Icons.accessibility,
              primaryColor: AppColors.primary,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Verify the content is accessible
      expect(find.text('Accessible Action'), findsOneWidget);
      expect(find.text('Accessibility test'), findsOneWidget);
      
      // Verify it's interactive
      await tester.tap(find.byType(ActionCard));
      await tester.pump();
      
      expect(wasTapped, true);
    });

    testWidgets('highlighted card renders with elevated styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Featured Action',
              description: 'This is featured',
              icon: Icons.star,
              primaryColor: AppColors.primary,
              isHighlight: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the card renders correctly
      expect(find.text('Featured Action'), findsOneWidget);
      expect(find.text('This is featured'), findsOneWidget);
      
      // Verify "Learn more" indicator appears for highlighted cards
      expect(find.text('Learn more'), findsOneWidget);
      
      // Find the Card widget and verify it has elevation
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, AppTokens.elevationL);
    });
  });
}
