import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/buyer_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/buyer_model.dart';
import 'edit_buyer_profile_screen.dart';

/// Buyer Profile Screen
/// Displays buyer information, statistics, and reliability score
class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final _sessionService = SessionService();
  bool _isInitialized = false;
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please login to view profile'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    final provider = context.read<BuyerProvider>();
    await provider.loadBuyerProfile(buyerId);
    
    // Load statistics (non-blocking)
    _statistics = await provider.getBuyerStatistics(buyerId);

    setState(() => _isInitialized = true);
  }

  Future<void> _refreshProfile() async {
    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) return;

    final provider = context.read<BuyerProvider>();
    await provider.loadBuyerProfile(buyerId, forceRefresh: true);
    
    // Refresh statistics
    _statistics = await provider.getBuyerStatistics(buyerId);
    setState(() {});
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
          'My Profile',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditBuyerProfileScreen(),
                ),
              );
              if (result == true) {
                _refreshProfile();
              }
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: !_isInitialized
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshProfile,
              color: AppColors.primary,
              child: _buildContent(),
            ),
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
            'Loading profile...',
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
    final buyer = provider.buyer;

    if (provider.profileError != null) {
      return _buildErrorState(provider.profileError!);
    }

    if (buyer == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(buyer),
          const SizedBox(height: 16),
          _buildReliabilityCard(buyer),
          const SizedBox(height: 16),
          _buildStatisticsCard(buyer),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Buyer buyer) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.business,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    if (buyer.isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              buyer.name,
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (buyer.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        buyer.buyerType.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.business, 'Business', buyer.businessName),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Phone', buyer.phoneNumber),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Location', buyer.location),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Registered',
              _formatDate(buyer.registeredAt),
            ),
            if (buyer.lastActiveAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.access_time,
                'Last Active',
                _formatDate(buyer.lastActiveAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReliabilityCard(Buyer buyer) {
    final tier = buyer.reliabilityTier;
    final tierColor = _getReliabilityColor(tier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reliability Score',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  buyer.reliabilityScore.toStringAsFixed(1),
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ 5.0',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tier.displayName,
                    style: AppTypography.labelMedium.copyWith(
                      color: tierColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStarRating(buyer.reliabilityScore),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(Buyer buyer) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transaction Statistics',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Orders',
                    buyer.totalTransactions.toString(),
                    Icons.shopping_cart_outlined,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Successful',
                    buyer.successfulTransactions.toString(),
                    Icons.check_circle_outline,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSuccessRateBar(buyer.successRate),
            const SizedBox(height: 8),
            Text(
              'Success Rate: ${buyer.successRate.toStringAsFixed(1)}%',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_statistics != null && _statistics!.isNotEmpty) ...[
              const Divider(height: 32),
              ..._buildAdditionalStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateBar(double successRate) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: successRate / 100,
        minHeight: 12,
        backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(
          successRate >= 80 ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }

  List<Widget> _buildAdditionalStats() {
    final stats = <Widget>[];
    
    if (_statistics!.containsKey('totalSpent')) {
      stats.add(_buildInfoRow(
        Icons.attach_money,
        'Total Spent',
        'ETB ${_statistics!['totalSpent']}',
      ));
      stats.add(const SizedBox(height: 12));
    }
    
    if (_statistics!.containsKey('activeDemands')) {
      stats.add(_buildInfoRow(
        Icons.trending_up,
        'Active Demands',
        _statistics!['activeDemands'].toString(),
      ));
      stats.add(const SizedBox(height: 12));
    }
    
    if (_statistics!.containsKey('avgRating')) {
      stats.add(_buildInfoRow(
        Icons.star,
        'Avg Rating',
        _statistics!['avgRating'].toStringAsFixed(1),
      ));
    }
    
    return stats;
  }

  Widget _buildStarRating(double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (score >= starValue) {
          return Icon(Icons.star, color: AppColors.accent, size: 32);
        } else if (score >= starValue - 0.5) {
          return Icon(Icons.star_half, color: AppColors.accent, size: 32);
        } else {
          return Icon(Icons.star_border, color: AppColors.accent, size: 32);
        }
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getReliabilityColor(ReliabilityTier tier) {
    switch (tier) {
      case ReliabilityTier.excellent:
        return AppColors.primary;
      case ReliabilityTier.veryGood:
        return AppColors.success;
      case ReliabilityTier.good:
        return AppColors.accent;
      case ReliabilityTier.average:
        return AppColors.warning;
      case ReliabilityTier.belowAverage:
        return AppColors.secondary;
      case ReliabilityTier.poor:
        return AppColors.error;
    }
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
              'Failed to load profile',
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
              onPressed: _refreshProfile,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Profile not found',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshProfile,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
