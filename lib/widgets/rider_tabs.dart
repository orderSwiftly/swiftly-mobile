// widgets/rider_tabs.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/rider_order_service.dart';

// ── Count Bubble ──
class CountBubble extends StatelessWidget {
  final int count;

  const CountBubble({super.key, required this.count});

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

// ── Pagination Bar ──
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const PaginationBar({
    super.key,
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

// ── Orders Tab ──
class OrdersTab extends StatelessWidget {
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

  const OrdersTab({
    super.key,
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
      return _ErrorSection(error: error!, onRetry: onRetry);
    }

    final orders = result?.orders ?? [];

    if (orders.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        subMessage: subMessage,
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
          PaginationBar(
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

class _ErrorSection extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorSection({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
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
}

// ── Active Orders Tab ──
class ActiveOrdersTab extends StatefulWidget {
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

  final Widget Function(RiderOrder order) orderCardBuilder;

  const ActiveOrdersTab({
    super.key,
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
    required this.orderCardBuilder,
  });

  @override
  State<ActiveOrdersTab> createState() => _ActiveOrdersTabState();
}

class _ActiveOrdersTabState extends State<ActiveOrdersTab>
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
          _ActiveErrorSection(
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
            (order) => widget.orderCardBuilder(order),
          ),
          if ((widget.claimedResult?.totalPages ?? 1) > 1)
            PaginationBar(
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
          _ActiveErrorSection(
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
            (order) => widget.orderCardBuilder(order),
          ),
          if ((widget.collectedResult?.totalPages ?? 1) > 1)
            PaginationBar(
              currentPage: widget.collectedPage,
              totalPages: widget.collectedResult!.totalPages,
              hasNext: widget.collectedResult!.hasNext,
              hasPrev: widget.collectedResult!.hasPrev,
              onNext: widget.onNextCollected,
              onPrev: widget.onPrevCollected,
            ),
        ],

        // Empty state
        if ((widget.claimedResult?.orders.isEmpty ?? true) &&
            (widget.collectedResult?.orders.isEmpty ?? true) &&
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
}

class _ActiveErrorSection extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ActiveErrorSection({required this.error, required this.onRetry});

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