import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/order_model.dart';
import '../../core/services/session_service.dart';
import 'farmer_dashboard.dart';
import 'my_produce_screen.dart';
import 'order_requests_screen.dart';
import 'logistics_status_screen.dart';
import '../shared/profile_screen.dart';
import '../../routes/app_routes.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FarmerDashboard(),
    MyProduceScreen(),
    OrderRequestsScreen(),
    LogisticsStatusScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final userId = sessionService.currentUserId;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduce),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: !Hive.isBoxOpen('orders')
          ? _buildNavigationBar(0)
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                final pendingCount = orderBox.values
                    .where((o) => o.farmerId == userId && o.status == 'pending')
                    .length;

                return _buildNavigationBar(pendingCount);
              },
            ),
    );
  }

  Widget _buildNavigationBar(int pendingCount) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, size: 32),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2, size: 32),
          label: 'Produce',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            child: const Icon(Icons.receipt_long_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            child: const Icon(Icons.receipt_long, size: 32),
          ),
          label: 'Orders',
        ),
        const NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping, size: 32),
          label: 'Logistics',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, size: 32),
          label: 'Profile',
        ),
      ],
    );
  }
}
