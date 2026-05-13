import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Get API URL from .env file
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';

  // Helper method to format phone number with country code
  String _formatPhoneNumber(String phone, {String countryCode = '+234'}) {
    // Remove any spaces, dashes, or special characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If number doesn't start with +, add country code
    if (!cleaned.startsWith('+')) {
      // If number starts with 0, remove the 0
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      cleaned = '$countryCode$cleaned';
    }

    return cleaned;
  }

  // Signup function with snake_case parameters
  Future<Map<String, dynamic>> signup({
    required String first_name,
    required String last_name,
    required String email,
    required String password,
    required String confirm_password,
    required String phone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/customer/register');

      // Format phone number with country code
      final formattedPhone = _formatPhoneNumber(phone);

      final body = {
        'first_name': first_name,
        'last_name': last_name,
        'email': email,
        'password': password,
        'confirm_password': confirm_password,
        'phone': formattedPhone,
      };

      print('Sending to API: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to get error message from response body
        try {
          final errorData = jsonDecode(response.body);

          // Check for different error formats
          String errorMessage = 'Signup failed';

          // Handle your API's specific response format
          if (errorData['fields'] != null && errorData['fields'] is List) {
            // Get the first field error message
            final fields = errorData['fields'] as List;
            if (fields.isNotEmpty) {
              final firstError = fields[0];
              if (firstError['message'] != null) {
                errorMessage = firstError['message'];
              }
            }
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }

          // Also check for specific field errors in other formats
          if (errorMessage == 'Signup failed' && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is Map) {
              // Get first error message from map
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first;
              } else if (firstError is String) {
                errorMessage = firstError;
              }
            }
          }

          throw Exception(errorMessage);
        } catch (e) {
          // If can't parse JSON, throw status code error
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Login function
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/login');

      final body = {
        'email': email,
        'password': password,
      };

      print('Sending login request: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to get error message from response body
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Login failed';

          // Handle your API's specific response format
          if (errorData['fields'] != null && errorData['fields'] is List) {
            // Get the first field error message
            final fields = errorData['fields'] as List;
            if (fields.isNotEmpty) {
              final firstError = fields[0];
              if (firstError['message'] != null) {
                errorMessage = firstError['message'];
              }
            }
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }

          // Handle invalid credentials (401 Unauthorized)
          if (response.statusCode == 401) {
            errorMessage = 'Invalid email or password. Please try again.';
          }

          // Handle account not found
          if (errorMessage.toLowerCase().contains('not found') ||
              errorMessage.toLowerCase().contains("doesn't exist")) {
            errorMessage = 'No account found with this email. Please sign up first.';
          }

          throw Exception(errorMessage);
        } catch (e) {
          // If can't parse JSON, throw status code error
          if (response.statusCode == 401) {
            throw Exception('Invalid email or password. Please try again.');
          } else if (response.statusCode == 404) {
            throw Exception('Login service unavailable. Please try again later.');
          } else {
            throw Exception('Login failed: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Test/fake login for development (no real API call)
  Future<Map<String, dynamic>> fakeLogin({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Demo credentials for testing
    const demoEmail = 'user@example.com';
    const demoPassword = 'Password123!';

    // Validate credentials
    if (email != demoEmail) {
      throw Exception('No account found with this email. Please sign up first.');
    }
    
    if (password != demoPassword) {
      throw Exception('Invalid email or password. Please try again.');
    }

    // Return fake success response
    return {
      'success': true,
      'message': 'Login successful',
      'data': {
        'email': email,
        'name': 'Demo User',
      },
      'token': 'fake_token_12345',
    };
  }

  // Test/fake signup for development (no real API call)
  Future<Map<String, dynamic>> fakeSignup({
    required String first_name,
    required String last_name,
    required String email,
    required String password,
    required String confirm_password,
    required String phone,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Validate password confirmation
    if (password != confirm_password) {
      throw Exception('Passwords do not match');
    }

    // Format phone
    final formattedPhone = _formatPhoneNumber(phone);

    // Return fake success response
    return {
      'success': true,
      'message': 'Account created successfully',
      'data': {
        'first_name': first_name,
        'last_name': last_name,
        'email': email,
        'phone': formattedPhone,
      },
      'token': 'fake_token_12345',
    };
  }
}