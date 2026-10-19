import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/farmer_model.dart';

/// Farmer Card Widget
/// Compact display of a farmer profile for marketplace browsing
/// Shows farmer name, location, cooperative, and member duration
class FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback onTap;
  final double? rating;
  final int? totalProduceListings;

  const FarmerCard({
    super.key,
    required this.farmer,
    required this.onTap,
    this.rating,
    this.totalProduceListings,
  });

  String _getMemberDuration() {
    final duration = DateTime.now().difference(farmer.registeredAt);
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return 'New member';
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: 14,
            color: AppColors.gold,
          );
        } else if (index < rating && rating % 1 >= 0.5) {
          return const Icon(
            Icons.star_half,
            size: 14,
            color: AppColors.gold,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: 14,
            color: AppColors.textTertiary.withOpacity(0.5),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Farmer name and rating
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryVeryLight,
                    child: Text(
                      farmer.name.isNotEmpty
                          ? farmer.name[0].toUpperCase()
                          : 'F',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (rating != null) ...[
                          Row(
                            children: [
                              _buildRatingStars(rating!),
                              const SizedBox(width: 6),
                              Text(
                                rating!.toStringAsFixed(1),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Verified badge or arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${farmer.woreda}, ${farmer.kebele}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Cooperative (if available)
              if (farmer.cooperativeName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        farmer.cooperativeName!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Member since and produce count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Member duration
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Member ${_getMemberDuration()}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  // Produce listings count
                  if (totalProduceListings != null && totalProduceListings! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryVeryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalProduceListings ${totalProduceListings! == 1 ? 'listing' : 'listings'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              // Number of farms
              if (farmer.farmIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.agriculture_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${farmer.farmIds.length} ${farmer.farmIds.length == 1 ? 'farm' : 'farms'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
