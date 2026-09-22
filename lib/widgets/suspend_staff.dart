// widgets/suspend_staff.dart
import 'package:flutter/material.dart';
import '../../models/staff.dart';

/// Confirmation dialog shown before suspending a staff member.
/// Returns true if the owner confirmed, false/null if they backed out.
/// Does NOT call the API itself — the caller performs the actual
/// suspend request after this resolves to true.
Future<bool?> showSuspendStaffDialog(BuildContext context, Staff staff) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Suspend Staff'),
      content: Text(
        '${staff.fullName} will lose access to the store until reinstated. '
        'You can reinstate them at any time from the Suspended tab.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
          child: const Text('Suspend'),
        ),
      ],
    ),
  );
}
