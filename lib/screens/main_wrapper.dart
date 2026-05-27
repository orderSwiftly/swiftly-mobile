// screens/main_wrapper.dart
import 'package:flutter/material.dart';
import '../widgets/navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'dashboard_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            ),
            // Main content area — ClipRect prevents any overflow bleeding
            Expanded(child: ClipRect(child: _pages[_selectedIndex])),
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
      child: _pages[_selectedIndex],
    );
  }
}

// ── DESKTOP ADAPTATION START ──
class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
    _NavItem(icon: Icons.receipt_outlined, label: 'Orders'),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.prof, // dark green — white icons are visible on this
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FIX: Logo area — use enough height and correct padding
          // so the image actually renders and isn't clipped by SafeArea
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Image.asset(
                'assets/images/swiftly-txt.png',
                width: 140, // explicit width so the image isn't zero-sized
                fit: BoxFit.contain,
                // Fallback text in case asset path hasn't been verified
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
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            final bool isActive = selectedIndex == index;
            return _SidebarNavTile(
              item: item,
              isActive: isActive,
              onTap: () => onIndexChanged(index),
            );
          }),

          const Spacer(),

          // Settings pinned at the bottom
          const _SidebarNavTile(
            item: _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            isActive: false,
            onTap: null,
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
// ── DESKTOP ADAPTATION END ──