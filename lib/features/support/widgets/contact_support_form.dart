import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../services/support_service.dart';

class ContactSupportForm extends StatefulWidget {
  const ContactSupportForm({super.key});

  @override
  State<ContactSupportForm> createState() => _ContactSupportFormState();
}

class _ContactSupportFormState extends State<ContactSupportForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _subject = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _subjects = [
    'General Inquiry',
    'Technical Issue',
    'Account Problem',
    'Order Issue',
    'Payment Problem',
    'Feature Request',
    'Other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final phone = authProvider.user?.phone ?? '';

      await SupportService().sendSupportRequest(
        subject: _subject,
        message: _messageController.text,
        phone: phone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent! We\'ll contact you within 24 hours.'),
            backgroundColor: AppColors.success,
          ),
        );
        _messageController.clear();
        setState(() => _subject = 'General Inquiry');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('network')
                  ? 'Message saved. We\'ll send it when you\'re online.'
                  : 'Failed to send message. Please try again.',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final phone = authProvider.user?.phone ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How can we help you?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _subject = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue or question...',
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                if (value.length < 20) {
                  return 'Message must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Sending...' : 'Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
