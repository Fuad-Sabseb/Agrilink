import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../core/services/session_service.dart';
import 'buyer_dashboard.dart';
import 'browse_produce_screen.dart';
import 'my_orders_screen.dart';
import '../shared/profile_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BuyerDashboard(),
    BrowseProduceScreen(),
    MyOrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final userId = sessionService.currentUser?.id;

    final bool boxesOpen = Hive.isBoxOpen('orders') && Hive.isBoxOpen('payments');

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: !boxesOpen
          ? _buildNavigationBar(0)
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<PaymentModel>>(
                  valueListenable: Hive.box<PaymentModel>('payments').listenable(),
                  builder: (context, paymentBox, _) {
                    // Count confirmed orders that haven't been paid
                    final unpaidCount = orderBox.values.where((o) {
                      if (o.buyerId != userId || o.status != 'confirmed') return false;
                      return !paymentBox.values.any((p) => p.orderId == o.id && p.status == 'completed');
                    }).length;

                    return _buildNavigationBar(unpaidCount);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNavigationBar(int unpaidCount) {
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
          icon: Icon(Icons.shopping_basket_outlined),
          selectedIcon: Icon(Icons.shopping_basket, size: 32),
          label: 'Market',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: unpaidCount > 0,
            label: Text('$unpaidCount'),
            child: const Icon(Icons.list_alt_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: unpaidCount > 0,
            label: Text('$unpaidCount'),
            child: const Icon(Icons.list_alt, size: 32),
          ),
          label: 'My Orders',
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
