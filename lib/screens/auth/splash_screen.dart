import 'package:flutter/material.dart';
import '../../core/services/session_service.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Add a slight delay for splash screen effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final sessionService = SessionService();
    
    if (sessionService.isLoggedIn) {
      final user = sessionService.currentUser;
      if (user != null) {
        // Route based on role
        switch (user.role.toLowerCase()) {
          case 'farmer':
            Navigator.pushReplacementNamed(context, AppRoutes.farmerDashboard);
            return;
          case 'buyer':
            Navigator.pushReplacementNamed(context, AppRoutes.buyerDashboard);
            return;
          case 'transporter':
            Navigator.pushReplacementNamed(context, AppRoutes.transporterDashboard);
            return;
          case 'bureau_officer':
            Navigator.pushReplacementNamed(context, AppRoutes.bureauDashboard);
            return;
        }
      }
    }
    
    // If not logged in or user data missing
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'AgroLink',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Connecting Farmers & Markets',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
