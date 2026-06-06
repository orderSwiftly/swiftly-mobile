// screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_colors.dart';
import '../services/checkout_service.dart';
import '../models/landmark.dart';
import '../models/checkout.dart';
import './customers/create_address_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  final String store_zone_id;

  const CheckoutScreen({super.key, required this.store_zone_id});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  List<Landmark> _landmarks = []; // Changed from _addresses
  bool _isLoading = true;
  Landmark? _selectedLandmark; // Changed from _selectedAddress
  String? _details;
  final TextEditingController _detailsController = TextEditingController();

  // New state for summary data
  CheckoutSummaryResponse? _summaryData;
  bool _isLoadingSummary = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadLandmarks(); // Changed from _loadAddresses
  }

  Future<void> _loadLandmarks() async {
    // Changed method name
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _checkoutService.listLandmarks(
        // Changed method call
        widget.store_zone_id,
      );
      setState(() {
        _landmarks = response.landmarks; // Note: Your model still uses 'landmarks' key internally
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading landmarks: $e')));
    }
  }

  void _selectLandmark(Landmark landmark) async {
    // Changed from _selectAddress
    setState(() {
      _selectedLandmark = landmark;
      _summaryData = null; // Clear previous summary
      _isLoadingSummary = true;
    });

    // Immediately fetch summary when landmark is selected
    await _loadSummaryForLandmark(landmark); // Changed method call
  }

  Future<void> _loadSummaryForLandmark(Landmark landmark) async {
    // Changed parameter type
    try {
      final summary = await _checkoutService.getCheckoutSummary(
        widget.store_zone_id,
        landmark.landmark_zone_id, // Changed from address.address_zone_id
      );

      if (mounted) {
        setState(() {
          _summaryData = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order summary: $e')),
        );
      }
    }
  }

  Future<void> _processCheckout() async {
    if (_selectedLandmark == null) {
      // Changed from _selectedAddress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery landmark'),
        ), // Changed text
      );
      return;
    }

    if (_summaryData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for order summary to load')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await _checkoutService.createCheckout(
        widget.store_zone_id,
        _selectedLandmark!.landmark_id, // Changed from address_id
        _selectedLandmark!.landmark_zone_id, // Changed from address_zone_id
        _detailsController.text,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              payment_link: response.payment_link,
              order_id: response.order_id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        if (e.toString().toLowerCase().contains('stock')) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.prof,
        foregroundColor: AppColors.text,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  // Desktop layout: three columns or two with summary on right
  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column — delivery landmark selection
              Expanded(
                flex: 4,
                child: _buildLandmarkSection(),
              ), // Changed method name
              const SizedBox(width: 32),
              // Right column — order summary (shown when landmark selected)
              Expanded(flex: 4, child: _buildSummarySection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandmarkSection() {
    // Changed from _buildAddressSection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Delivery Landmark', // Changed text
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateLandmarkScreen(
                      store_zone_id: widget.store_zone_id,
                    ),
                  ),
                );
                if (result == true) {
                  _loadLandmarks(); // Changed method call
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Landmark'), // Changed text
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_landmarks.isEmpty) // Changed from _addresses
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  const Text('No landmarks found'), // Changed text
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateLandmarkScreen(
                            store_zone_id: widget.store_zone_id,
                          ),
                        ),
                      );
                      if (result == true)
                        _loadLandmarks(); // Changed method call
                    },
                    child: const Text('Add Landmark'), // Changed text
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              children:
                  _landmarks // Changed from _addresses
                      .map(
                        (landmark) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: RadioListTile<Landmark>(
                            value: landmark,
                            groupValue: _selectedLandmark,
                            onChanged: (value) =>
                                _selectLandmark(value!), // Changed method call
                            title: Text(
                              landmark
                                  .landmark_name, // Changed from address_name
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              landmark.landmark_zone_name,
                            ), // Changed from address_zone_name
                            activeColor: AppColors.prof,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'Delivery Details (Optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _detailsController,
          decoration: InputDecoration(
            hintText: 'e.g., Room B26, Hall beside Bethel',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.info_outline),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Text(
          'Example: B26, Hall beside Bethel, etc.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    if (_selectedLandmark == null) {
      // Changed from _selectedAddress
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a delivery landmark to see your order total', // Changed text
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingSummary) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                'Calculating your order total...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_summaryData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load order summary'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadSummaryForLandmark(
                  _selectedLandmark!,
                ), // Changed method call
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.waveClr,
              ),
            ),
            const SizedBox(height: 16),

            // Order items preview (first few items)
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._summaryData!.items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₦${(item.price * item.quantity).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
            if (_summaryData!.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${_summaryData!.items.length - 3} more item(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const Divider(height: 24),

            // Price breakdown
            _buildPriceRow(
              'Subtotal',
              '₦${_summaryData!.subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Service Fee',
              '₦${_summaryData!.service_fee.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Delivery Fee',
              '₦${_summaryData!.delivery_fee.toStringAsFixed(2)}',
            ),
            const Divider(height: 24, thickness: 2),
            _buildPriceRow(
              'Total',
              '₦${_summaryData!.total.toStringAsFixed(2)}',
              isTotal: true,
            ),

            const SizedBox(height: 24),

            // Delivery landmark info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.prof.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivering to:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLandmark!
                        .landmark_name, // Changed from address_name
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_detailsController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Details: ${_detailsController.text}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm & Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.prof,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Confirm & Pay',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile layout with summary below landmark selection
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Landmark selection section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery Landmark', // Changed text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateLandmarkScreen(
                              store_zone_id: widget.store_zone_id,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadLandmarks(); // Changed method call
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Landmark'), // Changed text
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_landmarks.isEmpty) // Changed from _addresses
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          const Text('No landmarks found'), // Changed text
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateLandmarkScreen(
                                    store_zone_id: widget.store_zone_id,
                                  ),
                                ),
                              );
                              if (result == true)
                                _loadLandmarks(); // Changed method call
                            },
                            child: const Text('Add Landmark'), // Changed text
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._landmarks.map(
                    // Changed from _addresses
                    (landmark) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: RadioListTile<Landmark>(
                        value: landmark,
                        groupValue: _selectedLandmark,
                        onChanged: (value) =>
                            _selectLandmark(value!), // Changed method call
                        title: Text(
                          landmark.landmark_name, // Changed from address_name
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          landmark.landmark_zone_name,
                        ), // Changed from address_zone_name
                        activeColor: AppColors.prof,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Delivery Details (Optional)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Room B26, Hall beside Bethel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.info_outline),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Example: B26, Hall beside Bethel, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Order Summary Section (shown when landmark selected)
                if (_selectedLandmark != null) ...[
                  // Changed from _selectedAddress
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.waveClr,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoadingSummary)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Calculating total...'),
                          ],
                        ),
                      ),
                    )
                  else if (_summaryData != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal',
                              '₦${_summaryData!.subtotal.toStringAsFixed(2)}',
                            ),
                            const Divider(),
                            _buildPriceRow(
                              'Service Fee',
                              '₦${_summaryData!.service_fee.toStringAsFixed(2)}',
                            ),
                            _buildPriceRow(
                              'Delivery Fee',
                              '₦${_summaryData!.delivery_fee.toStringAsFixed(2)}',
                            ),
                            const Divider(thickness: 2),
                            _buildPriceRow(
                              'Total',
                              '₦${_summaryData!.total.toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Items: ${_summaryData!.items.length} product(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),

        // Confirm button pinned at bottom
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.text,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_selectedLandmark != null && // Changed from _selectedAddress
                      !_isLoadingSummary &&
                      !_isProcessing)
                  ? _processCheckout
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.prof,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirm & Pay',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.prof : null,
            ),
          ),
        ],
      ),
    );
  }
}

// PaymentWebView class remains the same (keep it as is)
class PaymentWebView extends StatefulWidget {
  final String payment_link;
  final String? order_id;

  const PaymentWebView({Key? key, required this.payment_link, this.order_id})
    : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            if (url.contains('success') || url.contains('complete')) {
              _handlePaymentSuccess();
            } else if (url.contains('failed') || url.contains('error')) {
              _handlePaymentFailure();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payment_link));
  }

  void _handlePaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Order confirmed.'),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  void _handlePaymentFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.prof,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ],
      ),
    );
  }
}
