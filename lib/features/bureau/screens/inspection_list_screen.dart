import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/inspection_provider.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/theme/colors.dart';
import 'inspection_details_screen.dart';

/// Inspection List Screen with advanced filtering and search
/// Requirements: 2.1-2.10
class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filters
  InspectionStatus? _statusFilter;
  InspectionType? _typeFilter;
  String? _woredaFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Sort
  SortOption _sortOption = SortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().fetchInspections();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspections'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showAdvancedFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildInspectionList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by cooperative, farm, or ID...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All',
              _statusFilter == null && _typeFilter == null && _woredaFilter == null,
              () {
                setState(() {
                  _statusFilter = null;
                  _typeFilter = null;
                  _woredaFilter = null;
                });
              },
              AppColors.primary,
            ),
            const SizedBox(width: 8),
            ...InspectionStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  status.displayName,
                  _statusFilter == status,
                  () => setState(() => _statusFilter = status),
                  _getStatusColor(status),
                ),
              );
            }).toList(),
            const VerticalDivider(),
            const SizedBox(width: 8),
            _buildSortDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: _sortOption,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          items: const [
            DropdownMenuItem(
              value: SortOption.dateNewest,
              child: Text('Newest First'),
            ),
            DropdownMenuItem(
              value: SortOption.dateOldest,
              child: Text('Oldest First'),
            ),
            DropdownMenuItem(
              value: SortOption.priorityHigh,
              child: Text('High Priority'),
            ),
            DropdownMenuItem(
              value: SortOption.priorityLow,
              child: Text('Low Priority'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortOption = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInspectionList() {
    return Consumer<InspectionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.inspections.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        // Apply filters
        var inspections = _searchQuery.isNotEmpty
            ? provider.searchInspections(_searchQuery)
            : provider.inspections;

        inspections = provider.filteredInspections(
          status: _statusFilter,
          type: _typeFilter,
          woredaId: _woredaFilter,
          startDate: _startDate,
          endDate: _endDate,
        );

        // Apply sort
        inspections = provider.sortInspections(inspections, _sortOption);

        if (inspections.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchInspections(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              return _buildInspectionCard(inspections[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InspectionDetailsScreen(
              inspectionId: inspection.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inspection.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(inspection.type),
                    color: _getStatusColor(inspection.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inspection.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inspection.cooperativeName ?? inspection.farmName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inspection.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    inspection.status.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  inspection.woredaName,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(inspection.checkInTime),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (inspection.findings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${inspection.findings.length} finding${inspection.findings.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (inspection.issueCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      '${inspection.issueCount} critical issue${inspection.issueCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'No inspections found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'Error loading inspections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<InspectionProvider>().fetchInspections();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTypeFilter(),
              const SizedBox(height: 16),
              _buildDateRangeFilter(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = null;
                          _typeFilter = null;
                          _woredaFilter = null;
                          _startDate = null;
                          _endDate = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspection Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: InspectionType.values.map((type) {
            final isSelected = _typeFilter == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _typeFilter = isSelected ? null : type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Select'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate == null
                        ? 'Select'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.scheduled:
        return AppColors.tertiary;
      case InspectionStatus.inProgress:
        return AppColors.secondary;
      case InspectionStatus.completed:
        return AppColors.success;
      case InspectionStatus.cancelled:
        return AppColors.disabled;
    }
  }

  IconData _getTypeIcon(InspectionType type) {
    switch (type) {
      case InspectionType.routine:
        return Icons.event_repeat;
      case InspectionType.followUp:
        return Icons.follow_the_signs;
      case InspectionType.complaint:
        return Icons.report_problem;
      case InspectionType.preHarvest:
        return Icons.eco;
      case InspectionType.postHarvest:
        return Icons.inventory;
      case InspectionType.emergency:
        return Icons.emergency;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
