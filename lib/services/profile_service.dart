// services/profile_service.dart
import 'dart:convert';
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
      case 'STORE_OWNER':
        return '$baseUrl/v2/profile/store-owner';
      case 'STAFF':
        return '$baseUrl/v2/profile/staff';
      case 'CUSTOMER':
      default:
        return '$baseUrl/v2/profile/customer';
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        print('No auth token found');
        return null;
      }

      final role = await _storage.read(key: 'user_role') ?? 'CUSTOMER';
      final endpoint = _profileEndpoint(role);

      print('🔑 Role from storage: $role');
      print('🌐 Fetching profile from: $endpoint');

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
      } else if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        return {'error': 'EMAIL_NOT_VERIFIED', 'message': errorData['message']};
      } else if (response.statusCode == 401) {
        print('Token expired, clearing storage');
        await _storage.delete(key: 'auth_token');
        return null;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
