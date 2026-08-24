// widgets/order_header.dart

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/customer_order_service.dart';
import '../screens/customers/order_card.dart';

enum OrderTab { pending, active, passive }

extension OrderTabExt on OrderTab {
  String get label => switch (this) {
    OrderTab.pending => 'Pending',
    OrderTab.active => 'Active',
    OrderTab.passive => 'Passive',
  };

  bool matches(String status) => switch (this) {
    OrderTab.pending => status == 'AWAITING_PAYMENT',
    OrderTab.active => const {
      'PAID',
      'PREPARING',
      'READY',
      'IN_TRANSIT',
    }.contains(status),
    OrderTab.passive => const {
      'DELIVERED',
      'CANCELLED',
      'ABANDONED',
    }.contains(status),
  };
}

class OrderHeader extends StatefulWidget {
  final List<Order> orders;
  final bool hasNext;
  final bool hasPrev;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final Future<void> Function() onRefresh;

  const OrderHeader({
    super.key,
    required this.orders,
    required this.hasNext,
    required this.hasPrev,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onPrev,
    required this.onRefresh,
  });

  @override
  State<OrderHeader> createState() => _OrderHeaderState();
}

class _OrderHeaderState extends State<OrderHeader>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: OrderTab.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _filtered(OrderTab tab) =>
      widget.orders.where((o) => tab.matches(o.orderStatus)).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ──
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelStyle: AppTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTypography.body.copyWith(fontSize: 13),
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.accent,
            indicatorWeight: 2.5,
            tabs: OrderTab.values.map((tab) {
              final count = _filtered(tab).length;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tab.label),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      _CountBubble(count: count, isSelected: false),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // ── Tab views ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: OrderTab.values.map((tab) {
              final orders = _filtered(tab);
              return orders.isEmpty
                  ? _EmptyTab(tab: tab)
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: widget.onRefresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 16,
                              ),
                              itemCount: orders.length,
                              itemBuilder: (_, i) =>
                                  OrderCard(order: orders[i]),
                            ),
                          ),
                        ),
                        _PaginationBar(
                          currentPage: widget.currentPage,
                          totalPages: widget.totalPages,
                          hasNext: widget.hasNext,
                          hasPrev: widget.hasPrev,
                          onNext: widget.onNext,
                          onPrev: widget.onPrev,
                        ),
                      ],
                    );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Count bubble on tab ──
class _CountBubble extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _CountBubble({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.prof.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.waveClr,
        ),
      ),
    );
  }
}

// ── Per-tab empty state ──
class _EmptyTab extends StatelessWidget {
  final OrderTab tab;

  const _EmptyTab({required this.tab});

  ({IconData icon, String message}) get _copy => switch (tab) {
    OrderTab.pending => (
      icon: Icons.hourglass_empty_outlined,
      message: 'No pending orders',
    ),
    OrderTab.active => (
      icon: Icons.local_shipping_outlined,
      message: 'No active orders',
    ),
    OrderTab.passive => (
      icon: Icons.receipt_long_outlined,
      message: 'No past orders',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final c = _copy;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(c.icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(c.message, style: AppTypography.body.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Pagination bar ──
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
        color: Colors.white,
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
