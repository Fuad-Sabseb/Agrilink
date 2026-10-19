import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/farmer_model.dart';

/// Contact Farmer Dialog
/// Provides multiple options for contacting a farmer
/// Options: Call, SMS, WhatsApp, Copy Number
/// 
/// Usage:
/// ```dart
/// final contacted = await showContactFarmerDialog(
///   context,
///   farmer: farmer,
/// );
/// ```
Future<bool?> showContactFarmerDialog(
  BuildContext context, {
  required Farmer farmer,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ContactFarmerDialog(farmer: farmer),
  );
}

class ContactFarmerDialog extends StatelessWidget {
  final Farmer farmer;

  const ContactFarmerDialog({
    super.key,
    required this.farmer,
  });

  Future<void> _makeCall(BuildContext context) async {
    final phoneNumber = farmer.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        _showError(context, 'Cannot make phone calls on this device');
      }
    }
  }

  Future<void> _sendSMS(BuildContext context) async {
    final phoneNumber = farmer.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'sms', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        _showError(context, 'Cannot send SMS on this device');
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phoneNumber = farmer.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    // Ethiopian phone format: remove leading 0 and add 251 country code
    final formattedNumber = phoneNumber.startsWith('0')
        ? '251${phoneNumber.substring(1)}'
        : phoneNumber.startsWith('251')
            ? phoneNumber
            : '251$phoneNumber';

    final message = Uri.encodeComponent(
        'Hello ${farmer.name}, I\'m interested in your produce. Can we discuss?');
    final uri = Uri.parse('https://wa.me/$formattedNumber?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        _showError(context, 'WhatsApp is not installed on this device');
      }
    }
  }

  void _copyNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: farmer.phoneNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number copied: ${farmer.phoneNumber}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryVeryLight,
                  child: Text(
                    farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Farmer',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        farmer.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Phone number display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      farmer.phoneNumber,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact options
            Text(
              'Choose contact method:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Call button
            _ContactOptionButton(
              icon: Icons.phone,
              label: 'Call',
              subtitle: 'Make a phone call',
              color: AppColors.success,
              onPressed: () => _makeCall(context),
            ),
            const SizedBox(height: 12),

            // SMS button
            _ContactOptionButton(
              icon: Icons.message,
              label: 'Send SMS',
              subtitle: 'Send a text message',
              color: AppColors.info,
              onPressed: () => _sendSMS(context),
            ),
            const SizedBox(height: 12),

            // WhatsApp button
            _ContactOptionButton(
              icon: Icons.chat_bubble,
              label: 'WhatsApp',
              subtitle: 'Message on WhatsApp',
              color: Color(0xFF25D366), // WhatsApp green
              onPressed: () => _openWhatsApp(context),
            ),
            const SizedBox(height: 12),

            // Copy number button
            _ContactOptionButton(
              icon: Icons.copy,
              label: 'Copy Number',
              subtitle: 'Copy to clipboard',
              color: AppColors.textSecondary,
              onPressed: () => _copyNumber(context),
            ),
            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact Option Button Widget
class _ContactOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _ContactOptionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
