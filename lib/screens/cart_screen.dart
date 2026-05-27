// screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../widgets/fetch_cart.dart';
import '../core/theme/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      // ── FIX: explicit white background prevents black screen when navigating back
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
        // ── FIX: Only show back button when actually pushed on top of another route.
        // When rendered inside MainWrapper as a tab, automaticallyImplyLeading
        // handles this — no manual leading needed.
        automaticallyImplyLeading: true,
      ),
      // ── DESKTOP ADAPTATION START ──
      // Center and cap cart content width on desktop
      body: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: const FetchCart(
                  showHeader: false,
                  showCheckoutButton: true,
                ),
              ),
            )
          : const FetchCart(showHeader: false, showCheckoutButton: true),
      // ── DESKTOP ADAPTATION END ──
    );
  }
}
