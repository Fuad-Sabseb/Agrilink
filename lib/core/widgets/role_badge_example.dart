import 'package:flutter/material.dart';
import 'role_badge.dart';

/// Example screen demonstrating RoleBadge usage
/// 
/// This is a visual example of how the RoleBadge widget appears
/// for different user roles with the Agricultural Earth-Tone color scheme.
class RoleBadgeExample extends StatelessWidget {
  const RoleBadgeExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Badge Examples'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Role Badges',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Farmer badge
              _buildRoleExample(
                'Farmer',
                'Rich Earth Green background with white text',
                const RoleBadge(role: 'farmer'),
              ),
              const SizedBox(height: 16),
              
              // Buyer badge
              _buildRoleExample(
                'Buyer',
                'Ethiopian Coffee Brown background with white text',
                const RoleBadge(role: 'buyer'),
              ),
              const SizedBox(height: 16),
              
              // Transporter badge
              _buildRoleExample(
                'Transporter',
                'Golden Harvest background with dark text for accessibility',
                const RoleBadge(role: 'transporter'),
              ),
              const SizedBox(height: 16),
              
              // Bureau badge
              _buildRoleExample(
                'Bureau Officer',
                'Sky Blue background with white text',
                const RoleBadge(role: 'bureau'),
              ),
              const SizedBox(height: 32),
              
              // Example in context
              const Text(
                'In Context Example:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildUserCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleExample(String title, String description, Widget badge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        badge,
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abebe Kebede',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jimma Zone',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const RoleBadge(role: 'farmer'),
          ],
        ),
      ),
    );
  }
}
