import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _profileEndpoint(String role) {
    switch (role.toUpperCase()) {
      case 'RIDER':
        return '$baseUrl/v2/profile/rider';
      case 'CUSTOMER':
        return '$baseUrl/v2/profile/customer';
      case 'STAFF':
        return '$baseUrl/v2/profile/staff';
      case 'STORE_OWNER':
        return '$baseUrl/v2/profile/store-owner';
      default:
        return '$baseUrl/v2/profile/customer';
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      // Retry up to 10 times with 500ms delay — handles race on first load
      String? token;
      for (int i = 0; i < 10; i++) {
        token = await _storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (token == null || token.isEmpty) {
        print('No auth token found after retries');
        return null;
      }

      print(
        'Token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );

      final role = await _storage.read(key: 'user_role') ?? 'CUSTOMER';
      final endpoint = _profileEndpoint(role);

      print('Fetching profile from: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token might be expired, clear it
        print('Token expired, clearing storage');
        await _storage.delete(key: 'auth_token');
        return null;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}