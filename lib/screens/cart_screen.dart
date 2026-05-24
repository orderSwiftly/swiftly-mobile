// screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../widgets/fetch_cart.dart';
import '../core/theme/app_colors.dart';

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const FetchCart(showHeader: false, showCheckoutButton: true),
    );
  }
}