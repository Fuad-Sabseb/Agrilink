import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/market_model.dart';
import '../../../core/models/price_model.dart';
import '../../../core/models/crop_plot_model.dart';

/// Price List Card
/// Displays prices for a specific market
class PriceListCard extends StatelessWidget {
  final Market market;
  final List<CropPrice> prices;

  const PriceListCard({
    super.key,
    required this.market,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Header
          _buildMarketHeader(),

          const Divider(height: 1),

          // Price List
          ...prices.map((price) => _buildPriceRow(price)),
        ],
      ),
    );
  }

  Widget _buildMarketHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Market Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: market.isPrimary
                  ? AppColors.primaryVeryLight
                  : AppColors.goldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              market.isPrimary ? Icons.location_city : Icons.store,
              color: market.isPrimary ? AppColors.primary : AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Market Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market.name,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${market.distanceFromJimmaKm.toInt()} km from Jimma',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Primary Badge
          if (market.isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Primary',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(CropPrice price) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: 2,
    );

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Grade Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getGradeColor(price.grade).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getGradeColor(price.grade),
                  width: 1,
                ),
              ),
              child: Text(
                price.grade.displayName,
                style: AppTypography.labelSmall.copyWith(
                  color: _getGradeColor(price.grade),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currencyFormat.format(price.pricePerKg)}/kg',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (price.priceChangePercent != null)
                    Row(
                      children: [
                        Icon(
                          price.isIncreasing
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: price.isIncreasing
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${price.priceChangePercent!.abs().toStringAsFixed(1)}%',
                          style: AppTypography.caption.copyWith(
                            color: price.isIncreasing
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Freshness Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: price.isFresh
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    price.isFresh ? 'Fresh' : '${price.ageInHours}h ago',
                    style: AppTypography.caption.copyWith(
                      color: price.isFresh ? AppColors.success : AppColors.warning,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.premium:
        return AppColors.gold;
      case QualityGrade.grade1:
        return AppColors.primary;
      case QualityGrade.grade2:
        return AppColors.info;
      case QualityGrade.grade3:
        return AppColors.warning;
      case QualityGrade.standard:
        return AppColors.textSecondary;
    }
  }
}
