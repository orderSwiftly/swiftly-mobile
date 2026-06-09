// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/navbar.dart';
import '../widgets/product_card.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/product_service.dart';
import '../widgets/list_categories.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'All';
  final ProductService _productService = ProductService();

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    try {
      final products = await _productService.exploreProducts(
        'BABCOCK_MAIN_CAMPUS',
      );
      return products;
    } catch (e) {
      print('Error loading products preview: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadFilteredProducts() async {
    try {
      final allProducts = await _loadProducts();
      if (_selectedCategory == 'All') return allProducts;
      return allProducts.where((product) {
        final productCategory = product['category'] ?? '';
        return productCategory.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    } catch (e) {
      print('Error loading filtered products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          _DashboardHeader(
            isMobile: isMobile,
            isDesktop: isDesktop,
            showNavBar: true, // ✅ Customer dashboard shows the navbar
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/explore'),
              child: const CustomSearchBar(
                showFilterButton: true,
                hintText: 'Search products...',
              ),
            ),
          ),

          const SizedBox(height: 16),

          ListCategories(
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),

          const SizedBox(height: 8),

          Flexible(
            child: FutureBuilder(
              future: _loadFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory == 'All'
                              ? 'No products available'
                              : 'No products in $_selectedCategory',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!;

                // ── DESKTOP ADAPTATION START ──
                final int crossAxisCount = isDesktop ? 4 : (isMobile ? 2 : 3);
                // ── DESKTOP ADAPTATION END ──

                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final store = product['store'] as Map<String, dynamic>?;
                    return ProductCard(
                      id: product['id'],
                      name: product['name'] ?? 'Product Name',
                      price:
                          double.tryParse(
                            product['price']?.toString() ?? '0',
                          ) ??
                          0.0,
                      description: product['description'],
                      category: product['category'] ?? 'Uncategorized',
                      storeName: store?['name'] ?? 'Unknown Store',
                      stock: product['stock'] ?? 0,
                      rating: (product['rating'] as num?)?.toDouble() ?? 0.0,
                      reviewsCount: product['reviews_count'] ?? 0,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product-details',
                          arguments: product,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final bool showNavBar; // ✅ Added this parameter

  const _DashboardHeader({
    required this.isMobile,
    required this.isDesktop,
    this.showNavBar = false, // Default to false for safety
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 100 : 120,
      color: AppColors.text,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // University Logo
              Container(
                width: isDesktop ? 50 : (isMobile ? 42 : 46),
                height: isDesktop ? 50 : (isMobile ? 42 : 46),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.text,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/babcock.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.secondary,
                      alignment: Alignment.center,
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 24 : (isMobile ? 20 : 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Mobile: centred "Home" title
              if (isMobile)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

              // Desktop layout
              if (isDesktop) ...[
                const SizedBox(width: 12),
                const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                // ✅ Only show AppNavBar if showNavBar is true
                if (showNavBar) const AppNavBar(),
              ],

              // ✅ Mobile: Only show AppNavBar if showNavBar is true
              if (isMobile && showNavBar) const AppNavBar(),
              if (!isMobile && !isDesktop && showNavBar) const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}