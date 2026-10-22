import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/widgets/role_badge.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/theme/tokens.dart';

void main() {
  group('RoleBadge Widget Tests', () {
    testWidgets('renders with farmer role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'farmer'),
          ),
        ),
      );

      expect(find.text('Farmer'), findsOneWidget);
    });

    testWidgets('renders with buyer role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'buyer'),
          ),
        ),
      );

      expect(find.text('Buyer'), findsOneWidget);
    });

    testWidgets('renders with transporter role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'transporter'),
          ),
        ),
      );

      expect(find.text('Transporter'), findsOneWidget);
    });

    testWidgets('renders with bureau role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'bureau'),
          ),
        ),
      );

      expect(find.text('Bureau Officer'), findsOneWidget);
    });

    testWidgets('formats bureau officer role correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'bureau officer'),
          ),
        ),
      );

      expect(find.text('Bureau Officer'), findsOneWidget);
    });

    testWidgets('applies correct background color for farmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'farmer'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.roleFarmer);
    });

    testWidgets('applies correct background color for buyer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'buyer'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.roleBuyer);
    });

    testWidgets('applies correct background color for transporter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'transporter'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.roleTransporter);
    });

    testWidgets('applies correct background color for bureau', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'bureau'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.roleBureau);
    });

    testWidgets('applies rounded corners with small border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'farmer'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, AppTokens.radiusS);
    });

    testWidgets('uses white text for farmer role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'farmer'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Farmer'));
      expect(text.style?.color, AppColors.textOnPrimary);
    });

    testWidgets('uses dark text for transporter role (accessibility)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'transporter'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Transporter'));
      expect(text.style?.color, AppColors.textPrimary);
    });

    testWidgets('uses white text for buyer role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'buyer'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Buyer'));
      expect(text.style?.color, AppColors.textOnPrimary);
    });

    testWidgets('uses white text for bureau role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'bureau'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Bureau Officer'));
      expect(text.style?.color, AppColors.textOnPrimary);
    });

    testWidgets('applies default padding when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'farmer'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final padding = container.padding as EdgeInsets;
      expect(padding.horizontal, AppTokens.spaceS * 2); // symmetric = doubled
      expect(padding.vertical, AppTokens.spaceXS * 2);
    });

    testWidgets('applies custom padding when specified', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(
              role: 'farmer',
              padding: customPadding,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, customPadding);
    });

    testWidgets('handles uppercase role input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'FARMER'),
          ),
        ),
      );

      expect(find.text('Farmer'), findsOneWidget);
    });

    testWidgets('handles mixed case role input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: 'FaRmEr'),
          ),
        ),
      );

      expect(find.text('Farmer'), findsOneWidget);
    });

    testWidgets('handles role with extra whitespace', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleBadge(role: '  farmer  '),
          ),
        ),
      );

      expect(find.text('Farmer'), findsOneWidget);
    });
  });
}
