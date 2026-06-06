import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_colors.dart';

class CreateLandmarkScreen extends StatefulWidget {
  // Changed class name
  final String store_zone_id;

  const CreateLandmarkScreen({
    super.key,
    required this.store_zone_id,
  }); // Changed constructor name

  @override
  State<CreateLandmarkScreen> createState() => _CreateLandmarkScreenState(); // Changed state class
}

class _CreateLandmarkScreenState extends State<CreateLandmarkScreen> {
  // Changed class name
  final TextEditingController _landmarkNameController =
      TextEditingController(); // Changed controller name
  final TextEditingController _landmarkZoneController =
      TextEditingController(); // Changed controller name
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
        title: const Text('Add New Landmark'), // Changed text
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
                  'Landmark Name', // Changed text
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _landmarkNameController, // Changed controller
                  decoration: InputDecoration(
                    hintText: 'e.g., Bethel, Samuel Akande, Queen Esther',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Zone', // This stays the same
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
                    _landmarkZoneController.text =
                        value ?? ''; // Changed controller
                  },
                  hint: const Text('Select zone'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _createLandmark, // Changed method name
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
                            'Save Landmark', // Changed text
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

  Future<void> _createLandmark() async {
    // Changed method name
    if (_landmarkNameController.text.isEmpty) {
      // Changed controller
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter landmark name'),
        ), // Changed text
      );
      return;
    }

    if (_landmarkZoneController.text.isEmpty) {
      // Changed controller
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a zone')));
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Replace this with actual API call to create landmark
    // Example:
    // try {
    //   await _checkoutService.createLandmark(
    //     widget.store_zone_id,
    //     _landmarkNameController.text,
    //     _landmarkZoneController.text,
    //   );
    //   Navigator.pop(context, true);
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error creating landmark: $e')),
    //   );
    // } finally {
    //   setState(() => _isLoading = false);
    // }

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _landmarkNameController.dispose(); // Changed controller
    _landmarkZoneController.dispose(); // Changed controller
    super.dispose();
  }
}
