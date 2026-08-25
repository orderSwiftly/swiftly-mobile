// screens/staff_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/list_staff.dart';
import '../../widgets/invite_staff.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _storeId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveStoreId();
  }

  Future<void> _resolveStoreId() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // store_id is saved as part of the staff profile / user data blob
    // after login (see 'user_data' key in ApiService) — read it back out
    // here rather than re-fetching the profile every time this screen opens.
    final storeId = await _storage.read(key: 'store_id');

    if (!mounted) return;

    if (storeId == null || storeId.isEmpty) {
      setState(() {
        _error = 'No store found for this account.';
        _loading = false;
      });
    } else {
      setState(() {
        _storeId = storeId;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _storeId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error ?? 'Something went wrong'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resolveStoreId,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ListStaffScreen owns the tabs (Active/Suspended/Dismissed), the
    // staff cards, and the FAB that pushes to InviteStaffScreen — this
    // screen's only job is resolving storeId and handing off.
    return ListStaffScreen(storeId: _storeId!);
  }
}
