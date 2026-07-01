// services/customer_order_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderItem {
  final String name;
  final String price;
  final int quantity;
  final String storeName;
  final bool isPackaged;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.storeName,
    required this.isPackaged,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: json['name'] as String,
    price: json['price'] as String,
    quantity: json['quantity'] as int,
    storeName: json['store_name'] as String? ?? '',
    isPackaged: json['is_packaged'] as bool? ?? false,
  );
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final String orderStatus;
  final String? deliveryCode;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderStatus,
    this.deliveryCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    items: (json['items'] as List<dynamic>)
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    total: (json['total'] as num).toDouble(),
    orderStatus: json['order_status'] as String,
    deliveryCode: json['delivery_code'] as String?,
  );
}

class OrdersResult {
  final List<Order> orders;
  final bool hasNext;
  final bool hasPrev;
  final int totalPages;
  final int currentPage;

  const OrdersResult({
    required this.orders,
    required this.hasNext,
    required this.hasPrev,
    required this.totalPages,
    required this.currentPage,
  });
}

class CustomerOrderService {
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

  // --------------------- Get Orders ---------------------
  Future<OrdersResult?> getOrders({int page = 1, int limit = 10}) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse(
        '$baseUrl/v2/customer/orders',
      ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final pagination = body['pagination'] as Map<String, dynamic>;

        return OrdersResult(
          orders: (body['orders'] as List<dynamic>)
              .map((o) => Order.fromJson(o as Map<String, dynamic>))
              .toList(),
          hasNext: pagination['has_next'] as bool,
          hasPrev: pagination['has_prev'] as bool,
          totalPages: pagination['total_pages'] as int,
          currentPage: pagination['page'] as int,
        );
      } else {
        print('Failed to load orders: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return null;
    }
  }

  // --------------------- Get Order Details ---------------------
  Future<Order?> getOrderDetails(String orderId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/v2/customer/order/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Order.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('Failed to load order $orderId: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }
}
