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
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    final items = await _cartService.fetchCart();

    int itemCount = 0;
    for (var item in items) {
      itemCount += item['quantity'] as int? ?? 0;
    }

    setState(() {
      _cartItems = items;
      _totalItems = itemCount;
      _isLoading = false;
    });

    widget.onCartItemCountChanged?.call(_totalItems);
  }

  /// Groups cart items by zone_name. Items with no zone fall under 'Other'.
  Map<String, List<Map<String, dynamic>>> get _itemsByZone {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in _cartItems) {
      final zone = item['zone_name']?.toString().trim();
      final key = (zone != null && zone.isNotEmpty) ? zone : 'Other';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  String _extractProductId(Map<String, dynamic> item) {
    final rawId =
        item['product_id'] ?? item['productId'] ?? item['_id'] ?? item['id'];
    if (rawId is Map) {
      return rawId['\$oid']?.toString() ?? rawId['_id']?.toString() ?? '';
    }
    return rawId?.toString() ?? '';
  }

  double _zoneTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      final qty = item['quantity'] as int? ?? 0;
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      return sum + price * qty;
    });
  }

  int _zoneItemCount(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
  }

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

  Future<void> _setQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) {
      await _loadCart();
      return;
    }
    setState(() => _isUpdating = true);
    final result = await _cartService.setCartQuantity(productId, newQuantity);
    if (result != null) {
      await _loadCart();
      _showSnackBar('Quantity updated', AppColors.prof);
    } else {
      _showSnackBar('Failed to update quantity', Colors.red);
    }
    setState(() => _isUpdating = false);
  }

  void _showQuantityDialog(
    String productId,
    String productName,
    int currentQuantity,
  ) {
    final controller = TextEditingController(text: currentQuantity.toString());
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
              controller: controller,
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
              final newQty = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context);
              if (newQty > 0) _setQuantity(productId, newQty);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.prof,
              foregroundColor: AppColors.text,
            ),
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

  void _navigateToCheckout(
    String zoneName,
    List<Map<String, dynamic>> zoneItems,
  ) {
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: {
        'zone_name': zoneName,
        'items': zoneItems,
        'total': _zoneTotal(zoneItems),
      },
    );
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
              : _buildZonedCartList(isMobile),
        ),
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
                        final id = _extractProductId(item);
                        if (id.isNotEmpty) {
                          await _cartService.removeFromCart(id);
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

  // ─── Zoned list ────────────────────────────────────────────────────────────

  Widget _buildZonedCartList(bool isMobile) {
    final grouped = _itemsByZone;
    final zones = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zoneName = zones[index];
        final zoneItems = grouped[zoneName]!;
        return _buildZoneSection(zoneName, zoneItems, isMobile);
      },
    );
  }

  Widget _buildZoneSection(
    String zoneName,
    List<Map<String, dynamic>> zoneItems,
    bool isMobile,
  ) {
    final total = _zoneTotal(zoneItems);
    final count = _zoneItemCount(zoneItems);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.prof.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.prof),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    zoneName,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.prof,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.prof.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count item${count != 1 ? 's' : ''}',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.prof,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items
          ...zoneItems.map(
            (item) => _buildCartItem(
              productId: _extractProductId(item),
              productName: item['name']?.toString() ?? '',
              price: double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
              quantity: item['quantity'] as int? ?? 0,
              storeName: item['store_name']?.toString() ?? 'Unknown Store',
              imageUrl: item['image_url']?.toString(),
            ),
          ),

          // Zone checkout footer
          if (widget.showCheckoutButton)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zone Total',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₦${total.toStringAsFixed(0)}',
                        style: AppTypography.title.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isUpdating
                        ? null
                        : () => _navigateToCheckout(zoneName, zoneItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.prof,
                      foregroundColor: AppColors.text,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Checkout Zone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String storeName,
    String? imageUrl,
  }) {
    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.textHint.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    width: 72,
                    height: 72,
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
                                size: 28,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.textSecondary,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Name + store + delete
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            RemoveFromCartButton(
                              productId: productId,
                              productName: productName,
                              iconOnly: true,
                              onRemoved: _loadCart,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
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
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Price | Stepper | Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Unit price
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

                  // Stepper
                  GestureDetector(
                    onTap: _isUpdating
                        ? null
                        : () => _showQuantityDialog(
                            productId,
                            productName,
                            quantity,
                          ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textHint.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _isUpdating
                                ? null
                                : () => _updateQuantity(productId, 'decrease'),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          SizedBox(
                            width: 28,
                            child: Text(
                              quantity.toString(),
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: _isUpdating
                                ? null
                                : () => _updateQuantity(productId, 'increase'),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}