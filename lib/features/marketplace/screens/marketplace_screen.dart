import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/demand_model.dart';
import '../../../core/models/buyer_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/services/buyer_marketplace_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../buyer/screens/demand_detail_screen.dart';

/// Marketplace Screen - Phase 3
/// Module 3: Buyer Marketplace with live 'Buying Now' status, reliability scores
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CropType? _selectedCropFilter;
  String _searchQuery = '';
  double? _maxPriceFilter;
  bool _transportProvidedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.marketplace),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.local_offer),
              text: 'Active Demands',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Find Buyers',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveDemandsTab(),
          _buildFindBuyersTab(),
        ],
      ),
    );
  }

  Widget _buildActiveDemandsTab() {
    var demands = _selectedCropFilter == null
        ? BuyerMarketplaceService.getActiveDemands()
        : BuyerMarketplaceService.filterDemandsByCrop(_selectedCropFilter!);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      demands = demands.where((d) =>
        d.cropType.displayName.toLowerCase().contains(q) ||
        d.pickupLocation.toLowerCase().contains(q)
      ).toList();
    }

    if (_maxPriceFilter != null) {
      demands = demands.where((d) => d.priceOfferPerKg <= _maxPriceFilter!).toList();
    }

    if (_transportProvidedOnly) {
      demands = demands.where((d) => d.transportProvided).toList();
    }

    return Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search crop or location...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: Icon(
                  Icons.filter_list,
                  color: (_maxPriceFilter != null || _transportProvidedOnly)
                      ? AppColors.primary
                      : null,
                ),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
        ),

        // Crop filter chips
        Container(
          height: 54,
          color: AppColors.surface,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildFilterChip('All', null),
              const SizedBox(width: 8),
              ...CropType.values.map((crop) {
                if (crop == CropType.other) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(crop.displayName, crop),
                );
              }),
            ],
          ),
        ),
        
        // Demands list
        Expanded(
          child: demands.isEmpty
              ? _buildEmptyState('No active demands found matching filters')
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // Refresh UI
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: demands.length,
                    itemBuilder: (context, index) {
                      final demand = demands[index];
                      final buyer =
                          BuyerMarketplaceService.getBuyerById(demand.buyerId);
                      return _buildDemandCard(demand, buyer);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Demands',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _maxPriceFilter = null;
                          _transportProvidedOnly = false;
                        });
                        Navigator.pop(bottomSheetContext);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Transport Provided Only'),
                  subtitle: const Text('Only show demands where buyer provides transport'),
                  value: _transportProvidedOnly,
                  onChanged: (val) {
                    setModalState(() => _transportProvidedOnly = val);
                    setState(() => _transportProvidedOnly = val);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Max Price Offer: ${_maxPriceFilter != null ? "${_maxPriceFilter!.toStringAsFixed(0)} ETB/kg" : "Any"}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _maxPriceFilter ?? 200,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  label: '${(_maxPriceFilter ?? 200).toStringAsFixed(0)} ETB',
                  onChanged: (val) {
                    setModalState(() => _maxPriceFilter = val);
                    setState(() => _maxPriceFilter = val);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFindBuyersTab() {
    final buyers = BuyerMarketplaceService.getAllBuyers();
    final verifiedBuyers = buyers.where((b) => b.isVerified).toList();
    final activeBuyers = buyers.where((b) => b.isActive).toList();

    return Column(
      children: [
        // Stats summary
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${buyers.length}', 'Total Buyers'),
              Container(width: 1, height: 30, color: AppColors.border),
              _buildStatItem('${verifiedBuyers.length}', 'Verified'),
              Container(width: 1, height: 30, color: AppColors.border),
              _buildStatItem('${activeBuyers.length}', 'Active Now'),
            ],
          ),
        ),
        
        // Buyers list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buyers.length,
            itemBuilder: (context, index) {
              final buyer = buyers[index];
              return _buildBuyerCard(buyer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, CropType? cropType) {
    final isSelected = _selectedCropFilter == cropType;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCropFilter = selected ? cropType : null;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDemandCard(Demand demand, Buyer? buyer) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DemandDetailScreen(demand: demand),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  // 'Buying Now' pulse indicator
                  if (demand.status == BuyingStatus.buyingNow)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (demand.status == BuyingStatus.buyingNow)
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      demand.cropType.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                          '0xFF${demand.status.color.substring(1)}')),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      demand.status.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Buyer info
              if (buyer != null)
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        buyer.businessName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    // Reliability stars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          buyer.reliabilityScore.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (buyer.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 8),
              
              // Price and quantity
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.attach_money,
                      label: 'Price Offer',
                      value: '${demand.priceOfferPerKg.toStringAsFixed(2)} ETB/kg',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.scale,
                      label: 'Quantity',
                      value:
                          '${demand.minimumQuantityKg.toInt()}-${demand.maximumQuantityKg.toInt()} kg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Location and expiry
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            demand.pickupLocation,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (demand.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Urgent: ${demand.hoursUntilExpiry}h left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              // View and response counts
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.visibility, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${demand.viewCount}', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.message, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${demand.responseCount}', style: theme.textTheme.bodySmall),
                  const Spacer(),
                  if (demand.transportProvided)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Transport Provided',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyerCard(Buyer buyer) {
    final theme = Theme.of(context);
    final demands = BuyerMarketplaceService.getDemandsByBuyer(buyer.id);
    final activeDemands =
        demands.where((d) => d.status == BuyingStatus.buyingNow).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBuyerDetailsModal(buyer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      buyer.name[0].toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer.businessName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          buyer.buyerType.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (buyer.isVerified)
                    Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Reliability score
              Row(
                children: [
                  ...List.generate(5, (index) {
                    if (index < buyer.reliabilityScore.floor()) {
                      return Icon(Icons.star, size: 16, color: AppColors.gold);
                    } else if (index < buyer.reliabilityScore) {
                      return Icon(Icons.star_half, size: 16, color: AppColors.gold);
                    } else {
                      return Icon(Icons.star_border,
                          size: 16, color: AppColors.gold);
                    }
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${buyer.reliabilityScore.toStringAsFixed(1)} (${buyer.totalTransactions} transactions)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildBuyerStat(
                      '${buyer.successRate.toStringAsFixed(0)}%',
                      'Success Rate',
                    ),
                  ),
                  Expanded(
                    child: _buildBuyerStat(
                      '$activeDemands',
                      'Active Demands',
                    ),
                  ),
                  Expanded(
                    child: _buildBuyerStat(
                      buyer.location,
                      'Location',
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBuyerStat(String value, String label) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyerDetailsModal(Buyer buyer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      buyer.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                buyer.businessName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (buyer.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 18, color: AppColors.primary),
                            ],
                          ],
                        ),
                        Text(buyer.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${buyer.reliabilityScore.toStringAsFixed(1)} ★', 'Reliability'),
                  _buildStatItem('${buyer.totalTransactions}', 'Transactions'),
                  _buildStatItem('${buyer.successfulTransactions}', 'Completed'),
                ],
              ),
              const Divider(height: 28),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                title: const Text('Location'),
                subtitle: Text(buyer.location),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                title: const Text('Phone Number'),
                subtitle: Text(buyer.phoneNumber),
                trailing: FilledButton.tonalIcon(
                  onPressed: () async {
                    final cleanPhone = buyer.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
                    final uri = Uri.parse('tel:$cleanPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
