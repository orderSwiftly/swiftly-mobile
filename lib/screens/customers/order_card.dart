// screens/customers/order_card.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/customer_order_service.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: order ID + status badge ──
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
                _StatusBadge(status: order.orderStatus),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Items ──
            ...order.items.map((item) => _ItemRow(item: item)),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Footer: total + delivery code ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₦${order.total.toStringAsFixed(2)}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (order.deliveryCode != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.pin_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery code: ${order.deliveryCode}',
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

class _ItemRow extends StatelessWidget {
  final OrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity bubble
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
                Text(
                  item.storeName,
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦${(double.parse(item.price) * item.quantity).toStringAsFixed(2)}',
            style: AppTypography.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  ({Color bg, Color fg, String label}) get _config => switch (status) {
    'AWAITING_PAYMENT' => (
      bg: const Color(0xFFFFF3CD),
      fg: const Color(0xFF856404),
      label: 'Awaiting Payment',
    ),
    'PAID' => (
      bg: const Color(0xFFD1ECF1),
      fg: const Color(0xFF0C5460),
      label: 'Paid',
    ),
    'PREPARING' => (
      bg: const Color(0xFFE2D9F3),
      fg: const Color(0xFF4B2DA0),
      label: 'Preparing',
    ),
    'READY' => (
      bg: const Color(0xFFD4EDDA),
      fg: const Color(0xFF155724),
      label: 'Ready',
    ),
    'IN_TRANSIT' => (
      bg: const Color(0xFFCCE5FF),
      fg: const Color(0xFF004085),
      label: 'In Transit',
    ),
    'DELIVERED' => (
      bg: const Color(0xFFD4EDDA),
      fg: const Color(0xFF155724),
      label: 'Delivered',
    ),
    'CANCELLED' => (
      bg: const Color(0xFFF8D7DA),
      fg: const Color(0xFF721C24),
      label: 'Cancelled',
    ),
    'ABANDONED' => (
      bg: const Color(0xFFE2E3E5),
      fg: const Color(0xFF383D41),
      label: 'Abandoned',
    ),
    _ => (
      bg: const Color(0xFFE2E3E5),
      fg: const Color(0xFF383D41),
      label: status,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        c.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.fg,
        ),
      ),
    );
  }
}
