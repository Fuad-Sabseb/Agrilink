import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/statistic_card.dart';
import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/dashboard_card.dart';

/// Enhanced Transporter Dashboard
class EnhancedTransporterDashboard extends StatefulWidget {
  const EnhancedTransporterDashboard({super.key});

  @override
  State<EnhancedTransporterDashboard> createState() =>
      _EnhancedTransporterDashboardState();
}

class _EnhancedTransporterDashboardState
    extends State<EnhancedTransporterDashboard> {
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
        context.read<TransportProvider>().loadTransporterTrips(userId),
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
        return 'Transporter Dashboard';
      case 1:
        return 'Available Jobs';
      case 2:
        return 'My Trips';
      case 3:
        return 'Map View';
      default:
        return 'Transporter Dashboard';
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
        return _buildAvailableJobsScreen();
      case 2:
        return _buildMyTripsScreen();
      case 3:
        return _buildMapScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    final transportProvider = context.watch<TransportProvider>();
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
              'Trip Overview',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleTransporter,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildStatisticsGrid(transportProvider),
            const SizedBox(height: AppTokens.spaceXL),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleTransporter,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildQuickActions(),
            const SizedBox(height: AppTokens.spaceXL),

            // Active Trips
            Text(
              'Active Trips',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.roleTransporter,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildActiveTrips(transportProvider),
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
            AppColors.roleTransporter,
            AppColors.goldLight,
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
                  'Hello,',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  user?.fullName ?? 'Transporter',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  'Ready for your next delivery?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.local_shipping,
            size: 60,
            color: AppColors.textPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(TransportProvider transportProvider) {
    final trips = transportProvider.trips;
    final activeTrips = trips.where((t) => t.status == 'in_progress').length;
    final completedTrips = trips.where((t) => t.status == 'completed').length;
    final pendingTrips = trips.where((t) => t.status == 'pending').length;

    // Calculate earnings (mock data)
    final todayEarnings = 2500.0;
    final monthlyEarnings = 45000.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTokens.spaceM,
      mainAxisSpacing: AppTokens.spaceM,
      childAspectRatio: 1.3,
      children: [
        StatisticCard(
          label: 'Active Trips',
          value: '$activeTrips',
          icon: Icons.local_shipping_outlined,
          color: AppColors.roleTransporter,
        ),
        StatisticCard(
          label: 'Completed',
          value: '$completedTrips',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          trend: '+$completedTrips',
          trendPositive: true,
        ),
        StatisticCard(
          label: 'Today Earnings',
          value: '${todayEarnings.toStringAsFixed(0)} ETB',
          icon: Icons.attach_money,
          color: AppColors.accent,
        ),
        StatisticCard(
          label: 'This Month',
          value: '${monthlyEarnings.toStringAsFixed(0)} ETB',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.tertiaryDark,
          trend: '+18%',
          trendPositive: true,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ActionCard(
          title: 'Find Available Jobs',
          description: 'Browse transport requests near you',
          icon: Icons.work_outline,
          primaryColor: AppColors.roleTransporter,
          isHighlight: true,
          onTap: () {
            setState(() => _currentIndex = 1);
          },
        ),
        const SizedBox(height: AppTokens.spaceM),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'View Map',
                description: 'See nearby deliveries',
                icon: Icons.map_outlined,
                primaryColor: AppColors.tertiary,
                onTap: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
            const SizedBox(width: AppTokens.spaceM),
            Expanded(
              child: ActionCard(
                title: 'Trip History',
                description: 'View past trips',
                icon: Icons.history_outlined,
                primaryColor: AppColors.success,
                onTap: () {
                  Navigator.pushNamed(context, '/transporter/history');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTrips(TransportProvider transportProvider) {
    final activeTrips = transportProvider.trips
        .where((t) => t.status == 'in_progress')
        .toList();

    if (activeTrips.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceXL),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppTokens.spaceM),
                Text(
                  'No active trips',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  'Find available jobs to get started',
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
      children: activeTrips.map((trip) {
        return DashboardCard(
          title: 'Trip to ${trip.destinationLocation}',
          subtitle: 'Distance: ${trip.distance?.toStringAsFixed(1) ?? "N/A"} km',
          icon: Icons.navigation_outlined,
          iconColor: AppColors.roleTransporter,
          trailing: Chip(
            label: const Text('In Progress', style: TextStyle(fontSize: 12)),
            backgroundColor: AppColors.warning.withOpacity(0.1),
          ),
          onTap: () {
            // Navigate to trip details
          },
        );
      }).toList(),
    );
  }

  Widget _buildAvailableJobsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: AppColors.roleTransporter.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Available Jobs', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Transport requests will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTripsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: AppColors.roleTransporter.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('My Trips', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Your trip history will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: AppColors.roleTransporter.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Map View', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Map integration coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
