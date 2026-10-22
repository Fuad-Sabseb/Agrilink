import 'package:flutter/material.dart';
import 'location_test_screen.dart';
import 'notification_test_screen.dart';
import 'error_testing_screen.dart';

/// Debug Menu - Entry point for all debugging and testing screens
/// 
/// Available in DEBUG mode only
class DebugMenuScreen extends StatelessWidget {
  const DebugMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Testing Menu'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWarningCard(),
          const SizedBox(height: 24),
          _buildMenuCard(
            context,
            'Location Services Test',
            'Test GPS, permissions, tracking, and offline queue',
            Icons.location_on,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocationTestScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            'Notification Services Test',
            'Test notifications, history, and badge management',
            Icons.notifications,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationTestScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            'Error Testing',
            'Test all error scenarios with localized messages',
            Icons.bug_report,
            Colors.red,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ErrorTestingScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.amber),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Debug Mode Only\n\nThese screens are for development and testing. They should not be visible in production builds.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
