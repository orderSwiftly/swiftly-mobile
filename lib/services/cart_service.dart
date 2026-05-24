// services/cart_service.dart - Keep only what you need
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get auth token from secure storage
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // --------------------- Fetch Cart Items ---------------------
  Future<List<Map<String, dynamic>>> fetchCart() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/v2/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  // --------------------- Add to Cart ---------------------
  Future<Map<String, dynamic>?> addToCart(
    String productId, {
    int quantity = 1,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/v2/cart/$productId'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Added to cart successfully: $data');
        return data;
      } else {
        print('Failed to add to cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  // --------------------- Set Cart Item Quantity (PATCH) ---------------------
  Future<Map<String, dynamic>?> setCartQuantity(
    String productId, // Now accepts UUID, not name
    int quantity,
  ) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse('$baseUrl/v2/cart/$productId/quantity'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to set quantity: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error setting quantity: $e');
      return null;
    }
  }

  // --------------------- Remove from Cart ---------------------
  Future<bool> removeFromCart(String productName) async {
    try {
      final headers = await _getHeaders();

      // URL encode the product name
      final encodedName = Uri.encodeComponent(productName);

      final response = await http.delete(
        Uri.parse('$baseUrl/v2/cart/$encodedName'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Removed from cart successfully');
        return true;
      } else {
        print('Failed to remove from cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }
}