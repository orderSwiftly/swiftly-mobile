// the code for the navigation widget, which includes both a bottom navigation bar for mobile and a sidebar for larger screens. It also includes a responsive scaffold wrapper to handle the layout based on screen size.

// widgets/navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';

class AppNavigation extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.fetchUserProfile();
      if (mounted) {
        setState(() {
          _profile = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String getUserName() {
    if (_profile == null) return 'User';
    final firstName = _profile?['first_name'] ?? '';
    final lastName = _profile?['last_name'] ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    if (firstName.isNotEmpty) return firstName;
    if (lastName.isNotEmpty) return lastName;
    return 'User';
  }

  String getUserEmail() {
    return _profile?['email'] ?? 'user@example.com';
  }

  String getUserInitials() {
    final firstName = _profile?['first_name'] ?? '';
    final lastName = _profile?['last_name'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (lastName.isNotEmpty) return lastName[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return _buildBottomNavBar(context);
    } else {
      return _buildSidebar(context);
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemSelected,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.text,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.primary,
      selectedLabelStyle: AppTypography.button.copyWith(fontSize: 12),
      unselectedLabelStyle: AppTypography.caption,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
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
              children: [
                _buildSidebarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Cart',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.receipt_outlined,
                  activeIcon: Icons.receipt,
                  label: 'Orders',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.textHint.withOpacity(0.3)),
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.prof,
                        child: Text(
                          getUserInitials(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getUserName(),
                        style: AppTypography.title.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getUserEmail(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final authProviderNotifier = ref.read(
                            authProvider.notifier,
                          );
                          await authProviderNotifier.logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        icon: Icon(
                          Icons.logout,
                          size: 18,
                          color: AppColors.textError,
                        ),
                        label: Text(
                          'Logout',
                          style: AppTypography.button.copyWith(
                            fontSize: 14,
                            color: AppColors.textError,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textError.withOpacity(0.1),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
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
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
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

// Responsive Scaffold wrapper
class ResponsiveScaffold extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final Widget child;
  final PreferredSizeWidget? appBar;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.child,
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
                ),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isMobile
          ? AppNavigation(
              selectedIndex: currentIndex,
              onItemSelected: onIndexChanged,
            )
          : null,
    );
  }
}