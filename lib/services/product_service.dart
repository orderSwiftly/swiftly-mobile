// services/product_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  // --------------------- Explore Products ---------------------
  Future<List<Map<String, dynamic>>> exploreProducts(String institution) async {
    try {
      // Get auth token from secure storage
      final authToken = await _storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/v2/explore/$institution'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load products: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
