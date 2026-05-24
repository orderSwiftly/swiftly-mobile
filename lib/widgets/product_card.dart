// widgets/product_card.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/add_to_cart.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String category;
  final String storeName;
  final int stock;
  final double rating;
  final int reviewsCount;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.category,
    required this.storeName,
    required this.stock,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image with Stock Badge
            Stack(
              children: [
                Container(
                  height: isMobile ? 80 : 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: isMobile ? 32 : 40,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (stock > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: stock <= 10
                            ? const Color.fromARGB(255, 255, 123, 0)
                            : AppColors.waveClr,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$stock left',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: isMobile ? 13 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₦${price.toStringAsFixed(0)}',
                        style: AppTypography.title.copyWith(
                          fontSize: isMobile ? 13 : 14,
                          color: AppColors.prof,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Rating + Category Row
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          Icons.star,
                          size: 10,
                          color: rating >= i
                              ? Colors.amber
                              : AppColors.textHint,
                        ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Seller Section
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seller',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 8,
                              ),
                            ),
                            Text(
                              storeName,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  Divider(
                    height: 1,
                    color: AppColors.textHint.withOpacity(0.2),
                  ),

                  const SizedBox(height: 8),

                  // View Details + Cart Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: onTap,
                        child: Row(
                          children: [
                            Text(
                              'View Details',
                              style: AppTypography.body.copyWith(
                                color: AppColors.prof,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: AppColors.prof,
                            ),
                          ],
                        ),
                      ),
                      AddToCartButton(
                        productId: id,
                        stock: stock,
                        size: 14,
                        onSuccess: () {
                          // Optional: Show a message or update UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item added to cart!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}