// widgets/list_staff.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/staff.dart';
import '../../services/staff_service.dart';
import '../../utils/validators.dart';
import '../widgets/custom_loader.dart';
import 'invite_staff.dart';
import 'suspend_staff.dart';
import 'dismiss_staff.dart';

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

  // Staff IDs with a suspend/reinstate/dismiss request currently in
  // flight. Only set once a confirmation dialog has been accepted and
  // the actual API call is about to fire — never while a dialog is
  // still open and the owner is deciding.
  final Set<String> _pendingActionStaffIds = {};

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
    final confirmed = await showSuspendStaffDialog(context, staff);
    if (confirmed != true) return;

    setState(() => _pendingActionStaffIds.add(staff.staffId));
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
    } finally {
      if (mounted) {
        setState(() => _pendingActionStaffIds.remove(staff.staffId));
      }
    }
  }

  Future<void> _handleReinstate(Staff staff) async {
    setState(() => _pendingActionStaffIds.add(staff.staffId));
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
    } finally {
      if (mounted) {
        setState(() => _pendingActionStaffIds.remove(staff.staffId));
      }
    }
  }

  Future<void> _handleDismiss(Staff staff, String staffEmail) async {
    final confirmed = await showDismissStaffDialog(context, staff, staffEmail);
    if (confirmed != true) return;

    setState(() => _pendingActionStaffIds.add(staff.staffId));
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
    } finally {
      if (mounted) {
        setState(() => _pendingActionStaffIds.remove(staff.staffId));
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
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final staff = staffList[index];
          final isProcessing = _pendingActionStaffIds.contains(staff.staffId);

          return _StaffCard(
            staff: staff,
            isProcessing: isProcessing,
            onSuspend: status == 'ACTIVE' ? () => _handleSuspend(staff) : null,
            onReinstate: status == 'SUSPENDED'
                ? () => _handleReinstate(staff)
                : null,
            onDismiss: status != 'DISMISSED'
                ? (email) => _handleDismiss(staff, email)
                : null,
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final bool isProcessing;
  final VoidCallback? onSuspend;
  final VoidCallback? onReinstate;
  final void Function(String email)? onDismiss;

  const _StaffCard({
    required this.staff,
    this.isProcessing = false,
    this.onSuspend,
    this.onReinstate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isProcessing ? 0.6 : 1,
      child: Container(
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
                    if (isProcessing)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CustomLoader(size: 18, strokeWidth: 2),
                      )
                    else ...[
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
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Dismiss'),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
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
