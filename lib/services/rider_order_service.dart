// services/rider_order_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RiderOrder {
  final String id;
  final String orderStatus;
  final String paymentStatus;
  final String? paymentResolvedAt;
  final String? landmarkDetails;

  const RiderOrder({
    required this.id,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentResolvedAt,
    this.landmarkDetails,
  });

  factory RiderOrder.fromJson(Map<String, dynamic> json) => RiderOrder(
    id: json['id'] as String,
    orderStatus: json['order_status'] as String,
    paymentStatus: json['payment_status'] as String,
    paymentResolvedAt: json['payment_resolved_at'] as String?,
    landmarkDetails: json['landmark_details'] as String?,
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

  // --------------------- Get Rider Orders ---------------------
  Future<RiderOrdersResult?> getRiderOrders({
    required String status, // 'PACKAGED', 'CLAIMED', 'COLLECTED', 'DELIVERED'
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/rider/orders').replace(
        queryParameters: {'status': status, 'page': '$page', 'limit': '$limit'},
      );

      print('Fetching rider orders from: $uri');
      print('With status: $status');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final pagination = body['pagination'] as Map<String, dynamic>;
        print('Fetched rider orders successfully: ${body['orders']}');

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

  // --------------------- Claim Order ---------------------
  Future<bool> claimOrder(String orderId) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/rider/orders/$orderId/claim');

      print('Claiming order: $orderId');
      final response = await http.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Order $orderId claimed successfully');
        return true;
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

  // --------------------- Collect Order ---------------------
  Future<bool> collectOrder(String orderId) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/rider/orders/$orderId/collect');

      print('Collecting order: $orderId');
      final response = await http.patch(uri, headers: headers);

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

  // --------------------- Deliver Order ---------------------
  Future<bool> deliverOrder(String orderId, String deliveryCode) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/rider/orders/$orderId/deliver');

      print('Delivering order: $orderId');
      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode({'delivery_code': deliveryCode}),
      );

      if (response.statusCode == 200) {
        print('Order $orderId delivered successfully');
        return true;
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
