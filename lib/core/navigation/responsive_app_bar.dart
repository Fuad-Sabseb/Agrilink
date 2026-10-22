import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Responsive app bar that adapts to screen size
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
      elevation: elevation ?? AppTokens.elevationNone,
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: _getTitleStyle(isTablet, isDesktop),
                )
              : null),
      actions: _buildActions(context, isTablet, isDesktop),
      bottom: bottom,
      centerTitle: !isDesktop,
    );
  }

  TextStyle _getTitleStyle(bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return AppTypography.headlineSmall.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      );
    } else if (isTablet) {
      return AppTypography.titleLarge.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      );
    } else {
      return AppTypography.titleMedium.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      );
    }
  }

  List<Widget>? _buildActions(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    if (actions == null || actions!.isEmpty) return null;

    // On mobile, show overflow menu if there are too many actions
    if (!isTablet && actions!.length > 2) {
      return [
        actions!.first,
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          onSelected: (index) {
            // Handle action tap
          },
          itemBuilder: (context) {
            return List.generate(
              actions!.length - 1,
              (index) => PopupMenuItem(
                value: index + 1,
                child: actions![index + 1],
              ),
            );
          },
        ),
      ];
    }

    return actions;
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

/// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final String? searchHint;
  final Function(String)? onSearch;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SearchAppBar({
    super.key,
    this.title,
    this.searchHint,
    this.onSearch,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor ?? AppColors.primary,
      foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
      elevation: AppTokens.elevationNone,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                color: widget.foregroundColor ?? AppColors.textOnPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Search...',
                hintStyle: TextStyle(
                  color: (widget.foregroundColor ?? AppColors.textOnPrimary)
                      .withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
              onChanged: widget.onSearch,
            )
          : Text(widget.title ?? ''),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              widget.onSearch?.call('');
            },
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
      ],
    );
  }
}
