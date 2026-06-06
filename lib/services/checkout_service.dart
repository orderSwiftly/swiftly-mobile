// services/checkout_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/landmark.dart';
import '../models/checkout.dart';

class CheckoutService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Changed: method name and endpoint
  Future<ListLandmarksResponse> listLandmarks(String store_zone_id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/landmarks/$store_zone_id'), // Changed endpoint
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ListLandmarksResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load landmarks: ${response.statusCode}');
    }
  }

  // Changed: parameter name from address_zone_id to landmark_zone_id
  Future<CheckoutSummaryResponse> getCheckoutSummary(
    String store_zone_id,
    String landmark_zone_id, // Changed parameter name
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/v2/checkout/$store_zone_id/summary?landmark_zone_id=$landmark_zone_id', // Changed query param
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return CheckoutSummaryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load checkout summary: ${response.statusCode}',
      );
    }
  }

  // Changed: parameter names from address_* to landmark_*
  Future<CheckoutResponse> createCheckout(
    String store_zone_id,
    String landmark_id, // Changed from address_id
    String landmark_zone_id, // Changed from address_zone_id
    String? details,
  ) async {
    final headers = await _getHeaders();
    final body = json.encode({
      'landmark_id': landmark_id, // Changed key name
      'landmark_zone_id': landmark_zone_id, // Changed key name
      'details': details ?? '',
    });

    final response = await http.post(
      Uri.parse('$baseUrl/v2/checkout/$store_zone_id'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return CheckoutResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ??
            'Checkout failed - some items may be out of stock',
      );
    } else {
      throw Exception('Failed to create checkout: ${response.statusCode}');
    }
  }
}
