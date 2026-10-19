import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/order_model.dart';
import '../../models/logistics_model.dart';
import '../../core/services/session_service.dart';
import 'transporter_dashboard.dart';
import 'available_pickups_screen.dart';
import 'my_deliveries_screen.dart';
import '../shared/profile_screen.dart';

class TransporterMainScreen extends StatefulWidget {
  const TransporterMainScreen({super.key});

  @override
  State<TransporterMainScreen> createState() => _TransporterMainScreenState();
}

class _TransporterMainScreenState extends State<TransporterMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TransporterDashboard(),
    AvailablePickupsScreen(),
    MyDeliveriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final userId = sessionService.currentUser?.id;

    final bool boxesOpen = Hive.isBoxOpen('orders') && Hive.isBoxOpen('logistics');

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: !boxesOpen
          ? _buildNavigationBar(0, 0)
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<LogisticsModel>>(
                  valueListenable: Hive.box<LogisticsModel>('logistics').listenable(),
                  builder: (context, logisticsBox, _) {
                    // Available pickups = confirmed orders not yet claimed by anyone
                    final availablePickupsCount = orderBox.values
                        .where((o) => o.status == 'confirmed')
                        .length;

                    // My in-transit deliveries
                    final inTransitCount = logisticsBox.values
                        .where((d) => d.transporterId == userId && d.status == 'in_transit')
                        .length;

                    return _buildNavigationBar(availablePickupsCount, inTransitCount);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNavigationBar(int availablePickupsCount, int inTransitCount) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, size: 32),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: availablePickupsCount > 0,
            label: Text('$availablePickupsCount'),
            child: const Icon(Icons.map_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: availablePickupsCount > 0,
            label: Text('$availablePickupsCount'),
            child: const Icon(Icons.map, size: 32),
          ),
          label: 'Pickups',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: inTransitCount > 0,
            label: Text('$inTransitCount'),
            child: const Icon(Icons.local_shipping_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: inTransitCount > 0,
            label: Text('$inTransitCount'),
            child: const Icon(Icons.local_shipping, size: 32),
          ),
          label: 'Deliveries',
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
