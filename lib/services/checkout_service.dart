// services/checkout_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/address.dart';
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

  Future<ListAddressesResponse> listAddresses(String store_zone_id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/addresses/$store_zone_id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ListAddressesResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load addresses: ${response.statusCode}');
    }
  }

  Future<CheckoutSummaryResponse> getCheckoutSummary(
    String store_zone_id,
    String address_zone_id,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/v2/checkout/$store_zone_id/summary?address_zone_id=$address_zone_id',
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

  Future<CheckoutResponse> createCheckout(
    String store_zone_id,
    String address_id,
    String address_zone_id,
    String? details,
  ) async {
    final headers = await _getHeaders();
    final body = json.encode({
      'address_id': address_id,
      'address_zone_id': address_zone_id,
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
