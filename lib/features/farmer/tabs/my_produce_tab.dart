import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../models/produce_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../widgets/produce_list_item.dart';
import '../screens/add_produce_screen.dart';
import '../screens/produce_detail_screen.dart';

/// My Produce Tab with list, search, filter, and sort capabilities
class MyProduceTab extends StatefulWidget {
  const MyProduceTab({super.key});

  @override
  State<MyProduceTab> createState() => _MyProduceTabState();
}

class _MyProduceTabState extends State<MyProduceTab>
    with AutomaticKeepAliveClientMixin {
  final _sessionService = SessionService();
  final _searchController = TextEditingController();
  
  String _selectedFilter = 'all'; // all, available, sold, reserved
  String _selectedSort = 'newest'; // newest, oldest, price_high, price_low, name

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final userId = _sessionService.currentUserId;
    if (userId != null) {
      await context.read<ProduceProvider>().loadFarmerProduce(userId);
    }
  }

  void _applyFilters() {
    final provider = context.read<ProduceProvider>();
    
    // Apply status filter
    if (_selectedFilter != 'all') {
      provider.applyFilter(status: _selectedFilter);
    } else {
      provider.clearFilters();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      provider.searchProduce(_searchController.text);
    }

    // Apply sort
    switch (_selectedSort) {
      case 'newest':
        provider.sortProduce('date', ascending: false);
        break;
      case 'oldest':
        provider.sortProduce('date', ascending: true);
        break;
      case 'price_high':
        provider.sortProduce('price', ascending: false);
        break;
      case 'price_low':
        provider.sortProduce('price', ascending: true);
        break;
      case 'name':
        provider.sortProduce('name');
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter & Sort',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Status Filter
              Text(
                'Status',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('All', 'all', setModalState),
                  _buildFilterChip('Available', 'available', setModalState),
                  _buildFilterChip('Sold', 'sold', setModalState),
                  _buildFilterChip('Reserved', 'reserved', setModalState),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sort Options
              Text(
                'Sort By',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip('Newest', 'newest', setModalState),
                  _buildSortChip('Oldest', 'oldest', setModalState),
                  _buildSortChip('Price: High', 'price_high', setModalState),
                  _buildSortChip('Price: Low', 'price_low', setModalState),
                  _buildSortChip('Name', 'name', setModalState),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _selectedSort = value;
        });
      },
      selectedColor: AppColors.info.withValues(alpha: 0.2),
      checkmarkColor: AppColors.info,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.info : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final provider = context.watch<ProduceProvider>();
    final produceList = provider.filteredProduce;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search produce...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Badge(
                    isLabelVisible: _selectedFilter != 'all' || _selectedSort != 'newest',
                    child: const Icon(Icons.filter_list_rounded),
                  ),
                  onPressed: _showFilterBottomSheet,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(12),
                  ),
                  tooltip: 'Filter & Sort',
                ),
              ],
            ),
          ),

          // Statistics Bar
          _buildStatisticsBar(provider),

          // Produce List
          Expanded(
            child: _buildProduceList(provider, produceList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProduceScreen(),
            ),
          );
          if (result == true) {
            _refreshData();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Produce'),
      ),
    );
  }

  Widget _buildStatisticsBar(ProduceProvider provider) {
    final stats = provider.statistics;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            '${stats['totalListings'] ?? 0}',
            Icons.inventory_2_outlined,
            AppColors.primary,
          ),
          _buildStatItem(
            'Available',
            '${stats['availableCount'] ?? 0}',
            Icons.check_circle_outline,
            AppColors.success,
          ),
          _buildStatItem(
            'Sold',
            '${stats['soldCount'] ?? 0}',
            Icons.shopping_cart_outlined,
            AppColors.info,
          ),
          _buildStatItem(
            'Value',
            'ETB ${(stats['totalValue'] ?? 0).toStringAsFixed(0)}',
            Icons.attach_money,
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProduceList(ProduceProvider provider, List<ProduceModel> produceList) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your produce...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load produce',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (produceList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != 'all'
                  ? 'No produce found'
                  : 'No produce yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != 'all'
                  ? 'Try adjusting your filters'
                  : 'Add your first produce listing',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_searchController.text.isEmpty && _selectedFilter == 'all') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProduceScreen(),
                    ),
                  );
                  if (result == true) {
                    _refreshData();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Produce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: produceList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final produce = produceList[index];
          return ProduceListItem(
            produce: produce,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProduceDetailScreen(produce: produce),
                ),
              );
              if (result == true) {
                _refreshData();
              }
            },
          );
        },
      ),
    );
  }
}
