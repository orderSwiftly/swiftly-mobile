// services/cart_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Track in-flight DELETE requests to prevent duplicates
  static final Set<String> _pendingDeletes = {};

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
        return jsonDecode(response.body);
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

  Future<Map<String, dynamic>?> updateCartItem(
    String productId,
    String action,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/v2/cart/$productId/update'),
        headers: headers,
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to update cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating cart: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> setCartQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/v2/cart/$productId/quantity'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to set quantity: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error setting quantity: $e');
      return null;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    // If a delete for this product is already in flight, skip it
    if (_pendingDeletes.contains(productId)) {
      print('DELETE already in flight for $productId, skipping.');
      return false;
    }

    _pendingDeletes.add(productId);

    try {
      final headers = await _getHeaders();
      print('Headers being sent: $headers');
      print('Attempting DELETE for product_id: "$productId"');

      final response = await http.delete(
        Uri.parse('$baseUrl/v2/cart/$productId'),
        headers: headers,
      );

      print('Remove from cart response status: ${response.statusCode}');
      print('Remove from cart response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove from cart: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    } finally {
      _pendingDeletes.remove(productId);
    }
  }
}