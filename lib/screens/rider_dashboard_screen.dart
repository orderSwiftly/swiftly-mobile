// screens/rider_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/navbar.dart';

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          _RiderHeader(isMobile: isMobile, isDesktop: isDesktop),
          Expanded(
            child: Center(
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
                    style: AppTypography.headline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and manage deliveries',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderHeader extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;

  const _RiderHeader({required this.isMobile, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 100 : 120,
      color: AppColors.text,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.delivery_dining,
                size: isDesktop ? 36 : (isMobile ? 28 : 32),
                color: AppColors.accent,
              ),
              if (isMobile)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (isDesktop) ...[
                const SizedBox(width: 12),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                const AppNavBar(),
              ],
              if (isMobile) const AppNavBar(),
              if (!isMobile && !isDesktop) ...[
                const Spacer(),
                const AppNavBar(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
