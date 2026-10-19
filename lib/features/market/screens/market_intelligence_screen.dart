import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/market_model.dart';
import '../../../core/models/price_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/services/mock_data_service.dart';
import '../widgets/price_list_card.dart';
import '../widgets/where_should_i_sell_calculator.dart';

/// Market Intelligence Screen
/// Shows current prices by crop and grade across Jimma Zone markets
class MarketIntelligenceScreen extends StatefulWidget {
  const MarketIntelligenceScreen({super.key});

  @override
  State<MarketIntelligenceScreen> createState() =>
      _MarketIntelligenceScreenState();
}

class _MarketIntelligenceScreenState extends State<MarketIntelligenceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Market> _markets = [];
  List<CropPrice> _allPrices = [];
  CropType _selectedCrop = CropType.coffee;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _markets = MockDataService.getAllMarkets();
      _allPrices = MockDataService.getCurrentPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.marketIntelligence),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnPrimary,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          labelStyle: AppTypography.labelLarge,
          tabs: const [
            Tab(text: 'Price Lists'),
            Tab(text: 'Where Should I Sell?'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPriceListsTab(localizations),
          _buildCalculatorTab(),
        ],
      ),
    );
  }

  Widget _buildPriceListsTab(AppLocalizations localizations) {
    return Column(
      children: [
        // Crop Filter
        _buildCropFilter(),

        // Price Lists
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _markets.length,
            itemBuilder: (context, index) {
              final market = _markets[index];
              final marketPrices = _allPrices
                  .where((p) =>
                      p.marketId == market.id && p.cropType == _selectedCrop)
                  .toList();

              if (marketPrices.isEmpty) return const SizedBox.shrink();

              return PriceListCard(
                market: market,
                prices: marketPrices,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCropFilter() {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: CropType.values.take(5).map((crop) {
          final isSelected = _selectedCrop == crop;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(crop.afaanOromoo),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCrop = crop);
              },
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return const WhereShouldISellCalculator();
  }
}
