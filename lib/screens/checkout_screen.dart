import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_colors.dart';
import '../services/checkout_service.dart';
import '../models/address.dart';
// import '../models/checkout.dart';
import './customers/checkout_summary_screen.dart';
import './customers/create_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String store_zone_id;

  const CheckoutScreen({super.key, required this.store_zone_id});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  List<Address> _addresses = [];
  bool _isLoading = true;
  Address? _selectedAddress;
  String? _details;
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _checkoutService.listAddresses(
        widget.store_zone_id,
      );
      setState(() {
        _addresses = response.addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading addresses: $e')));
    }
  }

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
    });
  }

  Future<void> _proceedToSummary() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutSummaryScreen(
          store_zone_id: widget.store_zone_id,
          address_id: _selectedAddress!.address_id,
          address_zone_id: _selectedAddress!.address_zone_id,
          address_name: _selectedAddress!.address_name,
          details: _detailsController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.prof,
        foregroundColor: AppColors.text,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Address Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Address',
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
                                    builder: (context) => CreateAddressScreen(
                                      store_zone_id: widget.store_zone_id,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadAddresses();
                                }
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Address'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Address List
                        if (_addresses.isEmpty)
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
                                  const Text('No addresses found'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateAddressScreen(
                                                store_zone_id:
                                                    widget.store_zone_id,
                                              ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadAddresses();
                                      }
                                    },
                                    child: const Text('Add Address'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._addresses.map(
                            (address) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: RadioListTile<Address>(
                                value: address,
                                groupValue: _selectedAddress,
                                onChanged: (value) {
                                  _selectAddress(value!);
                                },
                                title: Text(
                                  address.address_name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(address.address_zone_name),
                                activeColor: AppColors.prof,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Details (Room Number / Exact Location)
                        const Text(
                          'Delivery Details (Optional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      ],
                    ),
                  ),
                ),

                // Proceed Button
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
                      onPressed: _proceedToSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.prof,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Summary',
                        style: TextStyle(color: AppColors.text, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
