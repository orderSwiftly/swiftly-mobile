// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/navbar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/profile_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

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

  String? getAvatarUrl() => _profile?['picture_url'];

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : Column(
              children: [
                // Top nav bar
                Container(
                  color: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const AppNavBar(),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  // ── DESKTOP ADAPTATION START ──
                  // Desktop: two-column layout inside a centered max-width container
                  // Left = avatar + name card, Right = menu items
                  // Mobile: original single-column list layout
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(isMobile),
                  // ── DESKTOP ADAPTATION END ──
                ),
              ],
            ),
    );
  }

  // ── DESKTOP ADAPTATION START ──
  // Desktop two-column profile layout
  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column — avatar card
              SizedBox(
                width: 260,
                child: Card(
                  color: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar circle
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                          backgroundImage: getAvatarUrl() != null
                              ? NetworkImage(getAvatarUrl()!)
                              : null,
                          child: getAvatarUrl() == null
                              ? Text(
                                  getUserInitials(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          getUserName(),
                          style: AppTypography.title.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Babcock University (Main)',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Logout button in the left card on desktop
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final authProviderNotifier = ref.read(
                                authProvider.notifier,
                              );
                              await authProviderNotifier.logout();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.logout,
                              size: 18,
                              color: AppColors.textError,
                            ),
                            label: Text(
                              'Logout',
                              style: AppTypography.button.copyWith(
                                color: AppColors.textError,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.textError.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Right column — menu items
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: AppTypography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(title: 'My Account', onTap: () {}),
                    _buildMenuItem(title: 'My Orders', onTap: () {}),
                    _buildMenuItem(title: 'My Addresses', onTap: () {}),
                    const SizedBox(height: 24),
                    Text(
                      'Preferences',
                      style: AppTypography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSwitchMenuItem(
                      title: 'Push Notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildMenuItem(title: 'Contact support', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── DESKTOP ADAPTATION END ──

  // Original mobile layout — unchanged
  Widget _buildMobileLayout(bool isMobile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              getUserName(),
              style: AppTypography.title.copyWith(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Babcock University (Main)',
              style: AppTypography.body.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Actions',
          style: AppTypography.title.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(title: 'My Account', onTap: () {}),
        _buildMenuItem(title: 'My Orders', onTap: () {}),
        _buildMenuItem(title: 'My Addresses', onTap: () {}),
        const SizedBox(height: 24),
        Text(
          'Preferences',
          style: AppTypography.title.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildSwitchMenuItem(
          title: 'Push Notifications',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildMenuItem(title: 'Contact support', onTap: () {}),
        const SizedBox(height: 32),
        if (isMobile)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                final authProviderNotifier = ref.read(authProvider.notifier);
                await authProviderNotifier.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Text(
                'Logout',
                style: AppTypography.button.copyWith(
                  color: AppColors.textError,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, color: AppColors.textHint),
      ],
    );
  }

  Widget _buildSwitchMenuItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
          onTap: () => onChanged(!value),
        ),
        const Divider(height: 1, color: AppColors.textHint),
      ],
    );
  }
}
