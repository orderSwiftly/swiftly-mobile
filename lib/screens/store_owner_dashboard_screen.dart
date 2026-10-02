// screens/store_owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/profile_service.dart';
import '../widgets/navbar.dart';

class StoreOwnerDashboardScreen extends StatefulWidget {
  const StoreOwnerDashboardScreen({super.key});

  @override
  State<StoreOwnerDashboardScreen> createState() =>
      _StoreOwnerDashboardScreenState();
}

class _StoreOwnerDashboardScreenState extends State<StoreOwnerDashboardScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ProfileService _profileService = ProfileService();

  String? _storeName;
  String? _storeAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    try {
      final activeStoreId = await _storage.read(key: 'active_store_id');
      final profile = await _profileService.fetchUserProfile();

      if (profile != null && activeStoreId != null) {
        final stores =
            (profile['owned_stores'] as List?)
                ?.map((s) => Map<String, dynamic>.from(s))
                .toList() ??
            [];

        final activeStore = stores.firstWhere(
          (s) => s['store_id'] == activeStoreId,
          orElse: () => {},
        );

        if (mounted) {
          setState(() {
            _storeName = activeStore['store_name'];
            _storeAddress = activeStore['store_address'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading store info: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          _StoreOwnerHeader(
            isMobile: isMobile,
            isDesktop: isDesktop,
            storeName: _storeName,
            isLoading: _isLoading,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : isDesktop
                // Desktop-specific dashboard layout for store owner.
                ? _buildDesktopContent()
                : _buildMobileContent(),
          ),
        ],
      ),
    );
  }

  // Desktop version: wider content card + summary blocks for large screens.
  Widget _buildMobileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Welcome to ${_storeName ?? 'your store'}',
            style: AppTypography.headline.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your store and products',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // Desktop layout: center the dashboard and add a large info card.
  Widget _buildDesktopContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.accent,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to ${_storeName ?? 'your store'}',
                              style: AppTypography.headline.copyWith(
                                color: AppColors.primary,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _storeAddress ??
                                  'Manage your store operations from one place.',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Orders',
                      value: 'Pending review',
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Products',
                      value: 'Live catalog',
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.people_alt_outlined,
                      title: 'Staff',
                      value: 'Team ready',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable desktop summary card for dashboard stats/overview blocks.
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: AppColors.text,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreOwnerHeader extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final String? storeName;
  final bool isLoading;

  const _StoreOwnerHeader({
    required this.isMobile,
    required this.isDesktop,
    required this.storeName,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final String title = isLoading ? 'Dashboard' : (storeName ?? 'Dashboard');

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
                Icons.store,
                size: isDesktop ? 36 : (isMobile ? 28 : 32),
                color: AppColors.accent,
              ),
              if (isMobile)
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              if (isDesktop) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
