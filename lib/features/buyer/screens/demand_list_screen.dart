import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/buyer_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/demand_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../widgets/demand_card.dart';
import 'create_demand_screen.dart';
import 'demand_detail_screen.dart';

/// Demand List Screen
/// Displays all buyer demands with filters
class DemandListScreen extends StatefulWidget {
  const DemandListScreen({super.key});

  @override
  State<DemandListScreen> createState() => _DemandListScreenState();
}

class _DemandListScreenState extends State<DemandListScreen> {
  final _sessionService = SessionService();
  bool _isInitialized = false;
  
  // Filters
  BuyingStatus? _selectedStatus;
  CropType? _selectedCropType;

  @override
  void initState() {
    super.initState();
    _loadDemands();
  }

  Future<void> _loadDemands() async {
    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to view demands'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    final provider = context.read<BuyerProvider>();
    await provider.loadBuyerDemands(buyerId);
    
    setState(() => _isInitialized = true);
  }

  Future<void> _refreshDemands() async {
    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) return;

    final provider = context.read<BuyerProvider>();
    await provider.loadBuyerDemands(buyerId, forceRefresh: true);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  void _applyFilters(BuyingStatus? status, CropType? cropType) {
    setState(() {
      _selectedStatus = status;
      _selectedCropType = cropType;
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedCropType = null;
    });
    Navigator.pop(context);
  }

  List<Demand> _getFilteredDemands(List<Demand> demands) {
    return demands.where((demand) {
      if (_selectedStatus != null && demand.status != _selectedStatus) {
        return false;
      }
      if (_selectedCropType != null && demand.cropType != _selectedCropType) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'My Demands',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedStatus != null || _selectedCropType != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilters,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: !_isInitialized
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshDemands,
              color: AppColors.primary,
              child: _buildContent(),
            ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateDemandScreen(),
                  ),
                );
                if (result == true) {
                  _refreshDemands();
                }
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('New Demand'),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading demands...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final provider = context.watch<BuyerProvider>();
    
    if (provider.demandsError != null) {
      return _buildErrorState(provider.demandsError!);
    }

    final allDemands = provider.demands;
    final filteredDemands = _getFilteredDemands(allDemands);

    if (allDemands.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredDemands.isEmpty) {
      return _buildNoResultsState();
    }

    return Column(
      children: [
        if (_selectedStatus != null || _selectedCropType != null)
          _buildActiveFiltersBar(filteredDemands.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDemands.length,
            itemBuilder: (context, index) {
              final demand = filteredDemands[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DemandCard(
                  demand: demand,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DemandDetailScreen(demand: demand),
                      ),
                    );
                    if (result == true) {
                      _refreshDemands();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersBar(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count result${count == 1 ? '' : 's'}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    BuyingStatus? tempStatus = _selectedStatus;
    CropType? tempCropType = _selectedCropType;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Demands',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'All Status',
                    isSelected: tempStatus == null,
                    onTap: () => setModalState(() => tempStatus = null),
                  ),
                  ...BuyingStatus.values.map((status) => _buildFilterChip(
                        label: status.displayName,
                        isSelected: tempStatus == status,
                        onTap: () => setModalState(() => tempStatus = status),
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Crop Type',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'All Crops',
                    isSelected: tempCropType == null,
                    onTap: () => setModalState(() => tempCropType = null),
                  ),
                  ...CropType.values.map((crop) => _buildFilterChip(
                        label: _getCropDisplayName(crop),
                        isSelected: tempCropType == crop,
                        onTap: () => setModalState(() => tempCropType = crop),
                      )),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _applyFilters(null, null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _applyFilters(tempStatus, tempCropType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No demands yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first demand to let farmers know what you\'re looking for',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateDemandScreen(),
                  ),
                );
                if (result == true) {
                  _refreshDemands();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Demand'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matching demands',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load demands',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshDemands,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCropDisplayName(CropType crop) {
    return crop.name[0].toUpperCase() + crop.name.substring(1);
  }
}
