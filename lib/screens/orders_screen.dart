// screens/orders_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/customer_order_service.dart';
import '../widgets/order_header.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final CustomerOrderService _service = CustomerOrderService();

  OrdersResult? _result;
  bool _loading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getOrders(page: page);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _error = 'Failed to load orders. Please try again.';
        _loading = false;
      });
    } else {
      setState(() {
        _result = result;
        _currentPage = page;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        backgroundColor: AppColors.text,
        elevation: 0,
        automaticallyImplyLeading: !isDesktop,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: AppTypography.body.copyWith(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchOrders(page: _currentPage),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final result = _result;

    if (result == null || result.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: AppTypography.headline.copyWith(
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start shopping to see your orders',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return OrderHeader(
      orders: result.orders,
      hasNext: result.hasNext,
      hasPrev: result.hasPrev,
      currentPage: _currentPage,
      totalPages: result.totalPages,
      onNext: () => _fetchOrders(page: _currentPage + 1),
      onPrev: () => _fetchOrders(page: _currentPage - 1),
      onRefresh: () => _fetchOrders(page: _currentPage),
    );
  }
}