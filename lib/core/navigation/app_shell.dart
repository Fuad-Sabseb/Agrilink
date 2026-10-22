import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import 'bottom_nav_bar.dart';
import 'app_drawer.dart';

/// AppShell - Main application shell with navigation
/// 
/// Provides consistent navigation structure across the app with:
/// - Bottom navigation for primary sections
/// - Drawer for secondary navigation and settings
/// - Adaptive layout for different screen sizes
/// - Role-based navigation items
class AppShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int)? onNavigationChange;
  final bool showBottomNav;
  final bool showDrawer;
  final String? title;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onNavigationChange,
    this.showBottomNav = true,
    this.showDrawer = true,
    this.title,
    this.actions,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final userRole = user?.role.toLowerCase() ?? '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, userRole),
      drawer: widget.showDrawer ? AppDrawer(scaffoldKey: _scaffoldKey) : null,
      body: widget.child,
      bottomNavigationBar: widget.showBottomNav
          ? AgriBottomNavBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onNavigationChange,
              userRole: userRole,
            )
          : null,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, String userRole) {
    if (widget.title == null && (widget.actions?.isEmpty ?? true)) {
      return null;
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: AppTokens.elevationNone,
      leading: widget.showDrawer
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
      title: widget.title != null ? Text(widget.title!) : null,
      actions: widget.actions,
    );
  }
}
