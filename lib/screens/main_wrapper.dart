// screens/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'dashboard_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'rider_dashboard_screen.dart';
import 'store_owner_dashboard_screen.dart';

// User role enum
enum UserRole { customer, rider, storeOwner }

class MainWrapper extends StatefulWidget {
  final String? role; // Pass from login: "CUSTOMER", "RIDER", "STORE_OWNER"
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

  @override
  void initState() {
    super.initState();
    _futureRole = _getUserRole();
  }

  Future<UserRole?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();

    // If role was passed directly (from login)
    if (widget.role != null) {
      // Store the role in lowercase for enum compatibility
      await prefs.setString('user_role', widget.role!.toLowerCase());
      await prefs.setString('auth_token', widget.token ?? '');
      await prefs.setString('user_id', widget.userId ?? '');
      return _stringToRole(widget.role!);
    }

    // Otherwise get from storage
    final roleString = prefs.getString('user_role');
    if (roleString == null) return UserRole.customer;
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

  // Helper method to get pages based on role
  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return [
          const RiderDashboardScreen(),
          const PlaceholderScreen(title: 'Deliveries'),
          const PlaceholderScreen(title: 'Earnings'),
          const ProfileScreen(),
        ];
      case UserRole.storeOwner:
        return [
          const StoreOwnerDashboardScreen(),
          const PlaceholderScreen(title: 'Products'),
          const PlaceholderScreen(title: 'Orders'),
          const ProfileScreen(),
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

  // Helper method to get nav items based on role
  List<_NavItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return const [
          _NavItem(icon: Icons.delivery_dining, label: 'Dashboard'),
          _NavItem(icon: Icons.map_outlined, label: 'Deliveries'),
          _NavItem(icon: Icons.monetization_on_outlined, label: 'Earnings'),
          _NavItem(icon: Icons.person_outline, label: 'Profile'),
        ];
      case UserRole.storeOwner:
        return const [
          _NavItem(icon: Icons.store, label: 'Dashboard'),
          _NavItem(icon: Icons.inventory_2_outlined, label: 'Products'),
          _NavItem(icon: Icons.receipt_long, label: 'Orders'),
          _NavItem(icon: Icons.person_outline, label: 'Profile'),
        ];
      case UserRole.customer:
      default:
        return const [
          _NavItem(icon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
          _NavItem(icon: Icons.receipt_outlined, label: 'Orders'),
          _NavItem(icon: Icons.person_outline, label: 'Profile'),
        ];
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: _futureRole,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _currentRole = snapshot.data ?? UserRole.customer;
        final pages = _getPagesForRole(_currentRole!);
        final navItems = _getNavItemsForRole(_currentRole!);

        // ── DESKTOP ADAPTATION START ──
        final bool isDesktop = MediaQuery.of(context).size.width >= 800;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppColors.prof,
            body: Row(
              children: [
                // Persistent left sidebar — replaces bottom nav on desktop
                _DesktopSidebar(
                  selectedIndex: _selectedIndex,
                  onIndexChanged: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  navItems: navItems,
                  onLogout: _logout,
                ),
                // Main content area — ClipRect prevents any overflow bleeding
                Expanded(child: ClipRect(child: pages[_selectedIndex])),
              ],
            ),
          );
        }
        // ── DESKTOP ADAPTATION END ──

        // Original mobile layout — unchanged
        return ResponsiveScaffold(
          currentIndex: _selectedIndex,
          onIndexChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          appBar: null,
          child: pages[_selectedIndex],
        );
      },
    );
  }
}

// ── DESKTOP ADAPTATION START ──
class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<_NavItem> navItems;
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
          // Logo area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Image.asset(
                'assets/images/swiftly-txt.png',
                width: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
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

          // Nav items
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final bool isActive = selectedIndex == index;
            return _SidebarNavTile(
              item: item,
              isActive: isActive,
              onTap: () => onIndexChanged(index),
            );
          }),

          const Spacer(),

          // Logout button at bottom
          _SidebarNavTile(
            item: const _NavItem(icon: Icons.logout_outlined, label: 'Logout'),
            isActive: false,
            onTap: onLogout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SidebarNavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarNavTile({
    required this.item,
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
          item.icon,
          color: isActive ? Colors.white : Colors.white60,
          size: 22,
        ),
        title: Text(
          item.label,
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

// Temporary placeholder screen for rider/store owner tabs that don't exist yet
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
// ── DESKTOP ADAPTATION END ──