import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/sell_recommendation_model.dart';

/// Recommendation Card
/// Shows detailed breakdown of net revenue calculation
/// Net Revenue = (Market Price * Quantity) - Transport Cost - Checkpoint Fees
class RecommendationCard extends StatelessWidget {
  final SellRecommendation recommendation;
  final int rank;
  final bool isBest;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
    this.isBest = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isBest ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBest ? AppColors.primary : Colors.transparent,
          width: isBest ? 2 : 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(currencyFormat),

          const Divider(height: 1),

          // Breakdown
          _buildBreakdown(currencyFormat),

          // Net Revenue (Bottom Bar)
          _buildNetRevenue(currencyFormat),
        ],
      ),
    );
  }

  Widget _buildHeader(NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isBest ? AppColors.primaryGradient : null,
        color: isBest ? null : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isBest
                  ? AppColors.gold
                  : AppColors.textSecondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppTypography.labelMedium.copyWith(
                  color: isBest ? AppColors.textOnDark : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Market Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.market.name,
                  style: AppTypography.titleLarge.copyWith(
                    color: isBest ? AppColors.textOnPrimary : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: isBest
                          ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recommendation.distanceKm.toInt()} km',
                      style: AppTypography.bodySmall.copyWith(
                        color: isBest
                            ? AppColors.textOnPrimary.withValues(alpha: 0.9)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Best Badge
          if (isBest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.textOnDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BEST',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gross Revenue
          _buildBreakdownRow(
            icon: Icons.add_circle_outline,
            iconColor: AppColors.success,
            label: 'Gross Revenue',
            sublabel:
                '${recommendation.pricePerKg.toStringAsFixed(2)} × ${recommendation.quantityKg.toInt()} kg',
            value: currencyFormat.format(recommendation.grossRevenue),
            valueColor: AppColors.success,
          ),

          const SizedBox(height: 12),

          // Transport Cost
          _buildBreakdownRow(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.warning,
            label: 'Transport Cost',
            sublabel: '${recommendation.distanceKm.toInt()} km trip',
            value: '- ${currencyFormat.format(recommendation.transportCost)}',
            valueColor: AppColors.warning,
          ),

          const SizedBox(height: 12),

          // Checkpoint Fees
          _buildBreakdownRow(
            icon: Icons.gavel_outlined,
            iconColor: AppColors.info,
            label: 'Checkpoint Fees',
            sublabel: 'Transit fees',
            value: '- ${currencyFormat.format(recommendation.checkpointFees)}',
            valueColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sublabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildNetRevenue(NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: recommendation.isProfitable
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            recommendation.isProfitable
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: recommendation.isProfitable
                ? AppColors.primary
                : AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Revenue',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${recommendation.profitMarginPercent.toStringAsFixed(1)}% profit margin',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(recommendation.netRevenue),
                style: AppTypography.headlineSmall.copyWith(
                  color: recommendation.isProfitable
                      ? AppColors.primary
                      : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${recommendation.netRevenuePerKg.toStringAsFixed(2)} ETB/kg',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
