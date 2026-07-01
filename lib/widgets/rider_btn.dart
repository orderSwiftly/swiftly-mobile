// widgets/rider_btn.dart

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/rider_order_service.dart';

class ClaimOrderButton extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const ClaimOrderButton({
    super.key,
    required this.orderId,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<ClaimOrderButton> createState() => _ClaimOrderButtonState();
}

class _ClaimOrderButtonState extends State<ClaimOrderButton> {
  final RiderOrderService _service = RiderOrderService();
  bool _isLoading = false;

  Future<void> _claimOrder() async {
    setState(() => _isLoading = true);

    final success = await _service.claimOrder(widget.orderId);

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order claimed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.onError?.call('Failed to claim order');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to claim order'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _claimOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Claim Order',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class UnclaimOrderButton extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const UnclaimOrderButton({
    super.key,
    required this.orderId,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<UnclaimOrderButton> createState() => _UnclaimOrderButtonState();
}

class _UnclaimOrderButtonState extends State<UnclaimOrderButton> {
  final RiderOrderService _service = RiderOrderService();
  bool _isLoading = false;

  Future<void> _unclaimOrder() async {
    setState(() => _isLoading = true);

    final success = await _service.unclaimOrder(widget.orderId);

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order unclaimed successfully!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.onError?.call('Failed to unclaim order');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to unclaim order'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _unclaimOrder,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Unclaim Order',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
      ),
    );
  }
}

class CollectOrderButton extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const CollectOrderButton({
    super.key,
    required this.orderId,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<CollectOrderButton> createState() => _CollectOrderButtonState();
}

class _CollectOrderButtonState extends State<CollectOrderButton> {
  final RiderOrderService _service = RiderOrderService();
  bool _isLoading = false;

  Future<void> _collectOrder() async {
    setState(() => _isLoading = true);

    final success = await _service.collectOrder(widget.orderId);

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order collected successfully!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.onError?.call('Failed to collect order');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to collect order'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _collectOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.prof,
          foregroundColor: AppColors.text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.text,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Collect Order',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class DeliverOrderButton extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const DeliverOrderButton({
    super.key,
    required this.orderId,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<DeliverOrderButton> createState() => _DeliverOrderButtonState();
}

class _DeliverOrderButtonState extends State<DeliverOrderButton> {
  final RiderOrderService _service = RiderOrderService();
  bool _isLoading = false;

  void _showDeliveryCodeDialog() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Delivery Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the 6-digit delivery code provided by the customer',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Delivery Code',
                hintText: 'Enter 6-digit code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
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
              final code = codeController.text.trim();
              if (code.length == 6) {
                Navigator.pop(context);
                _deliverOrder(code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 6-digit code'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.waveClr, foregroundColor: AppColors.text),
            child: const Text('Deliver'),
          ),
        ],
      ),
    );
  }

  Future<void> _deliverOrder(String code) async {
    setState(() => _isLoading = true);

    final success = await _service.deliverOrder(widget.orderId, code);

    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order delivered successfully! 🎉'),
          backgroundColor: AppColors.prof,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.onError?.call('Failed to deliver order');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to deliver order. Check delivery code.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _showDeliveryCodeDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.prof,
          foregroundColor: AppColors.text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.text,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Enter Code',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}