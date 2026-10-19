import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';

class TransactionFilterProvider extends ChangeNotifier {
  TransactionFilter _filter = const TransactionFilter();

  TransactionFilter get filter => _filter;
  bool get hasActiveFilters => _filter.hasActiveFilters;
  int get activeFilterCount => _filter.activeFilterCount;

  void setDateRange(DateTimeRange? range) {
    _filter = _filter.copyWith(
      dateRange: range,
      clearDateRange: range == null,
    );
    notifyListeners();
  }

  void setStatuses(List<String> statuses) {
    _filter = _filter.copyWith(statuses: statuses);
    notifyListeners();
  }

  void setCommodities(List<String> commodities) {
    _filter = _filter.copyWith(commodities: commodities);
    notifyListeners();
  }

  void setTypes(List<String> types) {
    _filter = _filter.copyWith(types: types);
    notifyListeners();
  }

  void setAmountRange(double? minAmount, double? maxAmount) {
    _filter = _filter.copyWith(
      minAmount: minAmount,
      maxAmount: maxAmount,
      clearMinAmount: minAmount == null,
      clearMaxAmount: maxAmount == null,
    );
    notifyListeners();
  }

  void clearFilters() {
    _filter = const TransactionFilter();
    notifyListeners();
  }

  /// Apply filters to a list of transactions
  List<T> applyFilters<T>(List<T> transactions, Map<String, dynamic> Function(T) toMap) {
    if (!hasActiveFilters) return transactions;

    return transactions.where((transaction) {
      return _filter.matches(toMap(transaction));
    }).toList();
  }
}
