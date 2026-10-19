import 'package:flutter/material.dart';

class TransactionFilter {
  final DateTimeRange? dateRange;
  final List<String> statuses;
  final List<String> commodities;
  final List<String> types;
  final double? minAmount;
  final double? maxAmount;

  const TransactionFilter({
    this.dateRange,
    this.statuses = const [],
    this.commodities = const [],
    this.types = const [],
    this.minAmount,
    this.maxAmount,
  });

  bool get hasActiveFilters {
    return dateRange != null ||
        statuses.isNotEmpty ||
        commodities.isNotEmpty ||
        types.isNotEmpty ||
        minAmount != null ||
        maxAmount != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (dateRange != null) count++;
    if (statuses.isNotEmpty) count++;
    if (commodities.isNotEmpty) count++;
    if (types.isNotEmpty) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }

  TransactionFilter copyWith({
    DateTimeRange? dateRange,
    List<String>? statuses,
    List<String>? commodities,
    List<String>? types,
    double? minAmount,
    double? maxAmount,
    bool clearDateRange = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return TransactionFilter(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      statuses: statuses ?? this.statuses,
      commodities: commodities ?? this.commodities,
      types: types ?? this.types,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  TransactionFilter clear() {
    return const TransactionFilter();
  }

  /// Apply filter to a list of transactions
  bool matches(Map<String, dynamic> transaction) {
    // Date range filter
    if (dateRange != null) {
      final transactionDate = DateTime.parse(transaction['date'] as String);
      if (transactionDate.isBefore(dateRange!.start) ||
          transactionDate.isAfter(dateRange!.end)) {
        return false;
      }
    }

    // Status filter
    if (statuses.isNotEmpty) {
      final status = transaction['status'] as String?;
      if (status == null || !statuses.contains(status)) {
        return false;
      }
    }

    // Commodity filter
    if (commodities.isNotEmpty) {
      final commodity = transaction['commodity'] as String?;
      if (commodity == null || !commodities.contains(commodity)) {
        return false;
      }
    }

    // Type filter
    if (types.isNotEmpty) {
      final type = transaction['type'] as String?;
      if (type == null || !types.contains(type)) {
        return false;
      }
    }

    // Amount range filter
    final amount = (transaction['amount'] as num?)?.toDouble();
    if (amount != null) {
      if (minAmount != null && amount < minAmount!) {
        return false;
      }
      if (maxAmount != null && amount > maxAmount!) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    return 'TransactionFilter(activeFilters: $activeFilterCount)';
  }
}

// Available filter options
class TransactionFilterOptions {
  static const List<String> statuses = [
    'Pending',
    'Confirmed',
    'In Transit',
    'Delivered',
    'Completed',
    'Cancelled',
  ];

  static const List<String> types = [
    'Sale',
    'Purchase',
    'Transport',
  ];

  // Commodities will be fetched dynamically from the app
  static const List<String> commonCommodities = [
    'Maize',
    'Wheat',
    'Teff',
    'Barley',
    'Sorghum',
    'Coffee',
    'Beans',
    'Peas',
  ];
}
