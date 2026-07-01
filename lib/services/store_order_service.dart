// services/store_order_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreOrderItem {
  final String id;
  final String name;
  final String price;
  final int quantity;
  final bool isPackaged;

  const StoreOrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isPackaged,
  });

  factory StoreOrderItem.fromJson(Map<String, dynamic> json) => StoreOrderItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as String,
    quantity: json['quantity'] as int,
    isPackaged: json['is_packaged'] as bool? ?? false,
  );
}

class StoreOrder {
  final String id;
  final String orderStatus;
  final List<StoreOrderItem> items;
  final double totalEarnings;

  const StoreOrder({
    required this.id,
    required this.orderStatus,
    required this.items,
    required this.totalEarnings,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) => StoreOrder(
    id: json['id'] as String,
    orderStatus: json['order_status'] as String,
    items: (json['items'] as List<dynamic>)
        .map((i) => StoreOrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    totalEarnings: (json['total_earnings'] as num).toDouble(),
  );
}

class StoreOrdersResult {
  final List<StoreOrder> orders;
  final bool hasNext;
  final bool hasPrev;
  final int totalPages;
  final int currentPage;
  final int total;

  const StoreOrdersResult({
    required this.orders,
    required this.hasNext,
    required this.hasPrev,
    required this.totalPages,
    required this.currentPage,
    required this.total,
  });
}

class StoreOrderService {
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

  // --------------------- Get Store Orders ---------------------
  Future<StoreOrdersResult?> getStoreOrders({
    required String storeId,
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/v2/store/$storeId/orders').replace(
        queryParameters: {'status': status, 'page': '$page', 'limit': '$limit'},
      );

      print('Fetching orders from: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final pagination = body['pagination'] as Map<String, dynamic>;
        print('Fetched store orders successfully: ${body['orders']}');

        return StoreOrdersResult(
          orders: (body['orders'] as List<dynamic>)
              .map((o) => StoreOrder.fromJson(o as Map<String, dynamic>))
              .toList(),
          hasNext: pagination['has_next'] as bool,
          hasPrev: pagination['has_prev'] as bool,
          totalPages: pagination['total_pages'] as int,
          currentPage: pagination['page'] as int,
          total: pagination['total'] as int,
        );
      } else {
        print('Failed to load store orders: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching store orders: $e');
      return null;
    }
  }

  // --------------------- Mark Item as Packaged ---------------------
  // --------------------- Mark Item as Packaged ---------------------
  Future<bool> markItemAsPackaged(String orderItemId) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/v2/orders/items/$orderItemId/packaged');

      print('Making PATCH request to: $uri');
      print('Order Item ID: $orderItemId');

      // Try with empty body first
      var response = await http.patch(uri, headers: headers);
      print('Attempt 1 - Empty body: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      }

      // Try with JSON body
      if (response.statusCode == 500) {
        print('Attempt 2 - With JSON body');
        response = await http.patch(
          uri,
          headers: headers,
          body: jsonEncode({'is_packaged': true}),
        );
        print('Attempt 2 - Response: ${response.statusCode}');

        if (response.statusCode == 200) {
          return true;
        }
      }

      print('All attempts failed. Final status: ${response.statusCode}');
      print('Final response: ${response.body}');
      return false;
    } catch (e) {
      print('Error marking item as packaged: $e');
      return false;
    }
  }
}
