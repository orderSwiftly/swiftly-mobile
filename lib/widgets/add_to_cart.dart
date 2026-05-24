// widgets/add_to_cart.dart
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../core/theme/app_colors.dart';

class AddToCartButton extends StatefulWidget {
  final String productId;
  final int stock;
  final double? size;
  final VoidCallback? onSuccess;

  const AddToCartButton({
    super.key,
    required this.productId,
    required this.stock,
    this.size,
    this.onSuccess,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  bool _isAdded = false;

  Future<void> _addToCart() async {
    if (widget.stock <= 0) {
      _showSnackBar('Out of stock!', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _cartService.addToCart(widget.productId, quantity: 1);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      setState(() {
        _isAdded = true;
      });
      _showSnackBar('Added to cart successfully!', AppColors.prof);

      // Reset the added state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isAdded = false;
          });
        }
      });

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } else {
      _showSnackBar('Failed to add to cart. Please try again.', Colors.red);
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
    return GestureDetector(
      onTap: (_isLoading || _isAdded) ? null : _addToCart,
      child: Container(
        padding: EdgeInsets.all(widget.size ?? 8),
        decoration: BoxDecoration(
          color: _isAdded
              ? Colors.green
              : (widget.stock <= 0 ? Colors.grey : AppColors.prof),
          borderRadius: BorderRadius.circular(50),
        ),
        child: _isLoading
            ? SizedBox(
                height: widget.size ?? 20,
                width: widget.size ?? 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.text,
                ),
              )
            : Icon(
                _isAdded ? Icons.check : Icons.shopping_cart_outlined,
                color: AppColors.text,
                size: widget.size ?? 20,
              ),
      ),
    );
  }
}

// Alternative: Button with text
class AddToCartTextButton extends StatefulWidget {
  final String productId;
  final int stock;
  final String text;
  final VoidCallback? onSuccess;

  const AddToCartTextButton({
    super.key,
    required this.productId,
    required this.stock,
    this.text = 'Add to Cart',
    this.onSuccess,
  });

  @override
  State<AddToCartTextButton> createState() => _AddToCartTextButtonState();
}

class _AddToCartTextButtonState extends State<AddToCartTextButton> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  bool _isAdded = false;

  Future<void> _addToCart() async {
    if (widget.stock <= 0) {
      _showSnackBar('Out of stock!', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _cartService.addToCart(widget.productId, quantity: 1);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      setState(() {
        _isAdded = true;
      });
      _showSnackBar('Added to cart successfully!', AppColors.prof);

      // Reset the added state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isAdded = false;
          });
        }
      });

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } else {
      _showSnackBar('Failed to add to cart. Please try again.', Colors.red);
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
    return ElevatedButton.icon(
      onPressed: (_isLoading || _isAdded) ? null : _addToCart,
      icon: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.text,
              ),
            )
          : Icon(_isAdded ? Icons.check : Icons.shopping_cart_outlined),
      label: Text(_isAdded ? 'Added!' : widget.text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isAdded
            ? Colors.green
            : (widget.stock <= 0 ? Colors.grey : AppColors.accent),
        foregroundColor: AppColors.text,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}