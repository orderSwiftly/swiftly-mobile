// screens/rider_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.text,
        // No bell/avatar here - just a simple AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 64,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome Rider!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('View and manage deliveries'),
          ],
        ),
      ),
    );
  }
}
