import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/inspection_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/inspection_model.dart';
import 'create_inspection_screen.dart';
import 'inspection_details_screen.dart';

/// Enhanced Bureau Dashboard Screen with InspectionProvider Integration
/// Requirements: 1.1-1.10, 2.1-2.10
class BureauDashboardEnhancedScreen extends StatefulWidget {
  const BureauDashboardEnhancedScreen({super.key});

  @override
  State<BureauDashboardEnhancedScreen> createState() => _BureauDashboardEnhancedScreenState();
}

class _BureauDashboardEnhancedScreenState extends State<BureauDashboardEnhancedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filters
  InspectionStatus? _statusFilter;
  InspectionType? _typeFilter;
  String? _woredaFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load inspections on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().fetchInspections();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bureau Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InspectionProvider>().fetchInspections();
            },
          ),
          Consumer<InspectionProvider>(
            builder: (context, provider, _) {
              if (provider.pendingOperationsCount > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cloud_upload),
                      onPressed: () async {
                        final count = await provider.syncOfflineOperations();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Synced $count operations'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${provider.pendingOperationsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Inspections'),
          ],
        ),
      ),
      body: Consumer<InspectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.inspections.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildInspectionsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateInspectionScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Inspection', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'Error loading data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<InspectionProvider>().fetchInspections();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== OVERVIEW TAB ====================

  Widget _buildOverviewTab(InspectionProvider provider) {
    final authProvider = context.watch<AuthProvider>();
    
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchInspections();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfficerCard(authProvider),
            const SizedBox(height: 16),
            _buildStatisticsCards(provider),
            const SizedBox(height: 16),
            _buildRecentInspections(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerCard(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              user.fullName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.woreda ?? 'Multiple Woredas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(InspectionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${provider.totalInspections}',
            Icons.assignment_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'In Progress',
            '${provider.inProgressCount}',
            Icons.pending_actions,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${provider.completedCount}',
            Icons.check_circle_outline,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInspections(InspectionProvider provider) {
    if (provider.inspections.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentInspections = provider.inspections.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Inspections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentInspections.map((inspection) => _buildInspectionCard(inspection)),
      ],
    );
  }

  // ==================== INSPECTIONS TAB ====================

  Widget _buildInspectionsTab(InspectionProvider provider) {
    final filteredInspections = _applyFilters(provider);

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.fetchInspections();
            },
            child: filteredInspections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredInspections.length,
                    itemBuilder: (context, index) {
                      return _buildInspectionCard(filteredInspections[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search inspections...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All Status',
                  _statusFilter == null,
                  () => setState(() => _statusFilter = null),
                ),
                const SizedBox(width: 8),
                ...InspectionStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                       status.displayName,
                      _statusFilter == status,
                      () => setState(() => _statusFilter = status),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 80, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'No inspections found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first inspection to get started',
            style: TextStyle(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InspectionDetailsScreen(
              inspectionId: inspection.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inspection.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(inspection.type),
                    color: _getStatusColor(inspection.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inspection.type.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inspection.cooperativeName ?? inspection.farmName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inspection.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    inspection.status.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  inspection.woredaName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(inspection.checkInTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (inspection.issueCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Text(
                      '${inspection.issueCount} ${inspection.issueCount == 1 ? 'issue' : 'issues'} found',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
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

  // Helper methods

  List<Inspection> _applyFilters(InspectionProvider provider) {
    var inspections = provider.inspections;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      inspections = provider.searchInspections(_searchQuery);
    }

    // Apply status filter
    if (_statusFilter != null) {
      inspections = inspections.where((i) => i.status == _statusFilter).toList();
    }

    // Apply type filter
    if (_typeFilter != null) {
      inspections = inspections.where((i) => i.type == _typeFilter).toList();
    }

    // Apply woreda filter
    if (_woredaFilter != null) {
      inspections = inspections.where((i) => i.woredaId == _woredaFilter).toList();
    }

    return inspections;
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.scheduled:
        return AppColors.tertiary;
      case InspectionStatus.inProgress:
        return AppColors.secondary;
      case InspectionStatus.completed:
        return AppColors.success;
      case InspectionStatus.cancelled:
        return AppColors.disabled;
    }
  }

  IconData _getTypeIcon(InspectionType type) {
    switch (type) {
      case InspectionType.routine:
        return Icons.event_repeat;
      case InspectionType.followUp:
        return Icons.follow_the_signs;
      case InspectionType.complaint:
        return Icons.report_problem;
      case InspectionType.preHarvest:
        return Icons.eco;
      case InspectionType.postHarvest:
        return Icons.inventory;
      case InspectionType.emergency:
        return Icons.emergency;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
