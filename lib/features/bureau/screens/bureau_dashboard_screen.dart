import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/bureau_officer_model.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/models/aggregate_report_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/services/bureau_oversight_service.dart';
import 'create_inspection_screen.dart';
import 'inspection_report_viewer_screen.dart';
import 'inspection_details_screen.dart';
import 'inspection_list_screen.dart';

/// Bureau Dashboard Screen - Phase 4
/// Government/Cooperative oversight dashboard for bureau officers
class BureauDashboardScreen extends StatefulWidget {
  final String officerId;

  const BureauDashboardScreen({
    super.key,
    this.officerId = '',
  });

  @override
  State<BureauDashboardScreen> createState() => _BureauDashboardScreenState();
}

class _BureauDashboardScreenState extends State<BureauDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = BureauOversightService();

  BureauOfficer? _officer;
  List<Inspection> _inspections = [];
  List<AggregateReport> _reports = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _selectedWoredaId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final officerId = widget.officerId.isNotEmpty
          ? widget.officerId
          : (context.read<AuthProvider>().userId ?? 'OFF001');
      var officer = await _service.getOfficerById(officerId);
      officer ??= (await _service.getOfficers()).firstOrNull;
      final effectiveOfficerId = officer?.id ?? officerId;
      final inspections = await _service.getInspections(officerId: effectiveOfficerId);
      final reports = await _service.getReports();
      final stats = await _service.getInspectionStatistics(officerId: effectiveOfficerId);

      setState(() {
        _officer = officer;
        _inspections = inspections;
        _reports = reports;
        _statistics = stats;
        _selectedWoredaId = officer?.assignedWoredas.firstOrNull ?? 'woreda-001';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bureau Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Inspections'),
            Tab(icon: Icon(Icons.assessment), text: 'Reports'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildInspectionsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  // ==================== OVERVIEW TAB ====================

  Widget _buildOverviewTab() {
    if (_officer == null) {
      return const Center(child: Text('Officer data not available'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfficerCard(),
            const SizedBox(height: 16),
            _buildStatisticsCards(),
            const SizedBox(height: 16),
            _buildWoredaSelector(),
            const SizedBox(height: 16),
            if (_selectedWoredaId != null) _buildWoredaAggregates(),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              _officer!.fullName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 24,
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
                  _officer!.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _officer!.rank.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_officer!.completedInspections} inspections completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_statistics == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Inspections',
            '${_statistics!['total']}',
            Icons.assignment_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'In Progress',
            '${_statistics!['inProgress']}',
            Icons.pending_actions,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Issues Found',
            '${_statistics!['totalIssuesFound']}',
            Icons.warning_amber_outlined,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoredaSelector() {
    if (_officer == null || _officer!.assignedWoredas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Woreda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _officer!.assignedWoredas.map((woredaId) {
            final isSelected = woredaId == _selectedWoredaId;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedWoredaId = woredaId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  woredaId.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWoredaAggregates() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _service.getWoredaAggregates(_selectedWoredaId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final cropVolumes = data['cropVolumes'] as List<CropVolumeData>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['woredaName']} Woreda - Crop Aggregates',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAggregateMetric(
                        'Farms',
                        '${data['totalFarms']}',
                        Icons.agriculture,
                      ),
                      _buildAggregateMetric(
                        'Hectares',
                        '${data['totalHectares'].toStringAsFixed(1)}',
                        Icons.landscape,
                      ),
                      _buildAggregateMetric(
                        'Farmers',
                        '${data['totalFarmers']}',
                        Icons.people,
                      ),
                      _buildAggregateMetric(
                        'Coops',
                        '${data['activeCooperatives']}',
                        Icons.groups,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...cropVolumes.map((crop) => _buildCropVolumeRow(crop)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAggregateMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCropVolumeRow(CropVolumeData crop) {
    final achievementRate = crop.harvestAchievementRate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grass, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropType.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${crop.hectares.toStringAsFixed(1)} ha • ${crop.farmCount} farms',
                      style: TextStyle(
                        fontSize: 12,
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
                    crop.actualVolume != null
                        ? '${(crop.actualVolume! / 1000).toStringAsFixed(1)} tons'
                        : '${(crop.expectedVolume / 1000).toStringAsFixed(1)} tons',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getHarvestStatusColor(crop.harvestStatus)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      crop.harvestStatus.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getHarvestStatusColor(crop.harvestStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (achievementRate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievementRate / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievementRate >= 90
                            ? AppColors.success
                            : achievementRate >= 70
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${achievementRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getHarvestStatusColor(HarvestStatus status) {
    switch (status) {
      case HarvestStatus.completed:
        return AppColors.success;
      case HarvestStatus.inProgress:
        return AppColors.primary;
      case HarvestStatus.preHarvest:
        return AppColors.textSecondary;
      case HarvestStatus.delayed:
        return AppColors.error;
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'New Inspection',
                Icons.add_task,
                AppColors.primary,
                () => _startNewInspection(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Generate Report',
                Icons.summarize,
                AppColors.success,
                () => _generateReport(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InspectionListScreen()),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View All Inspections & Filter'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INSPECTIONS TAB ====================

  Widget _buildInspectionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _inspections.isEmpty
          ? const Center(child: Text('No inspections yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                return _buildInspectionCard(_inspections[index]);
              },
            ),
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InspectionDetailsScreen(inspectionId: inspection.id),
          ),
        );
        if (mounted) _loadData();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getInspectionStatusColor(inspection.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInspectionTypeIcon(inspection.type),
                  color: _getInspectionStatusColor(inspection.status),
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inspection.cooperativeName ?? inspection.farmName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInspectionStatusColor(inspection.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inspection.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getInspectionStatusColor(inspection.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                inspection.woredaName,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(inspection.checkInTime),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (inspection.issueCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    '${inspection.issueCount} ${inspection.issueCount == 1 ? 'issue' : 'issues'} found',
                    style: TextStyle(
                      fontSize: 11,
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

  Color _getInspectionStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.completed:
        return AppColors.success;
      case InspectionStatus.inProgress:
        return AppColors.primary;
      case InspectionStatus.scheduled:
        return AppColors.warning;
      case InspectionStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getInspectionTypeIcon(InspectionType type) {
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

  // ==================== REPORTS TAB ====================

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _reports.isEmpty
          ? const Center(child: Text('No reports yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                return _buildReportCard(_reports[index]);
              },
            ),
    );
  }

  Widget _buildReportCard(AggregateReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assessment,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.woredaName} ${report.period.displayName} Report',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Generated by ${report.generatedByName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReportMetric(
                'Farms',
                '${report.totalFarms}',
                Icons.agriculture,
              ),
              _buildReportMetric(
                'Harvest',
                '${(report.totalActualHarvest / 1000).toStringAsFixed(0)}t',
                Icons.inventory,
              ),
              _buildReportMetric(
                'Rate',
                '${report.harvestCompletionRate.toStringAsFixed(0)}%',
                Icons.show_chart,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatDateTime(report.reportDate),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
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

  Future<void> _startNewInspection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateInspectionScreen(),
      ),
    );
    if (result != null && mounted) {
      _loadData();
    }
  }

  void _generateReport() {
    final completed = _inspections.where((i) => i.status == InspectionStatus.completed).toList();
    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No completed inspections available yet to generate a report.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    if (completed.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InspectionReportViewerScreen(inspection: completed.first),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Inspection Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final inspection = completed[index];
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: AppColors.secondary),
                    title: Text(inspection.cooperativeName ?? inspection.farmName ?? 'Inspection #${inspection.id}'),
                    subtitle: Text('${inspection.type.displayName} • ${inspection.woredaName}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InspectionReportViewerScreen(inspection: inspection),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
