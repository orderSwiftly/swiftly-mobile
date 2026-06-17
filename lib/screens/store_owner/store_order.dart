// screens/store_owner/store_order.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/store_order_service.dart';

class StoreOrderScreen extends StatefulWidget {
  const StoreOrderScreen({super.key});

  @override
  State<StoreOrderScreen> createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends State<StoreOrderScreen>
    with SingleTickerProviderStateMixin {
  final StoreOrderService _service = StoreOrderService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final TabController _tabController;

  // PAID tab state
  StoreOrdersResult? _paidResult;
  bool _paidLoading = true;
  String? _paidError;
  int _paidPage = 1;

  // PACKAGED tab state
  StoreOrdersResult? _packagedResult;
  bool _packagedLoading = true;
  String? _packagedError;
  int _packagedPage = 1;

  String? _storeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _storeId = await _storage.read(key: 'active_store_id');
    if (_storeId == null) {
      setState(() {
        _paidLoading = false;
        _packagedLoading = false;
        _paidError = 'No active store selected.';
        _packagedError = 'No active store selected.';
      });
      return;
    }
    await Future.wait([_fetchPaid(), _fetchPackaged()]);
  }

  Future<void> _fetchPaid({int page = 1}) async {
    setState(() {
      _paidLoading = true;
      _paidError = null;
    });

    final result = await _service.getStoreOrders(
      storeId: _storeId!,
      status: 'PAID',
      page: page,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _paidError = 'Failed to load new orders.';
        _paidLoading = false;
      });
    } else {
      setState(() {
        _paidResult = result;
        _paidPage = page;
        _paidLoading = false;
      });
    }
  }

  Future<void> _fetchPackaged({int page = 1}) async {
    setState(() {
      _packagedLoading = true;
      _packagedError = null;
    });

    final result = await _service.getStoreOrders(
      storeId: _storeId!,
      status: 'PACKAGED',
      page: page,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _packagedError = 'Failed to load packaged orders.';
        _packagedLoading = false;
      });
    } else {
      setState(() {
        _packagedResult = result;
        _packagedPage = page;
        _packagedLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          // ── Top bar ──
          Container(
            color: AppColors.text,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  // Refresh both tabs
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: () {
                      _fetchPaid(page: _paidPage);
                      _fetchPackaged(page: _packagedPage);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Tab bar ──
          Container(
            color: AppColors.text,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.accent,
              indicatorWeight: 2.5,
              labelStyle: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.body.copyWith(fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('New Orders'),
                      if ((_paidResult?.total ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        _CountBubble(count: _paidResult!.total),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Packaged'),
                      if ((_packagedResult?.total ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        _CountBubble(count: _packagedResult!.total),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Tab views ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // New orders tab
                _OrdersTab(
                  loading: _paidLoading,
                  error: _paidError,
                  result: _paidResult,
                  currentPage: _paidPage,
                  emptyIcon: Icons.inbox_outlined,
                  emptyMessage: 'No new orders yet',
                  onRetry: () => _fetchPaid(page: _paidPage),
                  onRefresh: () => _fetchPaid(page: _paidPage),
                  onNext: () => _fetchPaid(page: _paidPage + 1),
                  onPrev: () => _fetchPaid(page: _paidPage - 1),
                  orderCardBuilder: (order) => _StoreOrderCard(
                    order: order,
                    actionLabel: 'Mark as Packaged',
                    actionColor: AppColors.accent,
                    onAction: () {
                      // TODO: wire PATCH endpoint to mark packaged
                    },
                  ),
                ),

                // Packaged tab
                _OrdersTab(
                  loading: _packagedLoading,
                  error: _packagedError,
                  result: _packagedResult,
                  currentPage: _packagedPage,
                  emptyIcon: Icons.inventory_2_outlined,
                  emptyMessage: 'No packaged orders waiting',
                  onRetry: () => _fetchPackaged(page: _packagedPage),
                  onRefresh: () => _fetchPackaged(page: _packagedPage),
                  onNext: () => _fetchPackaged(page: _packagedPage + 1),
                  onPrev: () => _fetchPackaged(page: _packagedPage - 1),
                  orderCardBuilder: (order) => _StoreOrderCard(
                    order: order,
                    actionLabel: null, // waiting for rider — no store action
                    actionColor: null,
                    onAction: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable tab body ──
class _OrdersTab extends StatelessWidget {
  final bool loading;
  final String? error;
  final StoreOrdersResult? result;
  final int currentPage;
  final IconData emptyIcon;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final Widget Function(StoreOrder order) orderCardBuilder;

  const _OrdersTab({
    required this.loading,
    required this.error,
    required this.result,
    required this.currentPage,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onRetry,
    required this.onRefresh,
    required this.onNext,
    required this.onPrev,
    required this.orderCardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              error!,
              style: AppTypography.body.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
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

    final orders = result?.orders ?? [];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: AppTypography.body.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: orders.length,
              itemBuilder: (_, i) => orderCardBuilder(orders[i]),
            ),
          ),
        ),
        if ((result?.totalPages ?? 1) > 1)
          _PaginationBar(
            currentPage: currentPage,
            totalPages: result!.totalPages,
            hasNext: result!.hasNext,
            hasPrev: result!.hasPrev,
            onNext: onNext,
            onPrev: onPrev,
          ),
      ],
    );
  }
}

// ── Order card ──
class _StoreOrderCard extends StatelessWidget {
  final StoreOrder order;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;

  const _StoreOrderCard({
    required this.order,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '₦${order.totalEarnings.toStringAsFixed(2)}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Items ──
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.body.copyWith(fontSize: 14),
                      ),
                    ),
                    Text(
                      '₦${(double.parse(item.price) * item.quantity).toStringAsFixed(2)}',
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action button ──
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // ── Packaged tab — waiting for rider note ──
            if (actionLabel == null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Waiting for rider to claim',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Count bubble ──
class _CountBubble extends StatelessWidget {
  final int count;

  const _CountBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.prof.withOpacity(0.12),
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
