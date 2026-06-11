// widgets/navbar.dart
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../core/theme/app_colors.dart';

class AppNavBar extends StatefulWidget {
  const AppNavBar({super.key});

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _profileService.fetchUserProfile();
    if (mounted) setState(() => _profile = data);
  }

  String? _validUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    if (!url.startsWith('http')) return null;
    return url;
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = _validUrl(_profile?['picture_url']);
    final String? name = _profile != null
        ? '${_profile!['first_name'] ?? ''} ${_profile!['last_name'] ?? ''}'
              .trim()
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.prof,
                size: 26,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '4',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary.withOpacity(0.2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
