import 'package:flutter/material.dart';

/// EmptyState Widget
/// Production-ready empty state for zero-result scenarios
/// Displays icon, title, message, and optional action button
///
/// **Validates: Requirements 15.1, 15.2**

/// Empty state widget for zero-result screens
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Message text
  final String message;

  /// Optional action button text (e.g., "Add Item", "Try Again")
  final String? actionLabel;

  /// Optional action button callback
  final VoidCallback? onAction;

  /// Icon size
  final double iconSize;

  /// Icon color (defaults to theme's disabled color)
  final Color? iconColor;

  /// Semantic label for screen readers
  final String? semanticLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80.0,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? '$title. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? theme.disabledColor,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),

              // Action button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pre-configured empty state for no data scenarios
class NoDataEmptyState extends StatelessWidget {
  /// Optional custom title
  final String? title;

  /// Optional custom message
  final String? message;

  /// Optional action button
  final String? actionLabel;
  final VoidCallback? onAction;

  const NoDataEmptyState({
    super.key,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: title ?? 'No Data',
      message: message ?? 'There is no data to display at the moment.',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Pre-configured empty state for no search results
class NoSearchResultsEmptyState extends StatelessWidget {
  /// Search query that returned no results
  final String? searchQuery;

  /// Optional action button
  final String? actionLabel;
  final VoidCallback? onAction;

  const NoSearchResultsEmptyState({
    super.key,
    this.searchQuery,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No results found for "$searchQuery". Try a different search term.'
          : 'No results found. Try a different search term.',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Pre-configured empty state for empty lists
class EmptyListState extends StatelessWidget {
  /// Type of items in the list (e.g., "orders", "farms", "transactions")
  final String itemType;

  /// Optional action button
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyListState({
    super.key,
    required this.itemType,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.list_alt_outlined,
      title: 'No ${_capitalize(itemType)}',
      message: 'You don\'t have any $itemType yet.',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// Pre-configured empty state for filtered results
class NoFilteredResultsEmptyState extends StatelessWidget {
  /// Optional action button to clear filters
  final VoidCallback? onClearFilters;

  const NoFilteredResultsEmptyState({
    super.key,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: 'No Matching Results',
      message: 'No items match your current filters. Try adjusting your filters.',
      actionLabel: onClearFilters != null ? 'Clear Filters' : null,
      onAction: onClearFilters,
    );
  }
}

/// Pre-configured empty state for coming soon features
class ComingSoonEmptyState extends StatelessWidget {
  /// Feature name
  final String featureName;

  const ComingSoonEmptyState({
    super.key,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.hourglass_empty_outlined,
      title: 'Coming Soon',
      message: '$featureName will be available soon. Stay tuned!',
    );
  }
}
