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

  String? getAvatarUrl() {
    return _profile?['picture_url'];
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.text,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : Column(
              children: [
                // Top Navigation Bar with Bell and Avatar
                Container(
                  color: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
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
                        const AppNavBar(), // Bell icon and avatar
                      ],
                    ),
                  ),
                ),

                // Profile Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Profile Header
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

                      // Actions Section
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

                      // Preferences Section
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

                      // Logout Button (only for mobile, desktop has it in sidebar)
                      if (isMobile)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
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
                            child: Text(
                              'Logout',
                              style: AppTypography.button.copyWith(
                                color: AppColors.textError,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
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
            activeColor: AppColors.accent,
          ),
          onTap: () => onChanged(!value),
        ),
        const Divider(height: 1, color: AppColors.textHint),
      ],
    );
  }
}