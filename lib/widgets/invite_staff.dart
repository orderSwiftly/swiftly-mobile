// widgets/invite_staff.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/staff_service.dart';
import '../../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_loader.dart';

class InviteStaffScreen extends StatefulWidget {
  final String storeId;

  const InviteStaffScreen({super.key, required this.storeId});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteRow {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      // role_id intentionally omitted — invited without a role,
      // assigned later from the roles screen
    };
  }
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _staffService = StaffService();

  final List<_InviteRow> _rows = [_InviteRow()];
  bool _isLoading = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_InviteRow()));
  }

  void _removeRow(int index) {
    if (_rows.length == 1) return; // always keep at least one row
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _handleInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final staffList = _rows.map((row) => row.toJson()).toList();

      await _staffService.inviteStaff(
        storeId: widget.storeId,
        staffList: staffList,
      );

      if (mounted) {
        Validators.showSuccessSnackBar(
          context,
          _rows.length == 1
              ? 'Staff member invited successfully!'
              : '${_rows.length} staff members invited successfully!',
        );
        Navigator.pop(context, true); // true tells caller list should refresh
      }
    } catch (e) {
      if (mounted) {
        Validators.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text(
          'Invite Staff',
          style: AppTypography.headline.copyWith(
            color: AppColors.primary,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    return _InviteRowCard(
                      row: _rows[index],
                      index: index,
                      canRemove: _rows.length > 1,
                      onRemove: () => _removeRow(index),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add another staff member'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      disabledBackgroundColor: AppColors.accent.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    child: _isLoading
                        ? const CustomLoader(
                            size: 24,
                            strokeWidth: 2.5,
                            color: Colors.white,
                          )
                        : Text(
                            _rows.length == 1
                                ? 'Send Invite'
                                : 'Send ${_rows.length} Invites',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteRowCard extends StatelessWidget {
  final _InviteRow row;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  const _InviteRowCard({
    required this.row,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staff Member ${index + 1}',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey,
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: row.firstNameController,
                  label: 'First Name',
                  hint: 'John',
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: row.lastNameController,
                  label: 'Last Name',
                  hint: 'Doe',
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: row.emailController,
            label: 'Email Address',
            hint: 'staff@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: row.phoneController,
            label: 'Phone Number',
            hint: '+2348012345678',
            keyboardType: TextInputType.phone,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
