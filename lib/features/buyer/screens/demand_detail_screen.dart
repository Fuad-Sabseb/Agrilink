import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/buyer_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/demand_model.dart';
import '../../../core/models/crop_plot_model.dart';

/// Demand Detail Screen
/// View, edit, pause, resume, fill, or delete a demand
class DemandDetailScreen extends StatefulWidget {
  final Demand demand;

  const DemandDetailScreen({
    super.key,
    required this.demand,
  });

  @override
  State<DemandDetailScreen> createState() => _DemandDetailScreenState();
}

class _DemandDetailScreenState extends State<DemandDetailScreen> {
  late Demand _currentDemand;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentDemand = widget.demand;
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    final provider = context.read<BuyerProvider>();
    await provider.incrementDemandView(_currentDemand.id);
  }

  Future<void> _refreshDemand() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<BuyerProvider>();
    final updated = await provider.getDemand(_currentDemand.id);
    
    if (updated != null) {
      setState(() {
        _currentDemand = updated;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pauseDemand() async {
    final confirmed = await _showConfirmDialog(
      'Pause Demand',
      'Are you sure you want to pause this demand? Farmers will not see it while paused.',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    final provider = context.read<BuyerProvider>();
    final success = await provider.pauseDemand(_currentDemand.id);
    
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        _showSuccess('Demand paused successfully');
        await _refreshDemand();
      } else {
        _showError('Failed to pause demand');
      }
    }
  }

  Future<void> _resumeDemand() async {
    final confirmed = await _showConfirmDialog(
      'Resume Demand',
      'Are you sure you want to resume this demand? It will be visible to farmers again.',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    final provider = context.read<BuyerProvider>();
    final success = await provider.resumeDemand(_currentDemand.id);
    
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        _showSuccess('Demand resumed successfully');
        await _refreshDemand();
      } else {
        _showError('Failed to resume demand');
      }
    }
  }

  Future<void> _fillDemand() async {
    final confirmed = await _showConfirmDialog(
      'Mark as Filled',
      'Are you sure you want to mark this demand as filled? This action cannot be undone.',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    final provider = context.read<BuyerProvider>();
    final success = await provider.fillDemand(_currentDemand.id);
    
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        _showSuccess('Demand marked as filled');
        await _refreshDemand();
      } else {
        _showError('Failed to mark demand as filled');
      }
    }
  }

  Future<void> _deleteDemand() async {
    final confirmed = await _showConfirmDialog(
      'Delete Demand',
      'Are you sure you want to delete this demand? This action cannot be undone.',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    final provider = context.read<BuyerProvider>();
    final success = await provider.deleteDemand(_currentDemand.id);
    
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        _showSuccess('Demand deleted successfully');
        Navigator.pop(context, true);
      } else {
        _showError('Failed to delete demand');
      }
    }
  }

  void _shareDemand() {
    final text = '''
🛒 Buying Request

Crop: ${_getCropDisplayName(_currentDemand.cropType)}
Quality: ${_getGradeDisplayName(_currentDemand.preferredGrade)}
Quantity: ${_currentDemand.minimumQuantityKg.toInt()}-${_currentDemand.maximumQuantityKg.toInt()} kg
Price: ETB ${_currentDemand.priceOfferPerKg}/kg
Location: ${_currentDemand.pickupLocation}
${_currentDemand.transportProvided ? '🚚 Transport provided' : ''}
Expires: ${_formatDate(_currentDemand.expiresAt)}

${_currentDemand.additionalNotes ?? ''}
''';

    Clipboard.setData(ClipboardData(text: text));
    _showSuccess('Demand details copied to clipboard');
  }

  Future<bool?> _showConfirmDialog(
    String title,
    String message, {
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(isDestructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentDemand.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'Demand Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDemand,
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'pause':
                  _pauseDemand();
                  break;
                case 'resume':
                  _resumeDemand();
                  break;
                case 'fill':
                  _fillDemand();
                  break;
                case 'delete':
                  _deleteDemand();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_currentDemand.status == BuyingStatus.buyingNow)
                const PopupMenuItem(
                  value: 'pause',
                  child: Row(
                    children: [
                      Icon(Icons.pause_circle_outline),
                      SizedBox(width: 12),
                      Text('Pause'),
                    ],
                  ),
                ),
              if (_currentDemand.status == BuyingStatus.paused)
                const PopupMenuItem(
                  value: 'resume',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline),
                      SizedBox(width: 12),
                      Text('Resume'),
                    ],
                  ),
                ),
              if (_currentDemand.status != BuyingStatus.filled)
                const PopupMenuItem(
                  value: 'fill',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 12),
                      Text('Mark as Filled'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshDemand,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(statusColor),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                    const SizedBox(height: 16),
                    _buildPricingCard(),
                    const SizedBox(height: 16),
                    _buildLocationCard(),
                    if (_currentDemand.additionalNotes != null) ...[
                      const SizedBox(height: 16),
                      _buildNotesCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildStatsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(Color statusColor) {
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
                Expanded(
                  child: Text(
                    _getCropDisplayName(_currentDemand.cropType),
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentDemand.status.showPulse)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                      Text(
                        _currentDemand.status.displayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_currentDemand.isUrgent) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Expires in ${_currentDemand.hoursUntilExpiry} hours',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Preferred Grade',
              _getGradeDisplayName(_currentDemand.preferredGrade),
              Icons.star,
            ),
            if (_currentDemand.acceptedGrades != null &&
                _currentDemand.acceptedGrades!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Accepted Grades',
                _currentDemand.acceptedGrades!
                    .map((g) => _getGradeDisplayName(g))
                    .join(', '),
                Icons.checklist,
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              'Posted',
              '${_currentDemand.daysSincePosted} days ago',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Expires',
              _formatDate(_currentDemand.expiresAt),
              Icons.event,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Transport',
              _currentDemand.transportProvided ? 'Provided' : 'Not provided',
              Icons.local_shipping,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Quantity',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Min Quantity',
                    '${_currentDemand.minimumQuantityKg.toInt()} kg',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'Max Quantity',
                    '${_currentDemand.maximumQuantityKg.toInt()} kg',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Offer',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ETB ${_currentDemand.priceOfferPerKg}/kg',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Value (Min)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'ETB ${_currentDemand.totalOfferValueMin.toStringAsFixed(2)}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Value (Max)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'ETB ${_currentDemand.totalOfferValueMax.toStringAsFixed(2)}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Location',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentDemand.pickupLocation,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentDemand.additionalNotes!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentDemand.viewCount}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Views',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.reply,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentDemand.responseCount}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Responses',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
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

  Color _getStatusColor(BuyingStatus status) {
    switch (status) {
      case BuyingStatus.buyingNow:
        return AppColors.success;
      case BuyingStatus.paused:
        return AppColors.warning;
      case BuyingStatus.filled:
        return AppColors.textSecondary;
      case BuyingStatus.expired:
        return AppColors.error;
    }
  }

  String _getCropDisplayName(CropType crop) {
    return crop.name[0].toUpperCase() + crop.name.substring(1);
  }

  String _getGradeDisplayName(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.premium:
        return 'Premium';
      case QualityGrade.grade1:
        return 'Grade 1';
      case QualityGrade.grade2:
        return 'Grade 2';
      case QualityGrade.grade3:
        return 'Grade 3';
      case QualityGrade.standard:
        return 'Standard';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
