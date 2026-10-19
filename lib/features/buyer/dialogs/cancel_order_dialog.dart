import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Cancel Order Dialog
/// Allows buyer to cancel an order with a reason
class CancelOrderDialog extends StatefulWidget {
  final String orderId;
  final String orderTitle; // e.g., "50 kg Coffee"

  const CancelOrderDialog({
    super.key,
    required this.orderId,
    required this.orderTitle,
  });

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  String? _selectedReason;
  final _customReasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _predefinedReasons = [
    'Changed my mind',
    'Found better price elsewhere',
    'Quality concerns',
    'Delivery issues',
    'Farmer not responding',
    'Payment issues',
    'Other',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    if (_selectedReason == null) return false;
    if (_selectedReason == 'Other' && _customReasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _submit() {
    if (!_canSubmit()) return;

    final reason = _selectedReason == 'Other'
        ? _customReasonController.text.trim()
        : _selectedReason!;

    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Cancel Order'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to cancel:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.orderTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Please select a reason:',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._predefinedReasons.map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() => _selectedReason = value);
                        },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
            if (_selectedReason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customReasonController,
                decoration: InputDecoration(
                  labelText: 'Specify reason',
                  hintText: 'Enter your reason here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                maxLength: 200,
                enabled: !_isSubmitting,
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Keep Order'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || !_canSubmit() ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Cancel Order'),
        ),
      ],
    );
  }
}

/// Show Cancel Order Dialog
/// Returns the cancellation reason if confirmed, null if dismissed
Future<String?> showCancelOrderDialog(
  BuildContext context, {
  required String orderId,
  required String orderTitle,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => CancelOrderDialog(
      orderId: orderId,
      orderTitle: orderTitle,
    ),
  );
}
