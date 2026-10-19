import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/providers/auth_provider.dart';

/// DeleteAccountDialog
/// Confirmation dialog for account deletion with safety checks
/// Requires user to type their phone number for confirmation
///
/// **Validates: Requirements 12.8, 12.9, 12.10**

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _confirmationController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final authProvider = context.read<AuthProvider>();
    final userPhone = authProvider.user?.phone ?? '';

    // Validate confirmation
    if (_confirmationController.text.trim() != userPhone) {
      setState(() {
        _error = 'Phone number does not match';
      });
      return;
    }

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      // Call delete account API (would be implemented in AuthService)
      await Future.delayed(const Duration(seconds: 2)); // Simulated API call
      
      if (!mounted) return;

      // Logout and clear data
      await authProvider.logout();

      if (!mounted) return;

      // Close dialog and navigate to login
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to delete account. Please try again.';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userPhone = authProvider.user?.phone ?? '';

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          const Text('Delete Account'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deleting your account will permanently remove:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Your profile information'),
            const Text('• All your orders and transactions'),
            const Text('• Your farm and crop data'),
            const Text('• Your saved preferences'),
            const Text('• All associated records'),
            const SizedBox(height: 24),
            Text(
              'To confirm, please type your phone number:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userPhone,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                errorText: _error,
                border: const OutlineInputBorder(),
                enabled: !_isDeleting,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Delete Account'),
        ),
      ],
    );
  }
}

/// Show delete account confirmation dialog
Future<bool?> showDeleteAccountDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const DeleteAccountDialog(),
  );
}
