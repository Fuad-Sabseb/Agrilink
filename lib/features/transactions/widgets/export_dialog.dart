import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/export_service.dart';

class ExportDialog extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final String? userName;

  const ExportDialog({
    super.key,
    required this.transactions,
    this.userName,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final ExportService _exportService = ExportService();
  String _selectedFormat = 'CSV';
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  String? _error;

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_dateRange == null) return widget.transactions;

    return widget.transactions.where((t) {
      final date = DateTime.tryParse(t['date'] as String? ?? '');
      if (date == null) return false;
      return date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      // Validate max 12 months
      if (!_exportService.validateDateRange(picked.start, picked.end)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date range cannot exceed 12 months'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() => _dateRange = picked);
    }
  }

  Future<void> _export() async {
    if (_filteredTransactions.isEmpty) {
      setState(() => _error = 'No transactions to export');
      return;
    }

    setState(() {
      _isExporting = true;
      _error = null;
    });

    try {
      final String filePath;

      if (_selectedFormat == 'CSV') {
        filePath = await _exportService.exportToCsv(_filteredTransactions);
      } else {
        filePath = await _exportService.exportToPdf(
          _filteredTransactions,
          userName: widget.userName,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        
        // Show share dialog
        await _exportService.shareFile(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported ${_filteredTransactions.length} transactions'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Transactions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select export format and date range',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Format selection
            Text(
              'Format',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'CSV', label: Text('CSV')),
                ButtonSegment(value: 'PDF', label: Text('PDF')),
              ],
              selected: {_selectedFormat},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedFormat = selection.first);
              },
            ),
            const SizedBox(height: 16),

            // Date range
            Text(
              'Date Range (Optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _dateRange == null
                    ? 'All Transactions'
                    : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            if (_dateRange != null)
              TextButton.icon(
                onPressed: () => setState(() => _dateRange = null),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
              ),
            
            const SizedBox(height: 8),
            Text(
              '${_filteredTransactions.length} transactions will be exported',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isExporting || _filteredTransactions.isEmpty ? null : _export,
          child: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
