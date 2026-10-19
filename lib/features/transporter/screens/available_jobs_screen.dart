import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/transport_request_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../widgets/job_card.dart';

/// Available Jobs Screen - Browse and accept transport jobs
class AvailableJobsScreen extends StatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  String _sortBy = 'date';
  CropType? _filterCropType;
  bool? _filterRefrigeration;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    await transportProvider.loadPendingTransportRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'distance', child: Text('Sort by Distance')),
              const PopupMenuItem(value: 'earnings', child: Text('Sort by Earnings')),
            ],
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              _filterCropType != null || _filterRefrigeration != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadJobs,
        child: Consumer<TransportProvider>(
          builder: (context, transportProvider, child) {
            if (transportProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (transportProvider.error != null) {
              return _buildErrorState(transportProvider.error!);
            }

            var jobs = transportProvider.filteredRequests
                .where((j) => j.status == RequestStatus.pending)
                .toList();

            // Apply filters
            if (_filterCropType != null) {
              jobs = jobs.where((j) => j.cropType == _filterCropType).toList();
            }
            if (_filterRefrigeration != null) {
              jobs = jobs.where((j) => j.requiresRefrigeration == _filterRefrigeration).toList();
            }

            // Apply sorting
            _sortJobs(jobs);

            if (jobs.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return JobCard(
                  job: job,
                  onTap: () => _showJobDetails(context, job),
                  onAccept: () => _acceptJob(context, job),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _sortJobs(List<TransportRequest> jobs) {
    switch (_sortBy) {
      case 'date':
        jobs.sort((a, b) => a.requestedPickupDate.compareTo(b.requestedPickupDate));
        break;
      case 'distance':
        // Mock distance sorting
        jobs.sort((a, b) => a.quantityKg.compareTo(b.quantityKg));
        break;
      case 'earnings':
        jobs.sort((a, b) => b.quantityKg.compareTo(a.quantityKg));
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Jobs'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crop Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterCropType == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _filterCropType = null;
                        });
                      },
                    ),
                    ...CropType.values.map((type) {
                      return FilterChip(
                        label: Text(type.toString().split('.').last.toUpperCase()),
                        selected: _filterCropType == type,
                        onSelected: (selected) {
                          setDialogState(() {
                            _filterCropType = selected ? type : null;
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  value: _filterRefrigeration ?? false,
                  onChanged: (value) {
                    setDialogState(() {
                      _filterRefrigeration = value;
                    });
                  },
                  title: const Text('Refrigerated Only'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterCropType = null;
                _filterRefrigeration = null;
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(BuildContext context, TransportRequest job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Job Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 24),
                JobCard(
                  job: job,
                  onAccept: () {
                    Navigator.pop(context);
                    _acceptJob(context, job);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _acceptJob(BuildContext context, TransportRequest job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Accept Job', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Do you want to accept transport job for ${job.cropType.displayName}?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = this.context.read<AuthProvider>();
    final transportProvider = this.context.read<TransportProvider>();
    final transporterId = authProvider.user?.id ?? 'transporter_001';
    final vehicleId = authProvider.user?.roleData?['vehicleId'] as String? ?? 'vehicle_001';

    final result = await transportProvider.acceptJobWithRaceCheck(
      jobId: job.id,
      transporterId: transporterId,
      vehicleId: vehicleId,
      estimatedPickupTime: DateTime.now().add(const Duration(hours: 2)),
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Job for ${job.cropType.displayName} accepted successfully! 🚛'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await transportProvider.loadPendingTransportRequests();
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to accept job'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 80, color: AppColors.border),
          const SizedBox(height: 24),
          Text(
            'No Jobs Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check back later for new transport jobs',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Jobs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
