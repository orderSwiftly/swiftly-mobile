import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RoleManager {
  static const String _roleKey = 'user_role';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  // Fixed: was .toString() which produces unreadable map string
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> isCustomer() async {
    final role = await getUserRole();
    return role?.toUpperCase() == 'CUSTOMER';
  }

  Future<bool> isRider() async {
    final role = await getUserRole();
    return role?.toUpperCase() == 'RIDER';
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }
}