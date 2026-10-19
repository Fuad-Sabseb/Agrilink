import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../routes/app_routes.dart';
import '../widgets/transport_request_card.dart';

/// Transport Requests Tab for farmers
class TransportRequestsTab extends StatefulWidget {
  const TransportRequestsTab({super.key});

  @override
  State<TransportRequestsTab> createState() => _TransportRequestsTabState();
}

class _TransportRequestsTabState extends State<TransportRequestsTab>
    with AutomaticKeepAliveClientMixin {
  final _sessionService = SessionService();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    final userId = _sessionService.currentUserId;
    if (userId != null) {
      await context.read<TransportProvider>().loadFarmerTransportRequests(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final provider = context.watch<TransportProvider>();
    final requests = provider.farmerRequests;

    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading transport requests...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (requests.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transport requests',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create transport requests for your orders',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildFAB(),
        ],
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16).copyWith(bottom: 88),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];
              return TransportRequestCard(
                request: request,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    FarmerRoutes.transportRequestDetail,
                    arguments: request.id,
                  );
                },
              );
            },
          ),
        ),
        _buildFAB(),
      ],
    );
  }

  Widget _buildFAB() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(FarmerRoutes.createTransportRequest);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Request Transport',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
