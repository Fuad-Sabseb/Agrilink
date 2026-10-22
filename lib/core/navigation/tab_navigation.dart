import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Tab navigation item
class TabNavigationItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final Widget? badge;

  const TabNavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
    this.badge,
  });
}

/// Tab navigation with bottom tabs
class TabNavigation extends StatefulWidget {
  final List<TabNavigationItem> items;
  final int initialIndex;
  final String? title;
  final List<Widget>? actions;
  final bool showAppBar;

  const TabNavigation({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.title,
    this.actions,
    this.showAppBar = true,
  });

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: AppTokens.elevationNone,
              title: widget.title != null ? Text(widget.title!) : null,
              actions: widget.actions,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textOnPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor:
                    AppColors.textOnPrimary.withOpacity(0.6),
                labelStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.labelMedium,
                tabs: widget.items.map((item) {
                  return Tab(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.icon, size: AppTokens.iconS),
                        if (item.badge != null)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: item.badge!,
                          ),
                      ],
                    ),
                    text: item.label,
                  );
                }).toList(),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: widget.items.map((item) => item.screen).toList(),
      ),
    );
  }
}

/// Tab badge for notifications
class TabBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const TabBadge({
    super.key,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceXXS),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
