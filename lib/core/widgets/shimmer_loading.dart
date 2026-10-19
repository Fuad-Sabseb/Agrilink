import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Shimmer Loading Widgets
/// Production-ready loading state widgets using shimmer effect
/// Supports light and dark themes with accessibility labels
///
/// **Validates: Requirements 14.1, 14.2, 14.3**

// ============================================================================
// SHIMMER ANIMATION WIDGET
// ============================================================================

/// Base shimmer effect widget
/// Animates a gradient across child widgets to create loading effect
class Shimmer extends StatefulWidget {
  /// The child widget to apply shimmer effect to
  final Widget child;

  /// Base color of the shimmer (lightest color)
  final Color? baseColor;

  /// Highlight color of the shimmer (color of the animated shine)
  final Color? highlightColor;

  /// Duration of one shimmer animation cycle
  final Duration period;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.semanticLabel,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final baseColor = widget.baseColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : AppColors.border);
    final highlightColor = widget.highlightColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHigh
            : AppColors.surfaceLight);

    return Semantics(
      label: widget.semanticLabel ?? 'Loading...',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: [
                  0.0,
                  _animation.value / 2 + 0.5,
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// ============================================================================
// PRE-BUILT SHIMMER WIDGETS
// ============================================================================

/// Shimmer loading for a single line of text
class ShimmerTextLine extends StatelessWidget {
  /// Width of the text line (null for full width)
  final double? width;

  /// Height of the text line
  final double height;

  /// Border radius
  final double borderRadius;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerTextLine({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius = 4.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      semanticLabel: semanticLabel ?? 'Loading text',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer loading for multiple lines of text
class ShimmerTextBlock extends StatelessWidget {
  /// Number of lines to display
  final int lines;

  /// Height of each line
  final double lineHeight;

  /// Spacing between lines
  final double lineSpacing;

  /// Width ratios for each line (null for full width)
  /// Example: [1.0, 0.8, 0.6] makes each line progressively shorter
  final List<double>? lineWidthRatios;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerTextBlock({
    super.key,
    this.lines = 3,
    this.lineHeight = 16.0,
    this.lineSpacing = 8.0,
    this.lineWidthRatios,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading text content',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          final widthRatio = lineWidthRatios != null && index < lineWidthRatios!.length
              ? lineWidthRatios![index]
              : (index == lines - 1 ? 0.7 : 1.0); // Last line is shorter by default

          return Padding(
            padding: EdgeInsets.only(bottom: index < lines - 1 ? lineSpacing : 0),
            child: FractionallySizedBox(
              widthFactor: widthRatio,
              alignment: Alignment.centerLeft,
              child: ShimmerTextLine(
                height: lineHeight,
                semanticLabel: null, // Handled by parent Semantics
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Shimmer loading for a list item
class ShimmerListTile extends StatelessWidget {
  /// Whether to show a leading widget (e.g., avatar/icon)
  final bool hasLeading;

  /// Leading widget size
  final double leadingSize;

  /// Whether to show a trailing widget (e.g., icon/chevron)
  final bool hasTrailing;

  /// Whether leading is circular (avatar) or rectangular (icon)
  final bool circularLeading;

  /// Number of subtitle lines
  final int subtitleLines;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.leadingSize = 48.0,
    this.hasTrailing = true,
    this.circularLeading = true,
    this.subtitleLines = 1,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading list item',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading widget
            if (hasLeading) ...[
              Shimmer(
                semanticLabel: null, // Handled by parent
                child: Container(
                  width: leadingSize,
                  height: leadingSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: circularLeading ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: circularLeading ? null : BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
            ],

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerTextLine(
                    width: null,
                    height: 18.0,
                    semanticLabel: null,
                  ),
                  const SizedBox(height: 8.0),

                  // Subtitle lines
                  if (subtitleLines > 0)
                    ShimmerTextBlock(
                      lines: subtitleLines,
                      lineHeight: 14.0,
                      lineSpacing: 6.0,
                      lineWidthRatios: subtitleLines > 1
                          ? List.generate(subtitleLines, (i) => 0.9 - (i * 0.1))
                          : [0.6],
                      semanticLabel: null,
                    ),
                ],
              ),
            ),

            // Trailing widget
            if (hasTrailing) ...[
              const SizedBox(width: 16.0),
              Shimmer(
                semanticLabel: null,
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for a card
class ShimmerCard extends StatelessWidget {
  /// Height of the card
  final double height;

  /// Whether to show an image/thumbnail at the top
  final bool hasImage;

  /// Image height
  final double imageHeight;

  /// Number of title lines
  final int titleLines;

  /// Number of content lines
  final int contentLines;

  /// Whether to show action buttons at the bottom
  final bool hasActions;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerCard({
    super.key,
    this.height = 200.0,
    this.hasImage = false,
    this.imageHeight = 120.0,
    this.titleLines = 1,
    this.contentLines = 3,
    this.hasActions = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading card content',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (hasImage)
                Shimmer(
                  semanticLabel: null,
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      ShimmerTextBlock(
                        lines: titleLines,
                        lineHeight: 20.0,
                        lineSpacing: 6.0,
                        semanticLabel: null,
                      ),
                      const SizedBox(height: 12.0),

                      // Content
                      Expanded(
                        child: ShimmerTextBlock(
                          lines: contentLines,
                          lineHeight: 16.0,
                          lineSpacing: 8.0,
                          semanticLabel: null,
                        ),
                      ),

                      // Actions
                      if (hasActions) ...[
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Shimmer(
                              semanticLabel: null,
                              child: Container(
                                width: 80.0,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Shimmer(
                              semanticLabel: null,
                              child: Container(
                                width: 80.0,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading for a grid item (e.g., product card)
class ShimmerGridItem extends StatelessWidget {
  /// Aspect ratio of the grid item
  final double aspectRatio;

  /// Whether to show an image at the top
  final bool hasImage;

  /// Image aspect ratio
  final double imageAspectRatio;

  /// Number of title lines
  final int titleLines;

  /// Number of subtitle lines
  final int subtitleLines;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerGridItem({
    super.key,
    this.aspectRatio = 0.75,
    this.hasImage = true,
    this.imageAspectRatio = 1.0,
    this.titleLines = 2,
    this.subtitleLines = 1,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading grid item',
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (hasImage)
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: Shimmer(
                  semanticLabel: null,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  ShimmerTextBlock(
                    lines: titleLines,
                    lineHeight: 16.0,
                    lineSpacing: 6.0,
                    semanticLabel: null,
                  ),
                  if (subtitleLines > 0) ...[
                    const SizedBox(height: 8.0),
                    // Subtitle
                    ShimmerTextBlock(
                      lines: subtitleLines,
                      lineHeight: 14.0,
                      lineSpacing: 4.0,
                      lineWidthRatios: [0.5],
                      semanticLabel: null,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for a circular avatar
class ShimmerAvatar extends StatelessWidget {
  /// Size of the avatar
  final double size;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerAvatar({
    super.key,
    this.size = 48.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      semanticLabel: semanticLabel ?? 'Loading avatar',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ============================================================================
// CONVENIENCE BUILDERS
// ============================================================================

/// Builds a shimmer loading list with multiple items
class ShimmerListView extends StatelessWidget {
  /// Number of list items to show
  final int itemCount;

  /// Item builder configuration
  final bool hasLeading;
  final bool hasTrailing;
  final bool circularLeading;
  final int subtitleLines;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerListView({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.hasTrailing = true,
    this.circularLeading = true,
    this.subtitleLines = 1,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading list',
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ShimmerListTile(
            hasLeading: hasLeading,
            hasTrailing: hasTrailing,
            circularLeading: circularLeading,
            subtitleLines: subtitleLines,
            semanticLabel: null, // Handled by parent
          );
        },
      ),
    );
  }
}

/// Builds a shimmer loading grid with multiple items
class ShimmerGridView extends StatelessWidget {
  /// Number of grid items to show
  final int itemCount;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Grid item configuration
  final double aspectRatio;
  final bool hasImage;
  final int titleLines;
  final int subtitleLines;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerGridView({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.75,
    this.hasImage = true,
    this.titleLines = 2,
    this.subtitleLines = 1,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading grid',
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ShimmerGridItem(
            aspectRatio: aspectRatio,
            hasImage: hasImage,
            titleLines: titleLines,
            subtitleLines: subtitleLines,
            semanticLabel: null, // Handled by parent
          );
        },
      ),
    );
  }
}

/// Builds a shimmer loading for a card list
class ShimmerCardList extends StatelessWidget {
  /// Number of cards to show
  final int itemCount;

  /// Card configuration
  final double cardHeight;
  final bool hasImage;
  final int titleLines;
  final int contentLines;
  final bool hasActions;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const ShimmerCardList({
    super.key,
    this.itemCount = 3,
    this.cardHeight = 200.0,
    this.hasImage = false,
    this.titleLines = 1,
    this.contentLines = 3,
    this.hasActions = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Loading cards',
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ShimmerCard(
            height: cardHeight,
            hasImage: hasImage,
            titleLines: titleLines,
            contentLines: contentLines,
            hasActions: hasActions,
            semanticLabel: null, // Handled by parent
          );
        },
      ),
    );
  }
}
