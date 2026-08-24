// screens/riders/rider_delivery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/rider_order_service.dart';
import '../../widgets/rider_tabs.dart';
import '../../widgets/rider_btn.dart';

class RiderDeliveryScreen extends StatefulWidget {
  const RiderDeliveryScreen({super.key});

  @override
  State<RiderDeliveryScreen> createState() => _RiderDeliveryScreenState();
}

class _RiderDeliveryScreenState extends State<RiderDeliveryScreen>
    with SingleTickerProviderStateMixin {
  final RiderOrderService _service = RiderOrderService();

  late final TabController _tabController;

  // PENDING tab (PACKAGED)
  RiderOrdersResult? _pendingResult;
  bool _pendingLoading = true;
  String? _pendingError;
  int _pendingPage = 1;

  // ACTIVE tab (CLAIMED + COLLECTED)
  RiderOrdersResult? _claimedResult;
  bool _claimedLoading = true;
  String? _claimedError;
  int _claimedPage = 1;

  RiderOrdersResult? _collectedResult;
  bool _collectedLoading = true;
  String? _collectedError;
  int _collectedPage = 1;

  // DELIVERED tab
  RiderOrdersResult? _deliveredResult;
  bool _deliveredLoading = true;
  String? _deliveredError;
  int _deliveredPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.wait([
      _fetchPending(),
      _fetchClaimed(),
      _fetchCollected(),
      _fetchDelivered(),
    ]);
  }

  Future<void> _fetchPending({int page = 1}) async {
    setState(() {
      _pendingLoading = true;
      _pendingError = null;
    });

    final result = await _service.getRiderOrders(
      status: 'PACKAGED',
      page: page,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _pendingError = 'Failed to load available orders.';
        _pendingLoading = false;
      });
    } else {
      setState(() {
        _pendingResult = result;
        _pendingPage = page;
        _pendingLoading = false;
      });
    }
  }

  Future<void> _fetchClaimed({int page = 1}) async {
    setState(() {
      _claimedLoading = true;
      _claimedError = null;
    });

    final result = await _service.getRiderOrders(status: 'CLAIMED', page: page);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _claimedError = 'Failed to load claimed orders.';
        _claimedLoading = false;
      });
    } else {
      setState(() {
        _claimedResult = result;
        _claimedPage = page;
        _claimedLoading = false;
      });
    }
  }

  Future<void> _fetchCollected({int page = 1}) async {
    setState(() {
      _collectedLoading = true;
      _collectedError = null;
    });

    final result = await _service.getRiderOrders(
      status: 'COLLECTED',
      page: page,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _collectedError = 'Failed to load collected orders.';
        _collectedLoading = false;
      });
    } else {
      setState(() {
        _collectedResult = result;
        _collectedPage = page;
        _collectedLoading = false;
      });
    }
  }

  Future<void> _fetchDelivered({int page = 1}) async {
    setState(() {
      _deliveredLoading = true;
      _deliveredError = null;
    });

    final result = await _service.getRiderOrders(
      status: 'DELIVERED',
      page: page,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _deliveredError = 'Failed to load delivered orders.';
        _deliveredLoading = false;
      });
    } else {
      setState(() {
        _deliveredResult = result;
        _deliveredPage = page;
        _deliveredLoading = false;
      });
    }
  }

  void _refreshAll() {
    _fetchPending(page: _pendingPage);
    _fetchClaimed(page: _claimedPage);
    _fetchCollected(page: _collectedPage);
    _fetchDelivered(page: _deliveredPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          // Top bar
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
                    'Deliveries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: _refreshAll,
                  ),
                ],
              ),
            ),
          ),

          // Tab bar
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
                      const Text('Pending'),
                      if ((_pendingResult?.total ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        CountBubble(count: _pendingResult!.total),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Active'),
                      if (((_claimedResult?.total ?? 0) +
                              (_collectedResult?.total ?? 0)) >
                          0) ...[
                        const SizedBox(width: 6),
                        CountBubble(
                          count:
                              (_claimedResult?.total ?? 0) +
                              (_collectedResult?.total ?? 0),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Delivered'),
                      if ((_deliveredResult?.total ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        CountBubble(count: _deliveredResult!.total),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending tab (PACKAGED)
                OrdersTab(
                  loading: _pendingLoading,
                  error: _pendingError,
                  result: _pendingResult,
                  currentPage: _pendingPage,
                  emptyIcon: Icons.inbox_outlined,
                  emptyMessage: 'No available orders',
                  subMessage: 'Check back later for new orders',
                  onRetry: () => _fetchPending(page: _pendingPage),
                  onRefresh: () => _fetchPending(page: _pendingPage),
                  onNext: () => _fetchPending(page: _pendingPage + 1),
                  onPrev: () => _fetchPending(page: _pendingPage - 1),
                  orderCardBuilder: (order) => _buildOrderCard(
                    order: order,
                    statusType: 'PACKAGED',
                    actionWidget: ClaimOrderButton(
                      orderId: order.id,
                      onSuccess: _refreshAll,
                    ),
                  ),
                ),

                // Active tab (CLAIMED + COLLECTED)
                ActiveOrdersTab(
                  claimedResult: _claimedResult,
                  claimedLoading: _claimedLoading,
                  claimedError: _claimedError,
                  claimedPage: _claimedPage,
                  onRefreshClaimed: () => _fetchClaimed(page: _claimedPage),
                  onRetryClaimed: () => _fetchClaimed(page: _claimedPage),
                  onNextClaimed: () => _fetchClaimed(page: _claimedPage + 1),
                  onPrevClaimed: () => _fetchClaimed(page: _claimedPage - 1),
                  collectedResult: _collectedResult,
                  collectedLoading: _collectedLoading,
                  collectedError: _collectedError,
                  collectedPage: _collectedPage,
                  onRefreshCollected: () =>
                      _fetchCollected(page: _collectedPage),
                  onRetryCollected: () => _fetchCollected(page: _collectedPage),
                  onNextCollected: () =>
                      _fetchCollected(page: _collectedPage + 1),
                  onPrevCollected: () =>
                      _fetchCollected(page: _collectedPage - 1),
                  orderCardBuilder: (order) => _buildOrderCard(
                    order: order,
                    statusType: order.orderStatus,
                    actionWidget: order.orderStatus == 'CLAIMED'
                        ? Column(
                            children: [
                              CollectOrderButton(
                                orderId: order.id,
                                onSuccess: _refreshAll,
                              ),
                              const SizedBox(height: 8),
                              UnclaimOrderButton(
                                orderId: order.id,
                                onSuccess: _refreshAll,
                              ),
                            ],
                          )
                        : DeliverOrderButton(
                            orderId: order.id,
                            onSuccess: _refreshAll,
                          ),
                  ),
                ),

                // Delivered tab
                OrdersTab(
                  loading: _deliveredLoading,
                  error: _deliveredError,
                  result: _deliveredResult,
                  currentPage: _deliveredPage,
                  emptyIcon: Icons.check_circle_outline,
                  emptyMessage: 'No delivered orders yet',
                  subMessage: 'Your completed deliveries will appear here',
                  onRetry: () => _fetchDelivered(page: _deliveredPage),
                  onRefresh: () => _fetchDelivered(page: _deliveredPage),
                  onNext: () => _fetchDelivered(page: _deliveredPage + 1),
                  onPrev: () => _fetchDelivered(page: _deliveredPage - 1),
                  orderCardBuilder: (order) => _buildOrderCard(
                    order: order,
                    statusType: 'DELIVERED',
                    actionWidget: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Build Order Card ──
  Widget _buildOrderCard({
    required RiderOrder order,
    required String statusType,
    Widget? actionWidget,
  }) {
    Color getStatusColor() {
      switch (statusType) {
        case 'PACKAGED':
          return Colors.green;
        case 'CLAIMED':
          return Colors.orange;
        case 'COLLECTED':
          return Colors.blue;
        case 'DELIVERED':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    String getStatusLabel() {
      switch (statusType) {
        case 'PACKAGED':
          return 'Ready for Pickup';
        case 'CLAIMED':
          return 'Claimed';
        case 'COLLECTED':
          return 'Collected';
        case 'DELIVERED':
          return 'Delivered';
        default:
          return statusType;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            // Header
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Items
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Text(
                      item.storeName,
                      style: AppTypography.body.copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action widget
            if (actionWidget != null && statusType != 'DELIVERED') ...[
              const SizedBox(height: 12),
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }
}
