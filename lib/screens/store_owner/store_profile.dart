// screens/store_owner/store_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/profile_service.dart';
import '../../providers/auth_provider.dart';
import 'selecting_stores_screen.dart';

class StoreProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOrdersTap;

  const StoreProfileScreen({super.key, this.onOrdersTap});

  @override
  ConsumerState<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends ConsumerState<StoreProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String? _activeStoreId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        _profileService.fetchUserProfile(),
        _storage.read(key: 'active_store_id'),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _activeStoreId = results[1] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading store profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _ownerName {
    if (_profile == null) return 'Store Owner';
    final first = _profile!['first_name'] ?? '';
    final last = (_profile!['last_name'] ?? '').toString().trim();
    if (first.isNotEmpty && last.isNotEmpty && last != '.') {
      return '$first $last';
    }
    if (first.isNotEmpty) return first;
    return 'Store Owner';
  }

  String get _ownerInitials {
    final first = _profile?['first_name'] ?? '';
    final last = (_profile?['last_name'] ?? '').toString().trim();
    if (first.isNotEmpty && last.isNotEmpty && last != '.') {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first[0].toUpperCase();
    return 'S';
  }

  String? get _avatarUrl => _profile?['picture_url'];
  String get _email => _profile?['email'] ?? '';

  List<Map<String, dynamic>> get _stores {
    final raw = _profile?['owned_stores'];
    if (raw == null) return [];
    return (raw as List).map((s) => Map<String, dynamic>.from(s)).toList();
  }

  Map<String, dynamic>? get _activeStore {
    if (_activeStoreId == null) {
      return _stores.isNotEmpty ? _stores.first : null;
    }
    return _stores.firstWhere(
      (s) => s['store_id'] == _activeStoreId,
      orElse: () => _stores.isNotEmpty ? _stores.first : {},
    );
  }

  String _formatInstitution(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _logout() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _switchStore() {
    if (_stores.length <= 1) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectingStoresScreen(
          stores: _stores,
          onStoreSelected: () {
            Navigator.pop(context);
            _loadProfile();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.text,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : Column(
              children: [
                // ── Top bar ──
                Container(
                  color: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 20),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — owner card
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
                        _AvatarCircle(
                          initials: _ownerInitials,
                          avatarUrl: _avatarUrl,
                          radius: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _ownerName,
                          style: AppTypography.title.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
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

              // Right — active store + all stores + actions + preferences
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActiveStoreBanner(
                      store: _activeStore,
                      formatInstitution: _formatInstitution,
                      canSwitch: _stores.length > 1,
                      onSwitch: _switchStore,
                    ),

                    const SizedBox(height: 24),

                    if (_stores.length > 1) ...[
                      Text(
                        'All Stores',
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._stores.map(
                        (store) => _StoreCard(
                          store: store,
                          isActive: store['store_id'] == _activeStoreId,
                          formatInstitution: _formatInstitution,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Actions ──
                    Text(
                      'Actions',
                      style: AppTypography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      title: 'My Orders',
                      onTap: () => widget.onOrdersTap?.call(),
                    ),

                    const SizedBox(height: 24),

                    // ── Preferences ──
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
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    _buildMenuItem(title: 'Contact Support', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Owner identity row
        Row(
          children: [
            _AvatarCircle(
              initials: _ownerInitials,
              avatarUrl: _avatarUrl,
              radius: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ownerName,
                    style: AppTypography.title.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (_email.isNotEmpty)
                    Text(
                      _email,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Active store banner
        _ActiveStoreBanner(
          store: _activeStore,
          formatInstitution: _formatInstitution,
          canSwitch: _stores.length > 1,
          onSwitch: _switchStore,
        ),

        // All stores list — only if more than one
        if (_stores.length > 1) ...[
          const SizedBox(height: 20),
          Text(
            'All Stores',
            style: AppTypography.title.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ..._stores.map(
            (store) => _StoreCard(
              store: store,
              isActive: store['store_id'] == _activeStoreId,
              formatInstitution: _formatInstitution,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Actions ──
        Text(
          'Actions',
          style: AppTypography.title.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          title: 'My Orders',
          onTap: () => widget.onOrdersTap?.call(),
        ),

        const SizedBox(height: 24),

        // ── Preferences ──
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
          onChanged: (v) => setState(() => _notificationsEnabled = v),
        ),
        _buildMenuItem(title: 'Contact Support', onTap: () {}),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _logout,
            child: Text(
              'Logout',
              style: AppTypography.button.copyWith(color: AppColors.textError),
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

// ── Active store banner ──
class _ActiveStoreBanner extends StatelessWidget {
  final Map<String, dynamic>? store;
  final String Function(String) formatInstitution;
  final bool canSwitch;
  final VoidCallback onSwitch;

  const _ActiveStoreBanner({
    required this.store,
    required this.formatInstitution,
    required this.canSwitch,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    if (store == null || store!.isEmpty) return const SizedBox.shrink();

    final String? storePicture = store!['store_picture'];
    final String storeName = store!['store_name'] ?? 'Store';
    final String storeAddress = store!['store_address'] ?? '';
    final String institution = formatInstitution(
      store!['store_institution'] ?? '',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: storePicture != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(storePicture, fit: BoxFit.cover),
                  )
                : Icon(Icons.store_rounded, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        storeName,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (storeAddress.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    storeAddress,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (institution.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    institution,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (canSwitch) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSwitch,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Switch',
                  style: AppTypography.body.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Store card (all stores list) ──
class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final bool isActive;
  final String Function(String) formatInstitution;

  const _StoreCard({
    required this.store,
    required this.isActive,
    required this.formatInstitution,
  });

  @override
  Widget build(BuildContext context) {
    final String? storePicture = store['store_picture'];
    final String storeName = store['store_name'] ?? 'Store';
    final String storeAddress = store['store_address'] ?? '';
    final String institution = formatInstitution(
      store['store_institution'] ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
            backgroundImage: storePicture != null
                ? NetworkImage(storePicture)
                : null,
            child: storePicture == null
                ? Text(
                    storeName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                if (storeAddress.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    storeAddress,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (institution.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    institution,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isActive)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accent,
              size: 20,
            )
          else
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

// ── Avatar circle ──
class _AvatarCircle extends StatelessWidget {
  final String initials;
  final String? avatarUrl;
  final double radius;

  const _AvatarCircle({
    required this.initials,
    required this.avatarUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.65,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            )
          : null,
    );
  }
}
