import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_colors.dart';

class CreateAddressScreen extends StatefulWidget {
  final String store_zone_id;

  const CreateAddressScreen({super.key, required this.store_zone_id});

  @override
  State<CreateAddressScreen> createState() => _CreateAddressScreenState();
}

class _CreateAddressScreenState extends State<CreateAddressScreen> {
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _addressZoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    // Constrain the form width on desktop so it doesn't stretch edge-to-edge
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: AppColors.prof,
        foregroundColor: AppColors.text,
      ),
      // ── DESKTOP ADAPTATION START ──
      // Center and cap form at 520px on desktop; full width on mobile
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            // ── DESKTOP ADAPTATION END ──
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Bethel, Samuel Akande, Queen Esther',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Zone',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'MH',
                      child: Text('MH - Main Hall'),
                    ),
                    DropdownMenuItem(
                      value: 'FH',
                      child: Text('FH - Female Hall'),
                    ),
                    DropdownMenuItem(
                      value: 'BUSA',
                      child: Text('BUSA - Business Area'),
                    ),
                  ],
                  onChanged: (value) {
                    _addressZoneController.text = value ?? '';
                  },
                  hint: const Text('Select zone'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.prof,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
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
                            'Save Address',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createAddress() async {
    if (_addressNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter address name')),
      );
      return;
    }

    if (_addressZoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a zone')));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _addressZoneController.dispose();
    super.dispose();
  }
}
