// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/navbar.dart';
import '../widgets/product_card.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'customers/explore_screen.dart';
import '../services/product_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          _DashboardHeader(isMobile: isMobile),
          const SizedBox(height: 16),

          // Search Bar - Navigate to explore screen when tapped
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/explore');
              },
              child: const CustomSearchBar(
                showFilterButton: true,
                hintText: 'Search products...',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.prof,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/explore');
                  },
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: AppTypography.body.copyWith(
                          color: AppColors.prof,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(context, 'All', Icons.dashboard),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, 'Food', Icons.fastfood),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, 'Fashion', Icons.shopping_bag),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, 'Gadgets', Icons.devices),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    context,
                    'Electronics',
                    Icons.electrical_services,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Popular Products Title
          // Popular Products Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular Products',
                style: AppTypography.title.copyWith(
                  fontSize: 16,
                  color: AppColors.prof,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Products Preview - Use Flexible to prevent overflow
          Flexible(child: _buildProductsPreview(context, isMobile)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        Navigator.pushNamed(
          context,
          '/explore',
          arguments: {'category': label},
        );
      },
      backgroundColor: AppColors.text,
      selectedColor: AppColors.waveClr,
      side: BorderSide(color: AppColors.secondary),
      labelStyle: AppTypography.body.copyWith(
        color: AppColors.waveClr,
        fontSize: 13,
      ),
      avatar: Icon(icon, size: 16, color: AppColors.waveClr),
    );
  }

  Widget _buildProductsPreview(BuildContext context, bool isMobile) {
    return FutureBuilder(
      future: _loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
                  'No products available',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!;
        final previewProducts = products.take(4).toList();
        final crossAxisCount = isMobile ? 2 : 4;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: previewProducts.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final product = previewProducts[index];
            final store = product['store'] as Map<String, dynamic>?;

            return ProductCard(
              id: product['id'],
              name: product['name'] ?? 'Product Name',
              price:
                  double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
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
    );
  }

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    try {
      final productService = ProductService();
      final products = await productService.exploreProducts(
        'BABCOCK_MAIN_CAMPUS',
      );
      return products;
    } catch (e) {
      print('Error loading products preview: $e');
      return [];
    }
  }
}

class _DashboardHeader extends StatelessWidget {
  final bool isMobile;

  const _DashboardHeader({required this.isMobile});

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
              Container(
                width: isMobile ? 42 : 50,
                height: isMobile ? 42 : 50,
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
                          fontSize: isMobile ? 20 : 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
              if (!isMobile) const Spacer(),
              if (isMobile) const AppNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
