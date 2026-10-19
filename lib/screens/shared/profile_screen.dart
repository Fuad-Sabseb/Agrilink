import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final user = sessionService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar
            CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                (user?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Unknown User',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (user?.role ?? 'user').toUpperCase(),
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Info Cards
            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: user?.fullName ?? '—',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: user?.phone ?? '—',
              color: AppColors.tertiary,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: user?.location ?? '—',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.verified_user_outlined,
              label: 'Role',
              value: (user?.role ?? '—').capitalize(),
              color: AppColors.accent,
            ),
            const SizedBox(height: 40),
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Logout', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await sessionService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  }
                },
                icon: Icon(Icons.logout, color: AppColors.error),
                label: Text('Logout', style: TextStyle(color: AppColors.error, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
