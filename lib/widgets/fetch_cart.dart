// widgets/fetch_cart.dart
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'remove_from_cart.dart';

class FetchCart extends StatefulWidget {
  final Function(int)? onCartItemCountChanged;
  final bool showHeader;
  final bool showCheckoutButton;

  const FetchCart({
    super.key,
    this.onCartItemCountChanged,
    this.showHeader = true,
    this.showCheckoutButton = true,
  });

  @override
  State<FetchCart> createState() => _FetchCartState();
}

class _FetchCartState extends State<FetchCart> {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  bool _isUpdating = false;
  double _totalPrice = 0.0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    final items = await _cartService.fetchCart();

    double total = 0.0;
    int itemCount = 0;

    for (var item in items) {
      final quantity = item['quantity'] as int? ?? 0;
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      total += price * quantity;
      itemCount += quantity;
    }

    setState(() {
      _cartItems = items;
      _totalPrice = total;
      _totalItems = itemCount;
      _isLoading = false;
    });

    if (widget.onCartItemCountChanged != null) {
      widget.onCartItemCountChanged!(_totalItems);
    }
  }

  // Update quantity using increase/decrease actions
  Future<void> _updateQuantity(String productId, String action) async {
    setState(() => _isUpdating = true);

    final result = await _cartService.updateCartItem(productId, action);

    if (result != null) {
      await _loadCart();
      _showSnackBar(
        action == 'increase' ? 'Quantity increased' : 'Quantity decreased',
        Colors.green,
      );
    } else {
      _showSnackBar('Failed to update quantity', Colors.red);
    }

    setState(() => _isUpdating = false);
  }

  // Set quantity directly (for manual entry)
  Future<void> _setQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeItemFromList(productId);
      return;
    }

    setState(() => _isUpdating = true);

    final result = await _cartService.setCartQuantity(productId, newQuantity);

    if (result != null) {
      await _loadCart();
      _showSnackBar('Quantity updated successfully', Colors.green);
    } else {
      _showSnackBar('Failed to update quantity', Colors.red);
    }

    setState(() => _isUpdating = false);
  }

  // Helper method to remove item and reload cart
  Future<void> _removeItemFromList(String productId) async {
    await _loadCart();
  }

  void _showQuantityDialog(
    String productId,
    String productName,
    int currentQuantity,
  ) {
    final TextEditingController quantityController = TextEditingController();
    quantityController.text = currentQuantity.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter desired quantity for $productName',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter quantity',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text) ?? 0;
              Navigator.pop(context);
              if (newQuantity > 0) {
                _setQuantity(productId, newQuantity);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Update'),
          ),
        ],
      ),
    );
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

  void _navigateToCheckout() {
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        if (widget.showHeader) _buildHeader(isMobile),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _cartItems.isEmpty
              ? _buildEmptyState()
              : _buildCartList(isMobile),
        ),
        if (widget.showCheckoutButton && _cartItems.isNotEmpty)
          _buildCheckoutSection(isMobile),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.text,
        border: Border(
          bottom: BorderSide(color: AppColors.textHint.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Cart',
            style: AppTypography.headline.copyWith(
              fontSize: isMobile ? 20 : 24,
              color: AppColors.primary,
            ),
          ),
          if (_cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: _isUpdating
                  ? null
                  : () async {
                      for (var item in List.from(_cartItems)) {
                        final productId = item['product_id']?.toString() ?? '';
                        if (productId.isNotEmpty) {
                          await _cartService.removeFromCart(productId);
                        }
                      }
                      await _loadCart();
                      _showSnackBar('Cart cleared', Colors.green);
                    },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTypography.headline.copyWith(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(bool isMobile) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        final quantity = item['quantity'] as int? ?? 0;
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
        final total = price * quantity;
        final productName = item['name']?.toString() ?? '';
        String productId = '';
final rawId = item['product_id'] ?? item['productId'] ?? item['_id'] ?? item['id'];
if (rawId is Map) {
  productId = rawId['\$oid']?.toString() ?? rawId['_id']?.toString() ?? '';
} else if (rawId != null) {
  productId = rawId.toString();
}

print('Cart item "${item['name']}" → productId: "$productId"');

        return _buildCartItem(
          productId: productId,
          productName: productName,
          displayName: productName,
          price: price,
          quantity: quantity,
          total: total,
          storeName: item['store_name'] ?? 'Unknown Store',
          zoneName: item['zone_name'] ?? '',
          imageUrl: item['image_url'],
        );
      },
    );
  }

  Widget _buildCartItem({
    required String productId,
    required String productName,
    required String displayName,
    required double price,
    required int quantity,
    required double total,
    required String storeName,
    String? zoneName,
    String? imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textHint.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textSecondary,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    displayName,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Store Name
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          storeName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Zone Name
                  if (zoneName != null && zoneName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          zoneName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Price and Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '₦${price.toStringAsFixed(0)}',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.prof,
                            ),
                          ),
                        ],
                      ),

                      // Quantity Controls
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Quantity',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _isUpdating
                                ? null
                                : () => _showQuantityDialog(
                                    productId,
                                    productName,
                                    quantity,
                                  ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.textHint.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Decrease button
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateQuantity(
                                            productId,
                                            'decrease',
                                          ),
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      quantity.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Increase button
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateQuantity(
                                            productId,
                                            'increase',
                                          ),
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '₦${total.toStringAsFixed(0)}',
                            style: AppTypography.title.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Remove button - Using the reusable RemoveFromCartButton widget
                  Align(
                    alignment: Alignment.centerRight,
                    child: RemoveFromCartButton(
                      productId: productId,
                      productName: productName,
                      size: 14,
                      onRemoved: () {
                        _loadCart();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.text,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items:',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$_totalItems item${_totalItems > 1 ? 's' : ''}',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₦${_totalPrice.toStringAsFixed(0)}',
                  style: AppTypography.title.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _navigateToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.prof,
                  foregroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.text,
                        ),
                      )
                    : const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}