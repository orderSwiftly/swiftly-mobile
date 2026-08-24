// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;

  AuthState({required this.status, this.user});
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _profileService = ProfileService();
  final _apiService = ApiService();

  @override
  Future<AuthState> build() async {
    // On app start — check if token exists
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      return AuthState(status: AuthStatus.unauthenticated);
    }

    // Token exists — fetch profile
    final profileData = await _profileService.fetchUserProfile();

    if (profileData == null) {
      // Token expired
      await _apiService.removeToken(); // Use your existing removeToken method
      return AuthState(status: AuthStatus.unauthenticated);
    }

    if (profileData['error'] == 'EMAIL_NOT_VERIFIED') {
      // Logged in but email not verified — handle in your nav
      return AuthState(status: AuthStatus.unauthenticated);
    }

    return AuthState(
      status: AuthStatus.authenticated,
      user: UserModel.fromJson(profileData),
    );
  }

  // Call this after ApiService.login() succeeds
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();

    final profileData = await _profileService.fetchUserProfile();

    if (profileData == null || profileData['error'] != null) {
      await _apiService.removeToken();
      state = AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    // MARK ONBOARDING AS COMPLETED WHEN PROFILE LOADS SUCCESSFULLY
    await _apiService.saveOnboardingCompleted();

    state = AsyncValue.data(
      AuthState(
        status: AuthStatus.authenticated,
        user: UserModel.fromJson(profileData),
      ),
    );
  }


  Future<void> logout() async {
    await _apiService.removeToken(); // Use your existing removeToken method
    state = AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);