// services/category_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';

  // --------------------- Fetch Categories ---------------------
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> categories = data['categories'] ?? [];
        return categories.cast<String>();
      } else {
        print('Failed to load categories: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}