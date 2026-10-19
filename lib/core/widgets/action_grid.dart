import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Action Grid Item Data Model
class ActionGridItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String? badge;

  ActionGridItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    this.badge,
  });
}

/// Action Grid Widget
/// 2x4 or 2x3 icon action grid with rounded pill borders and distinct colored
/// icon containers matching Lao Agrolink's design pattern
class ActionGrid extends StatelessWidget {
  final List<ActionGridItem> items;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets padding;

  const ActionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _ActionGridTile(item: items[index]);
        },
      ),
    );
  }
}

/// Individual Action Grid Tile
class _ActionGridTile extends StatelessWidget {
  final ActionGridItem item;

  const _ActionGridTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: AppColors.shadow12,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: item.iconColor.withValues(alpha: 0.1),
        highlightColor: item.iconColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container with colored background
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: item.backgroundColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      item.icon,
                      size: 28,
                      color: item.iconColor,
                    ),
                  ),
                  // Badge
                  if (item.badge != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          item.badge!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                item.title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Action Grid (Horizontal Scrollable)
/// Alternative layout for feature-rich dashboards
class CompactActionGrid extends StatelessWidget {
  final List<ActionGridItem> items;
  final double itemWidth;
  final double itemHeight;

  const CompactActionGrid({
    super.key,
    required this.items,
    this.itemWidth = 100,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _CompactActionTile(
            item: items[index],
            width: itemWidth,
          );
        },
      ),
    );
  }
}

class _CompactActionTile extends StatelessWidget {
  final ActionGridItem item;
  final double width;

  const _CompactActionTile({
    required this.item,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: AppColors.shadow12,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: item.iconColor.withValues(alpha: 0.1),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      item.icon,
                      size: 24,
                      color: item.iconColor,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          item.badge!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
