import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/providers/inspection_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/statistic_card.dart';
import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/dashboard_card.dart';

/// Enhanced Bureau Officer Dashboard
class EnhancedBureauDashboard extends StatefulWidget {
  const EnhancedBureauDashboard({super.key});

  @override
  State<EnhancedBureauDashboard> createState() =>
      _EnhancedBureauDashboardState();
}

class _EnhancedBureauDashboardState extends State<EnhancedBureauDashboard> {
  final _sessionService = SessionService();
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final userId = _sessionService.currentUserId;
    if (userId == null) return;

    try {
      await Future.wait([
        context.read<InspectionProvider>().loadInspections(userId),
        context.read<NotificationProvider>().loadUserNotifications(userId),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return AppShell(
      currentIndex: _currentIndex,
      onNavigationChange: (index) {
        setState(() => _currentIndex = index);
      },
      showBottomNav: true,
      showDrawer: true,
      title: _getTitle(),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardData,
        ),
      ],
      child: _buildContent(),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Bureau Dashboard';
      case 1:
        return 'Inspections';
      case 2:
        return 'Registered Farms';
      case 3:
        return 'Reports';
      default:
        return 'Bureau Dashboard';
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildInspectionsScreen();
      case 2:
        return _buildFarmsScreen();
      case 3:
        return _buildReportsScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    final inspectionProvider = context.watch<InspectionProvider>();
    final user = _sessionService.currentUser;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(user),
            const SizedBox(height: AppTokens.spaceXL),

            // Statistics
            Text(
              'Inspection Overview',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleBureau,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildStatisticsGrid(inspectionProvider),
            const SizedBox(height: AppTokens.spaceXL),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleBureau,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildQuickActions(),
            const SizedBox(height: AppTokens.spaceXL),

            // Upcoming Inspections
            Text(
              'Upcoming Inspections',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleBureau,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildUpcomingInspections(inspectionProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.roleBureau,
            AppColors.tertiaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Officer',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  user?.fullName ?? 'Bureau Officer',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  'Ensuring agricultural quality and compliance',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user,
            size: 60,
            color: AppColors.textOnPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(InspectionProvider inspectionProvider) {
    final inspections = inspectionProvider.inspections;
    final totalInspections = inspections.length;
    final pendingInspections =
        inspections.where((i) => i.status.name == 'pending').length;
    final completedInspections =
        inspections.where((i) => i.status.name == 'completed').length;
    final scheduledInspections =
        inspections.where((i) => i.status.name == 'scheduled').length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTokens.spaceM,
      mainAxisSpacing: AppTokens.spaceM,
      childAspectRatio: 1.3,
      children: [
        StatisticCard(
          label: 'Total Inspections',
          value: '$totalInspections',
          icon: Icons.verified_outlined,
          color: AppColors.roleBureau,
        ),
        StatisticCard(
          label: 'Pending',
          value: '$pendingInspections',
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        StatisticCard(
          label: 'Scheduled',
          value: '$scheduledInspections',
          icon: Icons.calendar_today_outlined,
          color: AppColors.tertiaryDark,
        ),
        StatisticCard(
          label: 'Completed',
          value: '$completedInspections',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          trend: '+$completedInspections',
          trendPositive: true,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ActionCard(
          title: 'Schedule Inspection',
          description: 'Create a new farm inspection schedule',
          icon: Icons.add_task_outlined,
          primaryColor: AppColors.roleBureau,
          isHighlight: true,
          onTap: () {
            Navigator.pushNamed(context, '/bureau/schedule-inspection');
          },
        ),
        const SizedBox(height: AppTokens.spaceM),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'View Farms',
                description: 'Browse registered farms',
                icon: Icons.agriculture_outlined,
                primaryColor: AppColors.success,
                onTap: () {
                  setState(() => _currentIndex = 2);
                },
              ),
            ),
            const SizedBox(width: AppTokens.spaceM),
            Expanded(
              child: ActionCard(
                title: 'Reports',
                description: 'Generate reports',
                icon: Icons.analytics_outlined,
                primaryColor: AppColors.tertiary,
                onTap: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingInspections(InspectionProvider inspectionProvider) {
    final upcomingInspections = inspectionProvider.inspections
        .where((i) =>
            i.status.name == 'scheduled' || i.status.name == 'pending')
        .take(5)
        .toList();

    if (upcomingInspections.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceXL),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppTokens.spaceM),
                Text(
                  'No upcoming inspections',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  'Schedule a new inspection to get started',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: upcomingInspections.map((inspection) {
        return DashboardCard(
          title: '${inspection.inspectionType.name} Inspection',
          subtitle: inspection.farmName ?? 'Farm',
          icon: Icons.verified_outlined,
          iconColor: AppColors.roleBureau,
          trailing: Chip(
            label: Text(
              inspection.status.name,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getStatusColor(inspection.status.name)
                .withOpacity(0.1),
          ),
          onTap: () {
            // Navigate to inspection details
          },
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'scheduled':
        return AppColors.tertiary;
      case 'in_progress':
        return AppColors.roleBureau;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildInspectionsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 80,
            color: AppColors.roleBureau.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Inspections', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Inspection management coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 80,
            color: AppColors.roleBureau.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Registered Farms', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Farm registry coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: AppColors.roleBureau.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Reports', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Reporting system coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
