// screens/customers/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/product_service.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/product_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _categories = {'All'};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final products = await _productService.exploreProducts(
        'BABCOCK_MAIN_CAMPUS',
      );
      setState(() {
        _products = products.cast<Map<String, dynamic>>();
        _extractCategories();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _extractCategories() {
    final cats = <String>{'All'};
    for (var product in _products) {
      final category = product['category'] as String?;
      if (category != null && category.isNotEmpty) {
        cats.add(category);
      }
    }
    _categories = cats;
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final category = product['category']?.toString().toLowerCase() ?? '';
      final storeName =
          (product['store'] as Map?)?['name']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          category.contains(query) ||
          storeName.contains(query);
    }).toList();

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product['category'] == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isDesktop = screenWidth >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(isMobile, isDesktop),

          if (_categories.length > 1) _buildCategoryFilter(isMobile, isDesktop),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _filteredProducts.isEmpty
                ? _buildEmptyView()
                // ── DESKTOP ADAPTATION START ──
                // Pass isDesktop so the grid knows how many columns to use
                : _buildProductsGrid(isMobile, isDesktop),
            // ── DESKTOP ADAPTATION END ──
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isDesktop) {
    return Container(
      color: AppColors.text,
      padding: EdgeInsets.symmetric(
        // ── DESKTOP ADAPTATION START ──
        // More horizontal breathing room on desktop
        horizontal: isDesktop ? 32 : (isMobile ? 16 : 24),
        // ── DESKTOP ADAPTATION END ──
        vertical: 16,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Products',
              style: AppTypography.headline.copyWith(
                // ── DESKTOP ADAPTATION START ──
                // Slightly larger title on desktop
                fontSize: isDesktop ? 30 : (isMobile ? 24 : 28),
                // ── DESKTOP ADAPTATION END ──
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover amazing products at Babcock University',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            CustomSearchBar(
              hintText: 'Search by name, category, or store...',
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isMobile, bool isDesktop) {
    return Container(
      color: AppColors.text,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // ── DESKTOP ADAPTATION START ──
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : (isMobile ? 16 : 24),
        ),
        // ── DESKTOP ADAPTATION END ──
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                },
                backgroundColor: AppColors.primary,
                selectedColor: AppColors.accent,
                labelStyle: AppTypography.body.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.text,
                  fontSize: 13,
                ),
                checkmarkColor: AppColors.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(bool isMobile, bool isDesktop) {
    // ── DESKTOP ADAPTATION START ──
    // Scale columns with screen width:
    // mobile = 2, tablet = 3, desktop = 4
    final int crossAxisCount = isDesktop ? 4 : (isMobile ? 2 : 3);
    // Slightly taller cards on desktop to prevent text clipping
    final double childAspectRatio = isDesktop ? 0.72 : (isMobile ? 0.70 : 0.75);
    // Extra padding on desktop so grid doesn't stretch wall-to-wall
    final double horizontalPadding = isDesktop ? 32 : 16;
    // ── DESKTOP ADAPTATION END ──

    return GridView.builder(
      padding: EdgeInsets.all(horizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final store = product['store'] as Map<String, dynamic>?;

        return ProductCard(
          id: product['id'],
          name: product['name'] ?? 'Product Name',
          price: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
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
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textError),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: AppTypography.body.copyWith(color: AppColors.textError),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No products found for your search'
                : 'No products available',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                });
              },
              child: Text(
                'Clear filters',
                style: AppTypography.body.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
