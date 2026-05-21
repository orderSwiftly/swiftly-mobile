// widgets/add_to_cart.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AddToCartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double? size;

  const AddToCartButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: EdgeInsets.all(size ?? 8),
        decoration: BoxDecoration(
          color: AppColors.prof,
          borderRadius: BorderRadius.circular(50),
        ),
        child: isLoading
            ? SizedBox(
                height: size ?? 20,
                width: size ?? 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.text,
                ),
              )
            : Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.text,
                size: size ?? 20,
              ),
      ),
    );
  }
}

// Alternative: Button with text
class AddToCartTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const AddToCartTextButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Add to Cart',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.text,
              ),
            )
          : const Icon(Icons.shopping_cart_outlined),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.text,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}