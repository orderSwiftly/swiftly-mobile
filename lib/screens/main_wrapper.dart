// screens/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/profile_service.dart';
import 'dashboard_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'rider_dashboard_screen.dart';
import 'store_owner_dashboard_screen.dart';
import 'store_owner/selecting_stores_screen.dart';
import 'store_owner/store_profile.dart';
import 'store_owner/store_order.dart'; 

enum UserRole { customer, rider, storeOwner }

class MainWrapper extends StatefulWidget {
  final String? role;
  final String? token;
  final String? userId;

  const MainWrapper({super.key, this.role, this.token, this.userId});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  late Future<UserRole?> _futureRole;
  UserRole? _currentRole;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _futureRole = _getUserRole();
  }

  Future<UserRole?> _getUserRole() async {
    if (widget.role != null) {
      await _storage.write(key: 'user_role', value: widget.role!);
      await _storage.write(key: 'auth_token', value: widget.token ?? '');
      await _storage.write(key: 'user_id', value: widget.userId ?? '');
      return _stringToRole(widget.role!);
    }
    final roleString = await _storage.read(key: 'user_role') ?? 'CUSTOMER';
    return _stringToRole(roleString);
  }

  UserRole _stringToRole(String role) {
    switch (role.toUpperCase()) {
      case 'RIDER':
        return UserRole.rider;
      case 'STORE_OWNER':
        return UserRole.storeOwner;
      default:
        return UserRole.customer;
    }
  }

  Future<bool> _storeIsSelected() async {
    final storeId = await _storage.read(key: 'active_store_id');
    return storeId != null && storeId.isNotEmpty;
  }

  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return [
          const RiderDashboardScreen(),
          const PlaceholderScreen(title: 'Deliveries'),
          const PlaceholderScreen(title: 'Earnings'),
          const PlaceholderScreen(title: 'Profile'), // rider profile
        ];
      case UserRole.storeOwner:
        return [
          const StoreOwnerDashboardScreen(),
          const PlaceholderScreen(title: 'Products'),
          const StoreOrderScreen(),
          StoreProfileScreen(
            onOrdersTap: () => setState(() => _selectedIndex = 2),
          ), // store profile
        ];
      case UserRole.customer:
      default:
        return [
          const DashboardScreen(),
          const CartScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ];
    }
  }

  List<RoleNavItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return const [
          RoleNavItem(
            icon: Icons.delivery_dining_outlined,
            activeIcon: Icons.delivery_dining,
            label: 'Dashboard',
          ),
          RoleNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Deliveries',
          ),
          RoleNavItem(
            icon: Icons.monetization_on_outlined,
            activeIcon: Icons.monetization_on,
            label: 'Earnings',
          ),
          RoleNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];
      case UserRole.storeOwner:
        return const [
          RoleNavItem(
            icon: Icons.store_outlined,
            activeIcon: Icons.store,
            label: 'Dashboard',
          ),
          RoleNavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Products',
          ),
          RoleNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Orders',
          ),
          RoleNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];
      case UserRole.customer:
      default:
        return const [
          RoleNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          RoleNavItem(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            label: 'Cart',
          ),
          RoleNavItem(
            icon: Icons.receipt_outlined,
            activeIcon: Icons.receipt,
            label: 'Orders',
          ),
          RoleNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'active_store_id');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildScaffold() {
    final pages = _getPagesForRole(_currentRole!);
    final navItems = _getNavItemsForRole(_currentRole!);
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.prof,
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: _selectedIndex,
              onIndexChanged: (index) => setState(() => _selectedIndex = index),
              navItems: navItems,
              onLogout: _logout,
            ),
            Expanded(child: ClipRect(child: pages[_selectedIndex])),
          ],
        ),
      );
    }

    return ResponsiveScaffold(
      currentIndex: _selectedIndex,
      onIndexChanged: (index) => setState(() => _selectedIndex = index),
      navItems: navItems,
      appBar: null,
      child: pages[_selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: _futureRole,
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _currentRole = roleSnapshot.data ?? UserRole.customer;

        // Store owner gate — must select a store before accessing dashboard
        if (_currentRole == UserRole.storeOwner) {
          return FutureBuilder<bool>(
            future: _storeIsSelected(),
            builder: (context, storeSnapshot) {
              if (storeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final hasStore = storeSnapshot.data ?? false;

              if (!hasStore) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: ProfileService().fetchUserProfile(),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final profile = profileSnapshot.data;
                    final stores =
                        (profile?['owned_stores'] as List?)
                            ?.map((s) => Map<String, dynamic>.from(s))
                            .toList() ??
                        [];

                    return SelectingStoresScreen(
                      stores: stores,
                      onStoreSelected: () => setState(() {}),
                    );
                  },
                );
              }

              return _buildScaffold();
            },
          );
        }

        return _buildScaffold();
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<RoleNavItem> navItems;
  final VoidCallback onLogout;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.navItems,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.prof,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Image.asset(
                'assets/images/swiftly-txt.png',
                width: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'Swiftly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final bool isActive = selectedIndex == index;
            return _SidebarNavTile(
              icon: isActive ? item.activeIcon : item.icon,
              label: item.label,
              isActive: isActive,
              onTap: () => onIndexChanged(index),
            );
          }),
          const Spacer(),
          _SidebarNavTile(
            icon: Icons.logout_outlined,
            label: 'Logout',
            isActive: false,
            onTap: onLogout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarNavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white60,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.headline.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
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
