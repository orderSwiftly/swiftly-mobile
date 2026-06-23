// screens/riders/rider_delivery_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/rider_order_service.dart';

class RiderDeliveryScreen extends StatefulWidget {
  const RiderDeliveryScreen({super.key});

  @override
  State<RiderDeliveryScreen> createState() => _RiderDeliveryScreenState();
}

class _RiderDeliveryScreenState extends State<RiderDeliveryScreen>
    with SingleTickerProviderStateMixin {
  final RiderOrderService _service = RiderOrderService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final TabController _tabController;

  // PENDING tab (PACKAGED) - Available jobs
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
                      const Text('Pending'),
                      if ((_pendingResult?.total ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        _CountBubble(count: _pendingResult!.total),
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
                        _CountBubble(
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
                        _CountBubble(count: _deliveredResult!.total),
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
                // Pending tab (PACKAGED)
                _OrdersTab(
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
                  orderCardBuilder: (order) => _RiderOrderCard(
                    order: order,
                    statusType: 'PACKAGED',
                    onAction: () {
                      _showClaimConfirmation(context, order);
                    },
                  ),
                ),

                // Active tab (CLAIMED + COLLECTED)
                _ActiveOrdersTab(
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
                ),

                // Delivered tab
                _OrdersTab(
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
                  orderCardBuilder: (order) => _RiderOrderCard(
                    order: order,
                    statusType: 'DELIVERED',
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

  void _showClaimConfirmation(BuildContext context, RiderOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim Order'),
        content: Text(
          'Claim Order #${order.id.substring(0, 8).toUpperCase()}?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _claimOrder(order.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Claim Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _claimOrder(String orderId) async {
    final success = await _service.claimOrder(orderId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Order claimed successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _refreshAll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Failed to claim order'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
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

// ── Reusable tab body ──
class _OrdersTab extends StatelessWidget {
  final bool loading;
  final String? error;
  final RiderOrdersResult? result;
  final int currentPage;
  final IconData emptyIcon;
  final String emptyMessage;
  final String? subMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final Widget Function(RiderOrder order) orderCardBuilder;

  const _OrdersTab({
    required this.loading,
    required this.error,
    required this.result,
    required this.currentPage,
    required this.emptyIcon,
    required this.emptyMessage,
    this.subMessage,
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
              style: AppTypography.body.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                subMessage!,
                style: AppTypography.body.copyWith(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
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

// ── Active orders tab (combines CLAIMED and COLLECTED) ──
class _ActiveOrdersTab extends StatefulWidget {
  final RiderOrdersResult? claimedResult;
  final bool claimedLoading;
  final String? claimedError;
  final int claimedPage;
  final Future<void> Function() onRefreshClaimed;
  final VoidCallback onRetryClaimed;
  final VoidCallback onNextClaimed;
  final VoidCallback onPrevClaimed;

  final RiderOrdersResult? collectedResult;
  final bool collectedLoading;
  final String? collectedError;
  final int collectedPage;
  final Future<void> Function() onRefreshCollected;
  final VoidCallback onRetryCollected;
  final VoidCallback onNextCollected;
  final VoidCallback onPrevCollected;

  const _ActiveOrdersTab({
    required this.claimedResult,
    required this.claimedLoading,
    required this.claimedError,
    required this.claimedPage,
    required this.onRefreshClaimed,
    required this.onRetryClaimed,
    required this.onNextClaimed,
    required this.onPrevClaimed,
    required this.collectedResult,
    required this.collectedLoading,
    required this.collectedError,
    required this.collectedPage,
    required this.onRefreshCollected,
    required this.onRetryCollected,
    required this.onNextCollected,
    required this.onPrevCollected,
  });

  @override
  State<_ActiveOrdersTab> createState() => _ActiveOrdersTabState();
}

class _ActiveOrdersTabState extends State<_ActiveOrdersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        // Claimed section
        if (widget.claimedLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.claimedError != null)
          _ErrorSection(
            error: widget.claimedError!,
            onRetry: widget.onRetryClaimed,
          )
        else if (widget.claimedResult != null &&
            widget.claimedResult!.orders.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Claimed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
          ...widget.claimedResult!.orders.map(
            (order) => _RiderOrderCard(
              order: order,
              statusType: 'CLAIMED',
              onAction: () {
                _showCollectConfirmation(context, order);
              },
            ),
          ),
          if ((widget.claimedResult?.totalPages ?? 1) > 1)
            _PaginationBar(
              currentPage: widget.claimedPage,
              totalPages: widget.claimedResult!.totalPages,
              hasNext: widget.claimedResult!.hasNext,
              hasPrev: widget.claimedResult!.hasPrev,
              onNext: widget.onNextClaimed,
              onPrev: widget.onPrevClaimed,
            ),
        ],

        // Collected section
        if (widget.collectedLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.collectedError != null)
          _ErrorSection(
            error: widget.collectedError!,
            onRetry: widget.onRetryCollected,
          )
        else if (widget.collectedResult != null &&
            widget.collectedResult!.orders.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Collected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          ...widget.collectedResult!.orders.map(
            (order) => _RiderOrderCard(
              order: order,
              statusType: 'COLLECTED',
              onAction: () {
                _showDeliveryCodeDialog(context, order);
              },
            ),
          ),
          if ((widget.collectedResult?.totalPages ?? 1) > 1)
            _PaginationBar(
              currentPage: widget.collectedPage,
              totalPages: widget.collectedResult!.totalPages,
              hasNext: widget.collectedResult!.hasNext,
              hasPrev: widget.collectedResult!.hasPrev,
              onNext: widget.onNextCollected,
              onPrev: widget.onPrevCollected,
            ),
        ],

        // Empty state
        if (widget.claimedResult?.orders.isEmpty ??
            true &&
                !widget.claimedLoading &&
                !widget.collectedLoading &&
                widget.claimedError == null &&
                widget.collectedError == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No active orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showCollectConfirmation(BuildContext context, RiderOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: Text(
          'Mark Order #${order.id.substring(0, 8).toUpperCase()} as collected?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _collectOrder(context, order.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Collect Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _collectOrder(BuildContext context, String orderId) async {
    final service = RiderOrderService();
    final success = await service.collectOrder(orderId);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Order collected successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      widget.onRefreshClaimed();
      widget.onRefreshCollected();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Failed to collect order'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showDeliveryCodeDialog(BuildContext context, RiderOrder order) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Delivery Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(0, 8).toUpperCase()}',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Delivery Code',
                hintText: 'Enter the 4-digit delivery code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.length == 4) {
                Navigator.pop(context);
                _deliverOrder(context, order.id, code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 4-digit code'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Deliver'),
          ),
        ],
      ),
    );
  }

  Future<void> _deliverOrder(
    BuildContext context,
    String orderId,
    String code,
  ) async {
    final service = RiderOrderService();
    final success = await service.deliverOrder(orderId, code);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Order delivered successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      widget.onRefreshClaimed();
      widget.onRefreshCollected();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Failed to deliver order. Check delivery code.'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}

// ── Error section ──
class _ErrorSection extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorSection({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              error,
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
      ),
    );
  }
}

// ── Rider order card ──
class _RiderOrderCard extends StatelessWidget {
  final RiderOrder order;
  final String statusType;
  final VoidCallback? onAction;

  const _RiderOrderCard({
    required this.order,
    required this.statusType,
    this.onAction,
  });

  Color _getStatusColor() {
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

  String _getStatusLabel() {
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

  String _getActionLabel() {
    switch (statusType) {
      case 'PACKAGED':
        return 'Claim Order';
      case 'CLAIMED':
        return 'Collect Order';
      case 'COLLECTED':
        return 'Enter Code';
      default:
        return '';
    }
  }

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Details ──
            if (order.landmarkDetails != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.landmarkDetails!,
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],

            if (order.paymentResolvedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Paid at: ${_formatDate(order.paymentResolvedAt!)}',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],

            // ── Action button ──
            if (onAction != null && statusType != 'DELIVERED') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    _getActionLabel(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
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
