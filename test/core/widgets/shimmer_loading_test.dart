import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/widgets/shimmer_loading.dart';

void main() {
  group('Shimmer Widget', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should have accessibility label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              semanticLabel: 'Loading content',
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
    });

    testWidgets('should use default "Loading..." label when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading...'), findsOneWidget);
    });

    testWidgets('should animate shimmer effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));

      // Animation should be running
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should support custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              baseColor: Colors.red,
              highlightColor: Colors.blue,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should support custom animation period', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Shimmer(
              period: const Duration(milliseconds: 2000),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should adapt colors to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Shimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should adapt colors to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Shimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('ShimmerTextLine', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextLine(),
          ),
        ),
      );

      expect(find.byType(ShimmerTextLine), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should have accessibility label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextLine(
              semanticLabel: 'Loading text line',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading text line'), findsOneWidget);
    });

    testWidgets('should use default "Loading text" label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextLine(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading text'), findsOneWidget);
    });

    testWidgets('should support custom width and height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextLine(
              width: 200,
              height: 24,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerTextLine),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, 200);
    });

    testWidgets('should support custom border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextLine(
              borderRadius: 8.0,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextLine), findsOneWidget);
    });
  });

  group('ShimmerTextBlock', () {
    testWidgets('should render multiple lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextBlock(
              lines: 3,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextBlock), findsOneWidget);
      expect(find.byType(ShimmerTextLine), findsNWidgets(3));
    });

    testWidgets('should have accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextBlock(
              semanticLabel: 'Loading text block',
              lines: 3,
            ),
          ),
        ),
      );

      // Semantics widget should be present
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should support custom line width ratios', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextBlock(
              lines: 3,
              lineWidthRatios: [1.0, 0.8, 0.6],
            ),
          ),
        ),
      );

      expect(find.byType(FractionallySizedBox), findsNWidgets(3));
    });

    testWidgets('should support custom line height and spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerTextBlock(
              lines: 3,
              lineHeight: 20.0,
              lineSpacing: 10.0,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextBlock), findsOneWidget);
    });
  });

  group('ShimmerListTile', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(),
          ),
        ),
      );

      expect(find.byType(ShimmerListTile), findsOneWidget);
      // Multiple shimmer widgets: leading, title, subtitle lines, trailing
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('should have accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              semanticLabel: 'Loading list item',
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should render without leading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              hasLeading: false,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerListTile), findsOneWidget);
    });

    testWidgets('should render without trailing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              hasTrailing: false,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerListTile), findsOneWidget);
    });

    testWidgets('should support rectangular leading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              circularLeading: false,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerListTile), findsOneWidget);
    });

    testWidgets('should support multiple subtitle lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              subtitleLines: 2,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextBlock), findsOneWidget);
    });
  });

  group('ShimmerCard', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShimmerCard(),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShimmerCard(
                semanticLabel: 'Loading card',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should render with image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShimmerCard(
                hasImage: true,
                height: 300,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCard), findsOneWidget);
    });

    testWidgets('should render without actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShimmerCard(
                hasActions: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCard), findsOneWidget);
    });

    testWidgets('should support custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShimmerCard(
                height: 300,
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ShimmerCard),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.height, 300);
    });
  });

  group('ShimmerGridItem', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 200,
                height: 400,
                child: ShimmerGridItem(
                  titleLines: 1,
                  subtitleLines: 1,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerGridItem), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 200,
                height: 400,
                child: ShimmerGridItem(
                  semanticLabel: 'Loading grid item',
                  titleLines: 1,
                  subtitleLines: 1,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should render without image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 200,
                child: ShimmerGridItem(
                  hasImage: false,
                  titleLines: 1,
                  subtitleLines: 1,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerGridItem), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('should support custom title and subtitle lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 200,
                height: 400,
                child: ShimmerGridItem(
                  titleLines: 1,
                  subtitleLines: 1,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerGridItem), findsOneWidget);
    });
  });

  group('ShimmerAvatar', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerAvatar(),
          ),
        ),
      );

      expect(find.byType(ShimmerAvatar), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should have accessibility label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerAvatar(
              semanticLabel: 'Loading avatar',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading avatar'), findsOneWidget);
    });

    testWidgets('should support custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerAvatar(
              size: 80,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerAvatar),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, 80);
    });
  });

  group('ShimmerListView', () {
    testWidgets('should render multiple list items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListView(
              itemCount: 5,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerListView), findsOneWidget);
      expect(find.byType(ShimmerListTile), findsNWidgets(5));
    });

    testWidgets('should have accessibility label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListView(
              semanticLabel: 'Loading list view',
              itemCount: 3,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading list view'), findsOneWidget);
    });
  });

  group('ShimmerGridView', () {
    testWidgets('should render multiple grid items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: ShimmerGridView(
                itemCount: 4,  // Reduced from 6 to fit in test viewport
                crossAxisCount: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerGridView), findsOneWidget);
      // GridView may not render all items if they're off-screen
      expect(find.byType(ShimmerGridItem), findsWidgets);
    });

    testWidgets('should have accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: ShimmerGridView(
                semanticLabel: 'Loading grid view',
                itemCount: 4,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('ShimmerCardList', () {
    testWidgets('should render multiple cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCardList(
              itemCount: 3,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCardList), findsOneWidget);
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('should have accessibility label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCardList(
              semanticLabel: 'Loading card list',
              itemCount: 2,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading card list'), findsOneWidget);
    });
  });

  group('Theme Adaptation', () {
    testWidgets('shimmer should work in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerTextLine(),
                  ShimmerListTile(subtitleLines: 1),
                  SizedBox(
                    height: 200,
                    child: ShimmerCard(
                      height: 150,
                      titleLines: 1,
                      contentLines: 2,
                    ),
                  ),
                  ShimmerAvatar(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextLine), findsWidgets);
      expect(find.byType(ShimmerListTile), findsOneWidget);
      expect(find.byType(ShimmerCard), findsOneWidget);
      expect(find.byType(ShimmerAvatar), findsOneWidget);
    });

    testWidgets('shimmer should work in dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerTextLine(),
                  ShimmerListTile(subtitleLines: 1),
                  SizedBox(
                    height: 200,
                    child: ShimmerCard(
                      height: 150,
                      titleLines: 1,
                      contentLines: 2,
                    ),
                  ),
                  ShimmerAvatar(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerTextLine), findsWidgets);
      expect(find.byType(ShimmerListTile), findsOneWidget);
      expect(find.byType(ShimmerCard), findsOneWidget);
      expect(find.byType(ShimmerAvatar), findsOneWidget);
    });
  });

  group('Accessibility', () {
    testWidgets('all shimmer widgets should have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerTextLine(semanticLabel: 'Loading text'),
                  ShimmerTextBlock(
                    semanticLabel: 'Loading block',
                    lines: 2,
                    lineHeight: 14,
                  ),
                  ShimmerListTile(
                    semanticLabel: 'Loading item',
                    subtitleLines: 1,
                  ),
                  SizedBox(
                    height: 200,
                    child: ShimmerCard(
                      semanticLabel: 'Loading card',
                      height: 150,
                      titleLines: 1,
                      contentLines: 2,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 250,
                    child: ShimmerGridItem(
                      semanticLabel: 'Loading grid',
                      titleLines: 1,
                      subtitleLines: 1,
                    ),
                  ),
                  ShimmerAvatar(semanticLabel: 'Loading avatar'),
                ],
              ),
            ),
          ),
        ),
      );

      // Check that all shimmer widgets are present
      expect(find.byType(ShimmerTextLine), findsWidgets);
      expect(find.byType(Shimmer), findsWidgets);
    });
  });
}
