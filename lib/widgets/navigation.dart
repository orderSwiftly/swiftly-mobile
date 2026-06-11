// widgets/navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class RoleNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const RoleNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<RoleNavItem> navItems;

  const AppNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? _buildBottomNavBar() : _buildSidebar(context);
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.text,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.primary,
      selectedLabelStyle: AppTypography.button.copyWith(fontSize: 12),
      unselectedLabelStyle: AppTypography.caption,
      items: navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.text,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              'Swiftly',
              style: AppTypography.headline.copyWith(color: AppColors.accent),
            ),
          ),
          Divider(height: 1, color: AppColors.textHint.withOpacity(0.3)),
          Expanded(
            child: Column(
              children: List.generate(
                navItems.length,
                (index) => _buildSidebarItem(
                  context: context,
                  item: navItems[index],
                  index: index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required RoleNavItem item,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: AppTypography.body.copyWith(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveScaffold extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final List<RoleNavItem> navItems;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.child,
    required this.navItems,
    this.appBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: appBar,
      body: isMobile
          ? child
          : Row(
              children: [
                AppNavigation(
                  selectedIndex: currentIndex,
                  onItemSelected: onIndexChanged,
                  navItems: navItems,
                ),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isMobile
          ? AppNavigation(
              selectedIndex: currentIndex,
              onItemSelected: onIndexChanged,
              navItems: navItems,
            )
          : null,
    );
  }
}
