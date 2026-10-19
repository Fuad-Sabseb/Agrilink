import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/models/transport_request_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Transport Request Detail Screen
class TransportRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const TransportRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<TransportRequestDetailScreen> createState() =>
      _TransportRequestDetailScreenState();
}

class _TransportRequestDetailScreenState
    extends State<TransportRequestDetailScreen> {
  TransportRequest? _request;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = context
        .read<TransportProvider>()
        .farmerRequests
        .where((r) => r.id == widget.requestId)
        .firstOrNull;

    setState(() {
      _request = request;
      _isLoading = false;
      if (request == null) {
        _error = 'Request not found';
      }
    });
  }

  Future<void> _cancelRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
            'Are you sure you want to cancel this transport request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Note: Add cancelTransportRequest method to TransportProvider
    // For now, just show message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancel functionality to be implemented'),
        ),
      );
    }
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
          'Request Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_request != null && _request!.isPending)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelRequest,
              tooltip: 'Cancel Request',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load request',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRequest,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_request == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildDetailsCard(),
          const SizedBox(height: 16),
          _buildLocationsCard(),
          if (_request!.specialInstructions != null) ...[
            const SizedBox(height: 16),
            _buildInstructionsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _request!.status.displayName,
                style: AppTypography.titleMedium.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Request ID: ${_request!.id.substring(0, 8)}...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Details',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Crop Type', _request!.cropType.name.toUpperCase()),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Quantity', '${_request!.quantityKg.toStringAsFixed(0)} kg'),
            const SizedBox(height: 12),
            _buildInfoRow('Pickup Date',
                '${_request!.requestedPickupDate.day}/${_request!.requestedPickupDate.month}/${_request!.requestedPickupDate.year}'),
            const SizedBox(height: 12),
            _buildInfoRow('Refrigeration',
                _request!.requiresRefrigeration ? 'Required' : 'Not required'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locations',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                      Text(_request!.pickupLocation,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.pin_drop, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                      Text(_request!.deliveryLocation,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Special Instructions',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _request!.specialInstructions!,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_request!.status) {
      case RequestStatus.pending:
        return AppColors.warning;
      case RequestStatus.matched:
        return AppColors.info;
      case RequestStatus.accepted:
        return AppColors.success;
      case RequestStatus.cancelled:
        return AppColors.textSecondary;
      case RequestStatus.expired:
        return AppColors.error;
    }
  }
}
