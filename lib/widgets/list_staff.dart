// widgets/list_staff.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/staff.dart';
import '../../services/staff_service.dart';
import '../../utils/validators.dart';
import '../widgets/custom_loader.dart';
import 'invite_staff.dart';

class ListStaffScreen extends StatefulWidget {
  final String storeId;

  const ListStaffScreen({super.key, required this.storeId});

  @override
  State<ListStaffScreen> createState() => _ListStaffScreenState();
}

class _ListStaffScreenState extends State<ListStaffScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final StaffService _staffService = StaffService();

  static const _statuses = ['ACTIVE', 'SUSPENDED', 'DISMISSED'];

  final Map<String, List<Staff>> _staffByStatus = {
    'ACTIVE': [],
    'SUSPENDED': [],
    'DISMISSED': [],
  };
  final Map<String, bool> _loadingByStatus = {
    'ACTIVE': true,
    'SUSPENDED': true,
    'DISMISSED': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    for (final status in _statuses) {
      _loadStaff(status);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff(String status) async {
    setState(() => _loadingByStatus[status] = true);

    final data = await _staffService.fetchStaff(
      storeId: widget.storeId,
      status: status,
    );

    final staffList = (data['staffs'] as List? ?? [])
        .map((s) => Staff.fromJson(s as Map<String, dynamic>))
        .toList();

    if (mounted) {
      setState(() {
        _staffByStatus[status] = staffList;
        _loadingByStatus[status] = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    for (final status in _statuses) {
      await _loadStaff(status);
    }
  }

  Future<void> _handleSuspend(Staff staff) async {
    try {
      await _staffService.suspendStaff(
        storeId: widget.storeId,
        staffId: staff.staffId,
      );
      if (mounted) {
        Validators.showSuccessSnackBar(context, '${staff.fullName} suspended');
        _refreshAll();
      }
    } catch (e) {
      if (mounted) Validators.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _handleReinstate(Staff staff) async {
    try {
      await _staffService.reinstateStaff(
        storeId: widget.storeId,
        staffId: staff.staffId,
      );
      if (mounted) {
        Validators.showSuccessSnackBar(context, '${staff.fullName} reinstated');
        _refreshAll();
      }
    } catch (e) {
      if (mounted) Validators.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _handleDismiss(Staff staff, String staffEmail) async {
    final confirmed = await _showDismissConfirmation(staff, staffEmail);
    if (confirmed != true) return;

    try {
      await _staffService.dismissStaff(
        storeId: widget.storeId,
        staffId: staff.staffId,
      );
      if (mounted) {
        Validators.showSuccessSnackBar(context, '${staff.fullName} dismissed');
        _refreshAll();
      }
    } catch (e) {
      if (mounted) Validators.showErrorSnackBar(context, e.toString());
    }
  }

  Future<bool?> _showDismissConfirmation(Staff staff, String staffEmail) {
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
                  onPressed: matches
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Dismiss'),
                ),
              ],
            );
          },
        );
      },
    );
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
          'Staff',
          style: AppTypography.headline.copyWith(
            color: AppColors.primary,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Suspended'),
            Tab(text: 'Dismissed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
        onPressed: () async {
          final invited = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => InviteStaffScreen(storeId: widget.storeId),
            ),
          );
          if (invited == true) _refreshAll();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) => _buildStaffTab(status)).toList(),
      ),
    );
  }

  Widget _buildStaffTab(String status) {
    final isLoading = _loadingByStatus[status] ?? false;
    final staffList = _staffByStatus[status] ?? [];

    if (isLoading) {
      return const Center(child: CustomLoader(size: 32, strokeWidth: 3));
    }

    if (staffList.isEmpty) {
      return Center(
        child: Text(
          'No ${status.toLowerCase()} staff',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadStaff(status),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: staffList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _StaffCard(
            staff: staffList[index],
            onSuspend: status == 'ACTIVE'
                ? () => _handleSuspend(staffList[index])
                : null,
            onReinstate: status == 'SUSPENDED'
                ? () => _handleReinstate(staffList[index])
                : null,
            onDismiss: status != 'DISMISSED'
                ? (email) => _handleDismiss(staffList[index], email)
                : null,
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback? onSuspend;
  final VoidCallback? onReinstate;
  final void Function(String email)? onDismiss;

  const _StaffCard({
    required this.staff,
    this.onSuspend,
    this.onReinstate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: Text(
                  staff.firstName.isNotEmpty
                      ? staff.firstName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.fullName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staff.roleName ?? 'No role assigned',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: staff.status),
            ],
          ),
          if (staff.suspendedAt != null || staff.dismissedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              staff.suspendedAt != null
                  ? 'Suspended: ${staff.suspendedAt}'
                  : 'Dismissed: ${staff.dismissedAt}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
          if (onSuspend != null || onReinstate != null || onDismiss != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSuspend != null)
                    TextButton(
                      onPressed: onSuspend,
                      child: const Text('Suspend'),
                    ),
                  if (onReinstate != null)
                    TextButton(
                      onPressed: onReinstate,
                      child: const Text('Reinstate'),
                    ),
                  if (onDismiss != null)
                    TextButton(
                      onPressed: () => onDismiss!(_staffEmailPlaceholder),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Dismiss'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // The list-staff endpoint doesn't return email, only the profile/role
  // endpoints do. If you need the real email for the dismiss confirmation,
  // fetch it via fetchRoles(showStaff: true) or add it server-side to the
  // staff list response — this placeholder should be replaced.
  String get _staffEmailPlaceholder => staff.fullName;
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'SUSPENDED':
        return Colors.orange;
      case 'DISMISSED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
