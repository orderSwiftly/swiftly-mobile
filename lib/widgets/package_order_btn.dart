// widgets/package_order_btn.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/store_order_service.dart';

class PackageOrderButton extends StatefulWidget {
  final String orderItemId;
  final String orderId;
  final String itemName;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const PackageOrderButton({
    super.key,
    required this.orderItemId,
    required this.orderId,
    required this.itemName,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<PackageOrderButton> createState() => _PackageOrderButtonState();
}

class _PackageOrderButtonState extends State<PackageOrderButton> {
  final StoreOrderService _service = StoreOrderService();
  bool _isLoading = false;

  Future<void> _markAsPackaged() async {
    setState(() => _isLoading = true);

    try {
      final success = await _service.markItemAsPackaged(widget.orderItemId);

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = false);

      if (success) {
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"${widget.itemName}" packaged successfully',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        widget.onError?.call('Failed to mark item as packaged');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Server error. Please try again.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _markAsPackaged,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Mark as Packaged',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
