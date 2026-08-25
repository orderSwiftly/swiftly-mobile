// models/staff.dart

class Staff {
  final String staffId;
  final String firstName;
  final String lastName;
  final String status; // ACTIVE, SUSPENDED, DISMISSED
  final String? roleId;
  final String? roleName;
  final String? suspendedAt; // present only when status == SUSPENDED
  final String? dismissedAt; // present only when status == DISMISSED

  Staff({
    required this.staffId,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.roleId,
    this.roleName,
    this.suspendedAt,
    this.dismissedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['staff_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      roleId: json['role_id'] as String?,
      roleName: json['role_name'] as String?,
      suspendedAt: json['suspended_at'] as String?,
      dismissedAt: json['dismissed_at'] as String?,
    );
  }
}

class StaffRole {
  final String roleId;
  final String name;
  final Map<String, bool> permissions;
  final List<Staff>? members; // only present when fetched with showStaff

  StaffRole({
    required this.roleId,
    required this.name,
    required this.permissions,
    this.members,
  });

  factory StaffRole.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] as Map<String, dynamic>? ?? {};

    List<Staff>? members;
    if (json['memberships'] != null) {
      members = (json['memberships'] as List)
          .map(
            (m) => Staff(
              staffId: m['staff_id'] as String,
              firstName: m['first_name'] as String? ?? '',
              lastName: m['last_name'] as String? ?? '',
              status: m['status'] as String? ?? 'ACTIVE',
            ),
          )
          .toList();
    }

    return StaffRole(
      roleId: json['role_id'] as String,
      name: json['name'] as String? ?? '',
      permissions: rawPermissions.map(
        (key, value) => MapEntry(key, value as bool),
      ),
      members: members,
    );
  }
}

class StaffPermission {
  final String permission;
  final String title;
  final String description;

  StaffPermission({
    required this.permission,
    required this.title,
    required this.description,
  });

  factory StaffPermission.fromJson(Map<String, dynamic> json) {
    return StaffPermission(
      permission: json['permission'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
