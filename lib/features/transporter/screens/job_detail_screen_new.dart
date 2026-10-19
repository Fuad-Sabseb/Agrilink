import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trip_model.dart';
import '../../../core/repositories/transport_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'package:intl/intl.dart';

/// Job Detail Screen with Accept Button
/// Shows complete job information and handles job acceptance with race condition handling
class JobDetailScreenNew extends StatefulWidget {
  final Trip job;

  const JobDetailScreenNew({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailScreenNew> createState() => _JobDetailScreenNewState();
}

class _JobDetailScreenNewState extends State<JobDetailScreenNew> {
  bool _isAccepting = false;
  Trip? _currentJob;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.job;
  }

  Future<void> _acceptJob() async {
    final authProvider = context.read<AuthProvider>();
    final transporterId = authProvider.userId;

    if (transporterId == null) {
      _showError('Authentication required');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Job'),
        content: Text(
          'Do you want to accept this delivery job?\n\n'
          'Route: ${_currentJob!.pickupLocation} → ${_currentJob!.deliveryLocation}\n'
          'Earnings: ${_currentJob!.totalCost.toStringAsFixed(2)} ETB',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Accept Job'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isAccepting = true);

    try {
      final repository = TransportRepository();
      final result = await repository.acceptJob(
        jobId: _currentJob!.id,
        transporterId: transporterId,
        vehicleId: 'vehicle_default', // Should come from vehicle selection
        estimatedPickupTime: DateTime.now().add(const Duration(hours: 1)),
      );

      if (!mounted) return;

      if (result.success && result.job != null) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job accepted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        setState(() {
          _currentJob = result.job;
        });

        // Navigate to active delivery screen
        Navigator.pushReplacementNamed(
          context,
          '/transporter/active-delivery',
          arguments: result.job,
        );
      } else if (result.isRaceCondition) {
        // Job already accepted by another transporter
        _showRaceConditionDialog(
          result.acceptedBy ?? 'another transporter',
          result.acceptedAt ?? DateTime.now(),
        );
      } else if (result.isNotFound) {
        // Job no longer exists
        _showJobNotFoundDialog();
      } else {
        // Other error
        _showError(result.error ?? 'Failed to accept job');
      }
    } catch (e) {
      if (mounted) {
        _showError('Unexpected error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  void _showRaceConditionDialog(String acceptedBy, DateTime acceptedAt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Job Already Accepted'),
          ],
        ),
        content: Text(
          'Sorry, this job was just accepted by $acceptedBy at ${DateFormat('HH:mm').format(acceptedAt)}.\n\n'
          'The job is no longer available. Please check other available jobs.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to job list
            },
            child: const Text('View Other Jobs'),
          ),
        ],
      ),
    );
  }

  void _showJobNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Job Not Available'),
          ],
        ),
        content: const Text(
          'This job is no longer available. It may have been cancelled or removed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to job list
            },
            child: const Text('OK'),
          ),
        ],
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
    final isAvailable = _currentJob!.status == TripStatus.matched;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Job Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_currentJob!.totalCost.toStringAsFixed(2)} ETB',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated Earnings',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Job Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRouteStep(
                            icon: Icons.location_on,
                            label: 'Pickup',
                            value: _currentJob!.pickupLocation,
                            isStart: true,
                          ),
                          _buildRouteLine(),
                          _buildRouteStep(
                            icon: Icons.flag,
                            label: 'Delivery',
                            value: _currentJob!.deliveryLocation,
                            isEnd: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cargo Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cargo Details',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.agriculture,
                            'Crop Type',
                            _currentJob!.cropType.name.toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.scale,
                            'Quantity',
                            '${_currentJob!.quantityQuintals.toStringAsFixed(1)} quintals',
                          ),
                          if (_currentJob!.scheduledPickupTime != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.schedule,
                              'Scheduled Pickup',
                              DateFormat('MMM dd, yyyy HH:mm')
                                  .format(_currentJob!.scheduledPickupTime!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (!isAvailable) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This job is no longer available',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isAvailable
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _acceptJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isAccepting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Accept Job',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRouteStep({
    required IconData icon,
    required String label,
    required String value,
    bool isStart = false,
    bool isEnd = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isStart ? AppColors.success : AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 11, top: 8, bottom: 8),
      child: Container(
        width: 2,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.success.withValues(alpha: 0.5),
              AppColors.primary.withValues(alpha: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
