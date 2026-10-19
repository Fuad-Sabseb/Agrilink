import 'package:flutter/material.dart';

/// RefreshableContent Widget
/// Wraps content with pull-to-refresh functionality
/// Provides consistent refresh behavior across all list screens
///
/// **Validates: Requirements 14.8, 14.9**

/// Widget that adds pull-to-refresh functionality
class RefreshableContent extends StatelessWidget {
  /// Child widget to wrap (typically a ListView or ScrollView)
  final Widget child;

  /// Callback for refresh action
  final Future<void> Function() onRefresh;

  /// Optional refresh indicator color
  final Color? color;

  /// Optional background color
  final Color? backgroundColor;

  /// Displacement of the refresh indicator
  final double displacement;

  /// Stroke width of the refresh indicator
  final double strokeWidth;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const RefreshableContent({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Pull to refresh',
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? Theme.of(context).colorScheme.primary,
        backgroundColor: backgroundColor,
        displacement: displacement,
        strokeWidth: strokeWidth,
        child: child,
      ),
    );
  }
}

/// Mixin for screens that need pull-to-refresh functionality
mixin RefreshableMixin<T extends StatefulWidget> on State<T> {
  bool _isRefreshing = false;

  /// Whether a refresh is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Perform refresh operation
  /// Override this method in your widget to implement refresh logic
  Future<void> performRefresh();

  /// Handle refresh with loading state management
  Future<void> handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await performRefresh();
    } catch (e) {
      // Error handling should be done in performRefresh
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// Wrap your content with RefreshIndicator
  Widget buildRefreshableContent({
    required Widget child,
    Color? color,
    String? semanticLabel,
  }) {
    return RefreshableContent(
      onRefresh: handleRefresh,
      color: color,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// Always scrollable wrapper for enabling refresh on short content
class AlwaysScrollableWrapper extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Padding around the content
  final EdgeInsetsGeometry? padding;

  const AlwaysScrollableWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: child,
    );
  }
}

/// Refreshable list view builder
class RefreshableListView extends StatelessWidget {
  /// Callback for refresh action
  final Future<void> Function() onRefresh;

  /// Number of items in the list
  final int itemCount;

  /// Item builder function
  final Widget Function(BuildContext, int) itemBuilder;

  /// Optional separator builder
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Optional padding
  final EdgeInsetsGeometry? padding;

  /// Optional physics
  final ScrollPhysics? physics;

  /// Optional shrink wrap
  final bool shrinkWrap;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const RefreshableListView({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final listView = separatorBuilder != null
        ? ListView.separated(
            controller: controller,
            padding: padding,
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder!,
          )
        : ListView.builder(
            controller: controller,
            padding: padding,
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );

    return RefreshableContent(
      onRefresh: onRefresh,
      semanticLabel: semanticLabel,
      child: listView,
    );
  }
}

/// Refreshable grid view builder
class RefreshableGridView extends StatelessWidget {
  /// Callback for refresh action
  final Future<void> Function() onRefresh;

  /// Number of items in the grid
  final int itemCount;

  /// Item builder function
  final Widget Function(BuildContext, int) itemBuilder;

  /// Grid delegate
  final SliverGridDelegate gridDelegate;

  /// Optional padding
  final EdgeInsetsGeometry? padding;

  /// Optional physics
  final ScrollPhysics? physics;

  /// Optional shrink wrap
  final bool shrinkWrap;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const RefreshableGridView({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final gridView = GridView.builder(
      controller: controller,
      padding: padding,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    return RefreshableContent(
      onRefresh: onRefresh,
      semanticLabel: semanticLabel,
      child: gridView,
    );
  }
}
