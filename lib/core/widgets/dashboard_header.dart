import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../localization/app_localizations.dart';

/// User Role Enum
enum UserRole {
  farmer,
  buyer,
  transporter,
  bureau,
}

/// Dashboard Header Widget
/// Matches Lao Agrolink's header pattern with:
/// - Active User Role Badge
/// - Woreda/Regional Selector
/// - Notification Bell
class DashboardHeader extends StatelessWidget {
  final UserRole currentRole;
  final String selectedWoreda;
  final int notificationCount;
  final VoidCallback? onRoleTap;
  final VoidCallback? onWoredaTap;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.currentRole,
    required this.selectedWoreda,
    this.notificationCount = 0,
    this.onRoleTap,
    this.onWoredaTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Role Badge, Spacer, Notification
              Row(
                children: [
                  _buildRoleBadge(context),
                  const Spacer(),
                  _buildNotificationButton(context),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom Row: Woreda Selector
              _buildWoredaSelector(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final roleData = _getRoleData(localizations);

    return InkWell(
      onTap: onRoleTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: roleData.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              roleData.icon,
              size: 16,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              roleData.label,
              style: AppTypography.roleBadge,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return InkWell(
      onTap: onNotificationTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_rounded,
              color: AppColors.textOnPrimary,
              size: 22,
            ),
            if (notificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoredaSelector(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return InkWell(
      onTap: onWoredaTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('select_woreda'),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedWoreda,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }

  _RoleData _getRoleData(AppLocalizations localizations) {
    switch (currentRole) {
      case UserRole.farmer:
        return _RoleData(
          label: localizations.roleFarmer,
          color: AppColors.roleFarmer,
          icon: Icons.agriculture_rounded,
        );
      case UserRole.buyer:
        return _RoleData(
          label: localizations.roleBuyer,
          color: AppColors.roleBuyer,
          icon: Icons.shopping_cart_rounded,
        );
      case UserRole.transporter:
        return _RoleData(
          label: localizations.roleTransporter,
          color: AppColors.roleTransporter,
          icon: Icons.local_shipping_rounded,
        );
      case UserRole.bureau:
        return _RoleData(
          label: localizations.roleBureau,
          color: AppColors.roleBureau,
          icon: Icons.business_rounded,
        );
    }
  }
}

class _RoleData {
  final String label;
  final Color color;
  final IconData icon;

  _RoleData({
    required this.label,
    required this.color,
    required this.icon,
  });
}
