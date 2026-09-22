// widgets/dismiss_staff.dart
import 'package:flutter/material.dart';
import '../../models/staff.dart';

/// "Type to confirm" dismiss dialog. Returns true if the owner typed a
/// matching email and confirmed, false/null otherwise. Does NOT call the
/// API itself — same contract as showSuspendStaffDialog.
Future<bool?> showDismissStaffDialog(
  BuildContext context,
  Staff staff,
  String staffEmail,
) {
  final confirmController = TextEditingController();

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final matches =
              confirmController.text.trim().toLowerCase() ==
              staffEmail.trim().toLowerCase();

          return AlertDialog(
            title: const Text('Dismiss Staff'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is permanent. ${staff.fullName} will lose access '
                  'immediately and cannot be undismissed — they would need '
                  'to be invited again as a new staff member.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Type "$staffEmail" to confirm:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: matches ? () => Navigator.pop(context, true) : null,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    },
  ).then((result) {
    confirmController.dispose();
    return result;
  });
}
