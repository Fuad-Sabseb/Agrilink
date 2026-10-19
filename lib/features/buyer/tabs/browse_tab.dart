import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/produce_model.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../widgets/produce_card.dart';
import '../screens/produce_details_screen.dart';

/// Browse Tab - Marketplace for buyers to browse and search produce
class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduceProvider>().loadAllProduce();
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFiltersBar(),
            Expanded(child: _buildProduceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse Produce',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find fresh produce from local farmers',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.primary,
            ),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
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
                    context.read<ProduceProvider>().searchProduce('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          context.read<ProduceProvider>().searchProduce(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFiltersBar() {
    final produceProvider = context.watch<ProduceProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filter by status
            _buildFilterChip(
              label: 'Available',
              isSelected: (produceProvider.activeFilters ?? {})['status'] == 'available',
              onTap: () {
                if ((produceProvider.activeFilters ?? {})['status'] == 'available') {
                  produceProvider.applyFilter(status: 'all');
                } else {
                  produceProvider.applyFilter(status: 'available');
                }
              },
            ),
            const SizedBox(width: 8),
            // Sort dropdown
            PopupMenuButton<String>(
              initialValue: _sortBy,
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
                produceProvider.sortProduce(
                  value,
                  ascending: value == 'name' || value == 'date',
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date',
                  child: Text('Newest First'),
                ),
                const PopupMenuItem(
                  value: 'price',
                  child: Text('Price: Low to High'),
                ),
                const PopupMenuItem(
                  value: 'name',
                  child: Text('Name: A to Z'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort, size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Sort',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter button
            InkWell(
              onTap: _showProduceFilterBottomSheet,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (produceProvider.activeFilters?.isNotEmpty == true)
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: (produceProvider.activeFilters?.isNotEmpty == true)
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: (produceProvider.activeFilters?.isNotEmpty == true)
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: AppTypography.bodySmall.copyWith(
                        color: (produceProvider.activeFilters?.isNotEmpty == true)
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: (produceProvider.activeFilters?.isNotEmpty == true)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProduceList() {
    final produceProvider = context.watch<ProduceProvider>();

    if (produceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (produceProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              produceProvider.error!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => produceProvider.loadAllProduce(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final produces = produceProvider.filteredProduce
        .where((p) => p.status == 'available')
        .toList();

    if (produces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No produce available',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for fresh produce',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => produceProvider.loadAllProduce(),
      child: _isGridView ? _buildGridView(produces) : _buildListView(produces),
    );
  }

  Widget _buildGridView(List<ProduceModel> produces) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: produces.length,
      itemBuilder: (context, index) {
        return ProduceCard(
          produce: produces[index],
          isGridView: true,
          onTap: () => _navigateToDetails(produces[index]),
        );
      },
    );
  }

  Widget _buildListView(List<ProduceModel> produces) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: produces.length,
      itemBuilder: (context, index) {
        return ProduceCard(
          produce: produces[index],
          isGridView: false,
          onTap: () => _navigateToDetails(produces[index]),
        );
      },
    );
  }

  void _navigateToDetails(ProduceModel produce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProduceDetailsScreen(produce: produce),
      ),
    );
  }

  void _showProduceFilterBottomSheet() {
    final produceProvider = context.read<ProduceProvider>();
    final currentFilters = produceProvider.activeFilters ?? {};
    
    String? selectedCrop = currentFilters['cropType'];
    double? maxPrice = currentFilters['maxPrice'];
    bool isOrganic = currentFilters['isOrganic'] == true;
    String? qualityGrade = currentFilters['qualityGrade'];

    final cropTypes = ['All', 'Teff', 'Coffee', 'Wheat', 'Maize', 'Barley', 'Potato', 'Beans', 'Sorghum'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Produce',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          produceProvider.clearFilters();
                          Navigator.pop(bottomSheetContext);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Crop type
                  Text(
                    'Crop Type',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cropTypes.map((crop) {
                      final isSelected = (selectedCrop == null && crop == 'All') ||
                          (selectedCrop?.toLowerCase() == crop.toLowerCase());
                      return ChoiceChip(
                        label: Text(crop),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedCrop = (crop == 'All' || !selected) ? null : crop.toLowerCase();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Max price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max Price per Unit',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        maxPrice != null ? '${maxPrice!.toStringAsFixed(0)} ETB' : 'Any',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: maxPrice ?? 500,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '${(maxPrice ?? 500).toStringAsFixed(0)} ETB',
                    onChanged: (val) {
                      setModalState(() => maxPrice = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quality grade
                  Text(
                    'Quality Grade',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final grade in ['All', 'Grade 1', 'Grade 2', 'Grade 3'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(grade),
                            selected: (qualityGrade == null && grade == 'All') || qualityGrade == grade,
                            onSelected: (selected) {
                              setModalState(() {
                                qualityGrade = (grade == 'All' || !selected) ? null : grade;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Organic switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Organic Produce Only'),
                    subtitle: const Text('Show certified organic crops only'),
                    value: isOrganic,
                    onChanged: (val) {
                      setModalState(() => isOrganic = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () {
                      produceProvider.filterProduce(
                        cropType: selectedCrop,
                        maxPrice: maxPrice,
                        qualityGrade: qualityGrade,
                        isOrganic: isOrganic ? true : null,
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
