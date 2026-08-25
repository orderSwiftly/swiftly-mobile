// services/staff_service.dart

// services/staff_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StaffService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // --------------------- List Staff ---------------------
  // status must be one of: ACTIVE, SUSPENDED, DISMISSED
  Future<Map<String, dynamic>> fetchStaff({
    required String storeId,
    required String status,
    String? roleId,
    String? staffId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
        if (roleId != null) 'role_id': roleId,
        if (staffId != null) 'staff_id': staffId,
      };

      final uri = Uri.parse(
        '$baseUrl/v2/store/$storeId/staffs',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _authHeaders());

      print('Fetch staff response status: ${response.statusCode}');
      print('Fetch staff response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load staff: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'staffs': [],
          'pagination': {
            'total': 0,
            'page': page,
            'limit': limit,
            'total_pages': 0,
            'has_next': false,
            'has_prev': false,
          },
        };
      }
    } catch (e) {
      print('Error fetching staff: $e');
      return {
        'staffs': [],
        'pagination': {
          'total': 0,
          'page': page,
          'limit': limit,
          'total_pages': 0,
          'has_next': false,
          'has_prev': false,
        },
      };
    }
  }

  // --------------------- Invite Staff ---------------------
  // Always sends a list, even for a single invite.
  Future<Map<String, dynamic>> inviteStaff({
    required String storeId,
    required List<Map<String, dynamic>> staffList,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/staff/invite');

      print('========== INVITE STAFF REQUEST ==========');
      print('URL: $url');
      print('BODY: $staffList');
      print('===========================================');

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(staffList),
      );

      print('Invite staff response status: ${response.statusCode}');
      print('Invite staff response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Failed to invite staff';

          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }

          if (response.statusCode == 400 &&
              errorData['invalid_role_ids'] != null) {
            errorMessage =
                'Some roles are invalid or do not belong to this store';
          }

          if (response.statusCode == 409 && errorData['conflicts'] != null) {
            errorMessage = 'Some staff details are already in use';
          }

          throw Exception(errorMessage);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Failed to invite staff: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Suspend Staff ---------------------
  Future<bool> suspendStaff({
    required String storeId,
    required String staffId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/staff/$staffId/suspend');

      final response = await http.patch(url, headers: await _authHeaders());

      print('Suspend staff response status: ${response.statusCode}');
      print('Suspend staff response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to suspend staff');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Reinstate Staff ---------------------
  Future<bool> reinstateStaff({
    required String storeId,
    required String staffId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/staff/$staffId/reinstate');

      final response = await http.patch(url, headers: await _authHeaders());

      print('Reinstate staff response status: ${response.statusCode}');
      print('Reinstate staff response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reinstate staff');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Dismiss Staff ---------------------
  // NOTE: This is permanent and cannot be undone.
  // The calling UI must confirm this action (e.g. require the staff
  // member's email to be typed in) before calling this method.
  Future<bool> dismissStaff({
    required String storeId,
    required String staffId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/staff/$staffId/dismiss');

      final response = await http.patch(url, headers: await _authHeaders());

      print('Dismiss staff response status: ${response.statusCode}');
      print('Dismiss staff response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to dismiss staff');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- List Roles ---------------------
  Future<Map<String, dynamic>> fetchRoles({
    required String storeId,
    String? roleId,
    bool showStaff = false,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (roleId != null) 'role_id': roleId,
        if (showStaff) 'show_staff': 'true',
      };

      final uri = Uri.parse(
        '$baseUrl/v2/store/$storeId/roles',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _authHeaders());

      print('Fetch roles response status: ${response.statusCode}');
      print('Fetch roles response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load roles: ${response.statusCode}');
        return {
          'roles': [],
          'pagination': {
            'total': 0,
            'page': page,
            'limit': limit,
            'total_pages': 0,
            'has_next': false,
            'has_prev': false,
          },
        };
      }
    } catch (e) {
      print('Error fetching roles: $e');
      return {
        'roles': [],
        'pagination': {
          'total': 0,
          'page': page,
          'limit': limit,
          'total_pages': 0,
          'has_next': false,
          'has_prev': false,
        },
      };
    }
  }

  // --------------------- Assign / Revoke Role ---------------------
  // Pass roleId = null to revoke the staff member's current role.
  Future<bool> assignRole({
    required String storeId,
    required String staffId,
    required String? roleId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/staff/$staffId/role');

      final response = await http.patch(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'role_id': roleId}),
      );

      print('Assign role response status: ${response.statusCode}');
      print('Assign role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to assign role');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- List Permissions ---------------------
  Future<List<Map<String, dynamic>>> fetchPermissions({
    required String storeId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/store/$storeId/staff-permissions'),
        headers: await _authHeaders(),
      );

      print('Fetch permissions response status: ${response.statusCode}');
      print('Fetch permissions response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> permissions = data['permissions'] ?? [];
        return permissions.cast<Map<String, dynamic>>();
      } else {
        print('Failed to load permissions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching permissions: $e');
      return [];
    }
  }

  // --------------------- Create Role ---------------------
  // permissions must include every permission key the system supports,
  // each explicitly set to true or false.
  Future<Map<String, dynamic>> createRole({
    required String storeId,
    required String name,
    required Map<String, bool> permissions,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/role');

      final body = {'name': name, 'permissions': permissions};

      print('========== CREATE ROLE REQUEST ==========');
      print('URL: $url');
      print('BODY: $body');
      print('==========================================');

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      print('Create role response status: ${response.statusCode}');
      print('Create role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to create role';

        if (errorData['fields'] != null && errorData['fields'] is List) {
          final fields = errorData['fields'] as List;
          if (fields.isNotEmpty && fields[0]['message'] != null) {
            errorMessage = fields[0]['message'];
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Edit Role ---------------------
  // name is compulsory even if unchanged. permissions must include
  // every permission key the system supports.
  Future<Map<String, dynamic>> editRole({
    required String storeId,
    required String roleId,
    required String name,
    required Map<String, bool> permissions,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/role/$roleId');

      final body = {'name': name, 'permissions': permissions};

      print('========== EDIT ROLE REQUEST ==========');
      print('URL: $url');
      print('BODY: $body');
      print('========================================');

      final response = await http.patch(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      print('Edit role response status: ${response.statusCode}');
      print('Edit role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to edit role';

        if (errorData['fields'] != null && errorData['fields'] is List) {
          final fields = errorData['fields'] as List;
          if (fields.isNotEmpty && fields[0]['message'] != null) {
            errorMessage = fields[0]['message'];
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Delete Role ---------------------
  // Any staff assigned to this role simply lose the role (they are
  // not suspended or dismissed). If you want to warn the owner about
  // affected staff first, call fetchRoles(showStaff: true) yourself
  // before calling this — the backend does not hold this back for
  // confirmation.
  Future<bool> deleteRole({
    required String storeId,
    required String roleId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/v2/store/$storeId/role/$roleId');

      final response = await http.delete(url, headers: await _authHeaders());

      print('Delete role response status: ${response.statusCode}');
      print('Delete role response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete role');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // --------------------- Staff Profile ---------------------
  // Call this right after staff login to populate the dashboard.
  // If the staff member has been dismissed, this returns a 403 and
  // the exception message should be treated as a hard stop — kick
  // them back to the login screen rather than rendering a dashboard.
  Future<Map<String, dynamic>> fetchStaffProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v2/profile/staff'),
        headers: await _authHeaders(),
      );

      print('Staff profile response status: ${response.statusCode}');
      print('Staff profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load staff profile');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
