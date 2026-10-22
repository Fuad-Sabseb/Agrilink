import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/widgets/statistic_card.dart';
import 'package:agrolink/core/theme/colors.dart';

void main() {
  group('StatisticCard Widget Tests', () {
    testWidgets('renders with required properties', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Active Listings',
              value: '12',
              icon: Icons.list,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Active Listings'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('displays positive trend indicator correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Revenue',
              value: '1,250 ETB',
              icon: Icons.attach_money,
              trend: '+15%',
              trendPositive: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('1,250 ETB'), findsOneWidget);
      expect(find.text('+15%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays negative trend indicator correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Pending Orders',
              value: '3',
              icon: Icons.pending,
              trend: '-2',
              trendPositive: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pending Orders'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('-2'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('applies custom color when provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Completed Jobs',
              value: '45',
              icon: Icons.check_circle,
              color: AppColors.secondary,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Completed Jobs'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      
      // Verify the icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, AppColors.secondary);
    });

    testWidgets('does not display trend when not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Total Farms',
              value: '8',
              icon: Icons.agriculture,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Total Farms'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('uses default primary color when color not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Test Label',
              value: '100',
              icon: Icons.star,
            ),
          ),
        ),
      );

      // Assert - verify icon uses default color
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('icon container has minimum touch target size', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Test',
              value: '1',
              icon: Icons.star,
            ),
          ),
        ),
      );

      // Assert - verify icon container meets minimum size requirement
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.star),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.constraints?.minWidth, 48.0);
      expect(container.constraints?.minHeight, 48.0);
    });

    testWidgets('card has consistent border radius', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Test',
              value: '1',
              icon: Icons.star,
            ),
          ),
        ),
      );

      // Assert - verify card has proper border radius
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });
  });
}
