import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/produce_model.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'edit_produce_screen.dart';

/// Produce Detail Screen with view, edit, and delete functionality
class ProduceDetailScreen extends StatefulWidget {
  final ProduceModel produce;

  const ProduceDetailScreen({
    super.key,
    required this.produce,
  });

  @override
  State<ProduceDetailScreen> createState() => _ProduceDetailScreenState();
}

class _ProduceDetailScreenState extends State<ProduceDetailScreen> {
  late ProduceModel _produce;

  @override
  void initState() {
    super.initState();
    _produce = widget.produce;
  }

  Color _getStatusColor() {
    switch (_produce.status) {
      case 'available':
        return AppColors.success;
      case 'sold':
        return AppColors.info;
      case 'reserved':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (_produce.status) {
      case 'available':
        return 'Available';
      case 'sold':
        return 'Sold';
      case 'reserved':
        return 'Reserved';
      default:
        return _produce.status;
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    try {
      await context.read<ProduceProvider>().updateProduceStatus(
            _produce.id,
            newStatus,
          );

      if (mounted) {
        setState(() {
          _produce = _produce.copyWith(status: newStatus);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_getStatusLabel()}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showStatusDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('available', 'Available', Icons.check_circle),
            _buildStatusOption('reserved', 'Reserved', Icons.bookmark),
            _buildStatusOption('sold', 'Sold', Icons.shopping_cart),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null && result != _produce.status) {
      _changeStatus(result);
    }
  }

  Widget _buildStatusOption(String value, String label, IconData icon) {
    final isSelected = _produce.status == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<void> _deleteProduce() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Produce'),
        content: const Text(
          'Are you sure you want to delete this produce listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ProduceProvider>().deleteProduce(_produce.id);
        
        if (mounted) {
          Navigator.pop(context, true); // Return to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Produce deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete produce: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'Produce Details',
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
                  builder: (context) => EditProduceScreen(produce: _produce),
                ),
              );
              if (result is ProduceModel) {
                setState(() {
                  _produce = result;
                });
              }
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteProduce,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (_produce.imageUrl != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_produce.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.agriculture_outlined,
                  size: 100,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _produce.cropName,
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showStatusDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getStatusLabel(),
                                style: AppTypography.labelMedium.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: statusColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _produce.cropType,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Card
                  _buildInfoCard(
                    'Price Information',
                    Icons.attach_money,
                    AppColors.accent,
                    [
                      _buildInfoRow(
                        'Price per ${_produce.unit}',
                        'ETB ${_produce.pricePerUnit.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'Available Quantity',
                        '${_produce.quantity} ${_produce.unit}',
                      ),
                      _buildInfoRow(
                        'Total Value',
                        'ETB ${(_produce.quantity * _produce.pricePerUnit).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quality & Details Card
                  _buildInfoCard(
                    'Quality & Details',
                    Icons.grade_outlined,
                    AppColors.success,
                    [
                      if (_produce.qualityGrade != null)
                        _buildInfoRow('Quality Grade', _produce.qualityGrade!),
                      _buildInfoRow(
                        'Organic',
                        _produce.isOrganic ? 'Yes' : 'No',
                      ),
                      if (_produce.harvestDate != null)
                        _buildInfoRow(
                          'Harvest Date',
                          dateFormat.format(_produce.harvestDate!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Card
                  _buildInfoCard(
                    'Location',
                    Icons.location_on_outlined,
                    AppColors.info,
                    [
                      _buildInfoRow('Location', _produce.location),
                      _buildInfoRow('Farmer', _produce.farmerName),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Description',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _produce.description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timestamps Card
                  _buildInfoCard(
                    'Timeline',
                    Icons.calendar_today_outlined,
                    AppColors.textSecondary,
                    [
                      _buildInfoRow(
                        'Listed on',
                        dateFormat.format(_produce.createdAt),
                      ),
                      _buildInfoRow(
                        'Last updated',
                        dateFormat.format(_produce.updatedAt ?? _produce.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProduceScreen(produce: _produce),
            ),
          );
          if (result is ProduceModel) {
            setState(() {
              _produce = result;
            });
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Produce'),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
