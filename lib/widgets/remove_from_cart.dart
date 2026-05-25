// widgets/remove_from_cart.dart
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class RemoveFromCartButton extends StatefulWidget {
  final String productId;
  final String productName;
  final VoidCallback? onRemoved;
  final double? size;
  final bool iconOnly;

  const RemoveFromCartButton({
    super.key,
    required this.productId,
    required this.productName,
    this.onRemoved,
    this.size,
    this.iconOnly = false,
  });

  @override
  State<RemoveFromCartButton> createState() => _RemoveFromCartButtonState();
}

class _RemoveFromCartButtonState extends State<RemoveFromCartButton> {
  final CartService _cartService = CartService();
  bool _isLoading = false;

  Future<void> _removeItem() async {
    if (_isLoading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove "${widget.productName}" from your cart?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await _cartService.removeFromCart(widget.productId);

    setState(() => _isLoading = false);

    if (success) {
      if (widget.onRemoved != null) widget.onRemoved!();
      _showSnackBar('${widget.productName} removed from cart', Colors.green);
    } else {
      _showSnackBar('Failed to remove item', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.iconOnly) {
      return IconButton(
        onPressed: _isLoading ? null : _removeItem,
        icon: _isLoading
            ? SizedBox(
                height: widget.size ?? 18,
                width: widget.size ?? 18,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : Icon(
                Icons.delete_outline,
                size: widget.size ?? 20,
                color: Colors.red,
              ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashRadius: 20,
      );
    }

    return TextButton.icon(
      onPressed: _isLoading ? null : _removeItem,
      icon: _isLoading
          ? SizedBox(
              height: widget.size ?? 14,
              width: widget.size ?? 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            )
          : Icon(Icons.delete_outline, size: widget.size ?? 14),
      label: Text(
        'Remove',
        style: TextStyle(
          fontSize: widget.size != null ? widget.size! * 0.85 : 12,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}