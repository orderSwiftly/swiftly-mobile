// screens/orders_screen.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    // On desktop, cap the empty state content width so it
    // doesn't look lost in the middle of a wide screen
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      // ── DESKTOP ADAPTATION START ──
      // Desktop: add a page title header above the empty state
      // so the screen doesn't feel like a blank page
      appBar: isDesktop
          ? AppBar(
              backgroundColor: AppColors.text,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
      // ── DESKTOP ADAPTATION END ──
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── DESKTOP ADAPTATION START ──
            // Slightly larger icon on desktop for better visual balance
            Icon(
              Icons.receipt_outlined,
              size: isDesktop ? 96 : 80,
              color: AppColors.textSecondary,
            ),
            // ── DESKTOP ADAPTATION END ──
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: AppTypography.headline.copyWith(
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start shopping to see your orders',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
