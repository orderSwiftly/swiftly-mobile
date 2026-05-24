// screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../widgets/fetch_cart.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.prof,
        elevation: 0,
        foregroundColor: AppColors.text,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const FetchCart(showHeader: false, showCheckoutButton: true),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to home or explore screen
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
              foregroundColor: AppColors.text,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
