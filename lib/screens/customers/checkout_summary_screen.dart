import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/checkout_service.dart';
import '../../models/checkout.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  final String store_zone_id;
  final String address_id;
  final String address_zone_id;
  final String address_name;
  final String details;

  const CheckoutSummaryScreen({
    super.key,
    required this.store_zone_id,
    required this.address_id,
    required this.address_zone_id,
    required this.address_name,
    required this.details,
  });

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  late Future<CheckoutSummaryResponse> _summaryFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() {
    _summaryFuture = _checkoutService.getCheckoutSummary(
      widget.store_zone_id,
      widget.address_zone_id,
    );
  }

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);

    try {
      final response = await _checkoutService.createCheckout(
        widget.store_zone_id,
        widget.address_id,
        widget.address_zone_id,
        widget.details,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              payment_url: response.payment_url,
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
    // ── DESKTOP ADAPTATION START ──
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: AppColors.prof,
        foregroundColor: AppColors.text,
      ),
      body: FutureBuilder<CheckoutSummaryResponse>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSummary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = snapshot.data!;

          // ── DESKTOP ADAPTATION START ──
          // Desktop: two-column layout — order items on left, price summary + pay on right
          // Mobile: original stacked layout with pinned bottom button
          return isDesktop
              ? _buildDesktopLayout(summary)
              : _buildMobileLayout(summary);
          // ── DESKTOP ADAPTATION END ──
        },
      ),
    );
  }

  // ── DESKTOP ADAPTATION START ──
  Widget _buildDesktopLayout(CheckoutSummaryResponse summary) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column — address + order items
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery address card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Address',
                                style: TextStyle(
                                  color: AppColors.prof,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.address_name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (widget.details.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Details: ${widget.details}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.waveClr,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...summary.items.map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Store: ${item.store_name}'),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Quantity: ${item.quantity}'),
                                    Text(
                                      '₦${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Right column — price summary + confirm button (sticky)
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal',
                              '₦${summary.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.waveClr,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            _buildPriceRow(
                              'Service Fee',
                              '₦${summary.service_fee.toStringAsFixed(2)}',
                            ),
                            _buildPriceRow(
                              'Delivery Fee',
                              '₦${summary.delivery_fee.toStringAsFixed(2)}',
                            ),
                            const Divider(thickness: 2),
                            _buildPriceRow(
                              'Total',
                              '₦${summary.total.toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm & Pay button in right column on desktop
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.prof,
                          padding: const EdgeInsets.symmetric(vertical: 18),
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
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── DESKTOP ADAPTATION END ──

  // Original mobile layout — unchanged
  Widget _buildMobileLayout(CheckoutSummaryResponse summary) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            color: AppColors.prof,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.address_name,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (widget.details.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Details: ${widget.details}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waveClr,
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.items.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Store: ${item.store_name}'),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantity: ${item.quantity}'),
                              Text(
                                '₦${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Subtotal',
                          '₦${summary.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.waveClr,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildPriceRow(
                          'Service Fee',
                          '₦${summary.service_fee.toStringAsFixed(2)}',
                        ),
                        _buildPriceRow(
                          'Delivery Fee',
                          '₦${summary.delivery_fee.toStringAsFixed(2)}',
                        ),
                        const Divider(thickness: 2),
                        _buildPriceRow(
                          'Total',
                          '₦${summary.total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pinned confirm button at bottom on mobile
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
                          AppColors.text,
                        ),
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

  Widget _buildPriceRow(
    String label,
    String amount, {
    bool isTotal = false,
    TextStyle? style,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                style ??
                TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            amount,
            style:
                style ??
                TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? AppColors.prof : AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

// Payment WebView — no layout changes needed, it's a full-screen webview
class PaymentWebView extends StatefulWidget {
  final String payment_url;
  final String? order_id;

  const PaymentWebView({Key? key, required this.payment_url, this.order_id})
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
      ..loadRequest(Uri.parse(widget.payment_url));
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
