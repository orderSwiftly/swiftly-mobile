// services/rider_order_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Models ──
class RiderOrderItem {
  final String name;
  final int quantity;
  final String storeName;

  const RiderOrderItem({
    required this.name,
    required this.quantity,
    required this.storeName,
  });

  factory RiderOrderItem.fromJson(Map<String, dynamic> json) => RiderOrderItem(
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    storeName: json['store_name'] as String,
  );
}

class RiderOrder {
  final String id;
  final String orderStatus;
  final List<RiderOrderItem> items;

  const RiderOrder({
    required this.id,
    required this.orderStatus,
    required this.items,
  });

  factory RiderOrder.fromJson(Map<String, dynamic> json) => RiderOrder(
    id: json['id'] as String,
    orderStatus: json['order_status'] as String,
    items: (json['items'] as List<dynamic>)
        .map((i) => RiderOrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
  );
}

class RiderOrdersResult {
  final List<RiderOrder> orders;
  final bool hasNext;
  final bool hasPrev;
  final int totalPages;
  final int currentPage;
  final int total;

  const RiderOrdersResult({
    required this.orders,
    required this.hasNext,
    required this.hasPrev,
    required this.totalPages,
    required this.currentPage,
    required this.total,
  });
}

// ── Service ──
class RiderOrderService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'https://your-api.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Get Rider Orders
  Future<RiderOrdersResult?> getRiderOrders({
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/v2/rider/orders').replace(
        queryParameters: {'status': status, 'page': '$page', 'limit': '$limit'},
      );

      print('Fetching rider orders from: $uri');
      print('With status: $status');

      final response = await http.get(uri, headers: headers);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final pagination = body['pagination'] as Map<String, dynamic>;

        return RiderOrdersResult(
          orders: (body['orders'] as List<dynamic>)
              .map((o) => RiderOrder.fromJson(o as Map<String, dynamic>))
              .toList(),
          hasNext: pagination['has_next'] as bool,
          hasPrev: pagination['has_prev'] as bool,
          totalPages: pagination['total_pages'] as int,
          currentPage: pagination['page'] as int,
          total: pagination['total'] as int,
        );
      } else {
        print('Failed to load rider orders: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching rider orders: $e');
      return null;
    }
  }

  // Claim Order - No body required
  Future<bool> claimOrder(String orderId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/v2/rider/$orderId/claim');

      print('Claiming order: $orderId');
      print('URI: $uri');

      final response = await http.patch(uri, headers: headers);

      print('Claim response status: ${response.statusCode}');
      print('Claim response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order $orderId claimed successfully');
        return true;
      } else if (response.statusCode == 409) {
        print('Order already claimed by another rider');
        return false;
      } else {
        print('Failed to claim order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error claiming order: $e');
      return false;
    }
  }

  // Unclaim Order - No body required
  Future<bool> unclaimOrder(String orderId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/v2/rider/$orderId/unclaim');

      print('Unclaiming order: $orderId');
      print('URI: $uri');

      final response = await http.patch(uri, headers: headers);

      print('Unclaim response status: ${response.statusCode}');
      print('Unclaim response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order $orderId unclaimed successfully');
        return true;
      } else {
        print('Failed to unclaim order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error unclaiming order: $e');
      return false;
    }
  }

  // Collect Order - No body required
  Future<bool> collectOrder(String orderId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final headers = {'Authorization': 'Bearer $token'};
      final uri = Uri.parse('$baseUrl/v2/rider/$orderId/collect');

      print('Collecting order: $orderId');
      print('URI: $uri');

      final response = await http.patch(uri, headers: headers);

      print('Collect response status: ${response.statusCode}');
      print('Collect response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order $orderId collected successfully');
        return true;
      } else {
        print('Failed to collect order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error collecting order: $e');
      return false;
    }
  }

  // Deliver Order - Requires delivery code in body
  Future<bool> deliverOrder(String orderId, String deliveryCode) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/v2/rider/$orderId/deliver');

      print('Delivering order: $orderId');
      print('URI: $uri');

      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode({'code': deliveryCode}),
      );

      print('Deliver response status: ${response.statusCode}');
      print('Deliver response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order $orderId delivered successfully');
        return true;
      } else if (response.statusCode == 429) {
        print('Order locked - too many failed attempts');
        return false;
      } else {
        print('Failed to deliver order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error delivering order: $e');
      return false;
    }
  }
}
