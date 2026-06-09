// core/guard/role_gate.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { customer, rider, storeOwner }

class RoleGate {
  static const String _roleKey = 'user_role';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Save user role after login (accepts UPPERCASE string from API)
  static Future<void> saveUserRole(String roleFromApi) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert UPPERCASE to lowercase for enum
    final roleLowercase = roleFromApi.toLowerCase();
    await prefs.setString(_roleKey, roleLowercase);
  }

  // Overload method to save from enum
  static Future<void> saveUserRoleFromEnum(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
  }

  // Get current user role
  static Future<UserRole?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_roleKey);
    if (roleString == null) return null;

    return UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.customer,
    );
  }

  // Save auth token after login
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Clear all session data on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Helper to convert API role string to enum
  static UserRole stringToRole(String role) {
    switch (role.toUpperCase()) {
      case 'RIDER':
        return UserRole.rider;
      case 'STORE_OWNER':
        return UserRole.storeOwner;
      case 'CUSTOMER':
      default:
        return UserRole.customer;
    }
  }

  // Helper to convert enum to uppercase string (for API if needed)
  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.rider:
        return 'RIDER';
      case UserRole.storeOwner:
        return 'STORE_OWNER';
      case UserRole.customer:
        return 'CUSTOMER';
    }
  }
}
