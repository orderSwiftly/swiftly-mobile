// widgets/list_categories.dart
import 'package:flutter/material.dart';
import '../services/categories_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class ListCategories extends StatefulWidget {
  final Function(String) onCategorySelected;

  const ListCategories({super.key, required this.onCategorySelected});

  @override
  State<ListCategories> createState() => _ListCategoriesState();
}

class _ListCategoriesState extends State<ListCategories> {
  final CategoryService _categoryService = CategoryService();
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _hasError = false;

  // Map categories to appropriate icons
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'fashion':
        return Icons.shopping_bag;
      case 'beauty':
        return Icons.face;
      case 'gadgets':
        return Icons.devices;
      case 'electronics':
        return Icons.electrical_services;
      case 'stationery':
        return Icons.edit_note;
      case 'care':
        return Icons.health_and_safety;
      default:
        return Icons.dashboard;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final categories = await _categoryService.fetchCategories();

    setState(() {
      _categories = categories;
      _isLoading = false;
      if (categories.isEmpty) {
        _hasError = true;
      }
    });
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.prof,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: isSelected ? Colors.white : AppColors.prof,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = label;
        });
        widget.onCategorySelected(label);
      },
      selected: isSelected,
      backgroundColor: Colors.white,
      selectedColor: AppColors.accent,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      elevation: 0,
      pressElevation: 1,
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Skeleton loading chips
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            'Failed to load categories',
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _loadCategories,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Retry',
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _categories.isEmpty) {
      return _buildErrorState();
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" category chip
          _buildCategoryChip('All', Icons.dashboard),
          const SizedBox(width: 8),

          // Dynamic categories from API
          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(category, _getCategoryIcon(category)),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories Section Header
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Category Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _buildCategoryChips(),
        ),

        const SizedBox(height: 16),

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

        // Products Preview - You can implement this part
        // Flexible(child: _buildProductsPreview(context, isMobile)),
      ],
    );
  }
}
