// screens/orders_screen.dart

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/customer_order_service.dart';
import 'customers/order_card.dart';

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
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
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
            Text(
              _error!,
              style: AppTypography.body.copyWith(color: Colors.grey),
            ),
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

    final orders = _result?.orders ?? [];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: isDesktop ? 96 : 80,
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
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _fetchOrders(page: _currentPage),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: orders.length,
              itemBuilder: (_, i) => OrderCard(order: orders[i]),
            ),
          ),
        ),
        _PaginationBar(
          currentPage: _currentPage,
          totalPages: _result?.totalPages ?? 1,
          hasNext: _result?.hasNext ?? false,
          hasPrev: _result?.hasPrev ?? false,
          onNext: () => _fetchOrders(page: _currentPage + 1),
          onPrev: () => _fetchOrders(page: _currentPage - 1),
        ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.text,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Prev'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
