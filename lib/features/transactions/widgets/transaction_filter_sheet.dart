import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/transaction_filter_provider.dart';
import '../../../core/models/transaction_filter.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionFilter _currentFilter;
  late List<String> _selectedStatuses;
  late List<String> _selectedCommodities;
  late List<String> _selectedTypes;
  DateTimeRange? _selectedDateRange;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TransactionFilterProvider>();
    _currentFilter = provider.filter;
    _selectedStatuses = List.from(_currentFilter.statuses);
    _selectedCommodities = List.from(_currentFilter.commodities);
    _selectedTypes = List.from(_currentFilter.types);
    _selectedDateRange = _currentFilter.dateRange;
    
    if (_currentFilter.minAmount != null) {
      _minAmountController.text = _currentFilter.minAmount.toString();
    }
    if (_currentFilter.maxAmount != null) {
      _maxAmountController.text = _currentFilter.maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = context.read<TransactionFilterProvider>();
    
    provider.setStatuses(_selectedStatuses);
    provider.setCommodities(_selectedCommodities);
    provider.setTypes(_selectedTypes);
    provider.setDateRange(_selectedDateRange);
    
    final minAmount = double.tryParse(_minAmountController.text);
    final maxAmount = double.tryParse(_maxAmountController.text);
    provider.setAmountRange(minAmount, maxAmount);
    
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatuses.clear();
      _selectedCommodities.clear();
      _selectedTypes.clear();
      _selectedDateRange = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Filter Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Filter content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDateRangeSection(),
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildCommoditySection(),
                    const SizedBox(height: 24),
                    _buildTypeSection(),
                    const SizedBox(height: 24),
                    _buildAmountRangeSection(),
                  ],
                ),
              ),
              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _selectDateRange,
          icon: const Icon(Icons.date_range),
          label: Text(
            _selectedDateRange == null
                ? 'Select Date Range'
                : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            alignment: Alignment.centerLeft,
          ),
        ),
        if (_selectedDateRange != null)
          TextButton.icon(
            onPressed: () => setState(() => _selectedDateRange = null),
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
          ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionFilterOptions.statuses.map((status) {
            final isSelected = _selectedStatuses.contains(status);
            return FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status);
                  } else {
                    _selectedStatuses.remove(status);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommoditySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commodity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionFilterOptions.commonCommodities.map((commodity) {
            final isSelected = _selectedCommodities.contains(commodity);
            return FilterChip(
              label: Text(commodity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCommodities.add(commodity);
                  } else {
                    _selectedCommodities.remove(commodity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionFilterOptions.types.map((type) {
            final isSelected = _selectedTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Range (ETB)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minAmountController,
                decoration: const InputDecoration(
                  labelText: 'Min Amount',
                  prefixText: 'ETB ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxAmountController,
                decoration: const InputDecoration(
                  labelText: 'Max Amount',
                  prefixText: 'ETB ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
