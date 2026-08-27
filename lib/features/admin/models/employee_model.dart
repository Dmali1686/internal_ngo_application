/// Typed model for an employee record returned by the backend.
///
/// Used in:
///  - [RoleManagementScreen] — employee list with role assignment
///  - [AdminAnalyticsScreen] — per-employee performance stats
class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status; // 'active' | 'inactive'
  final String? avatarUrl;
  final String? joinedAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.joinedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      status: json['status'] as String? ?? 'active',
      avatarUrl: json['avatar_url'] as String?,
      joinedAt: json['joined_at'] as String?,
    );
  }

  /// Whether this employee's account is currently active.
  bool get isActive => status == 'active';

  /// Display-friendly role label (e.g. 'doctor' → 'Doctor').
  String get roleLabel {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'doctor':
        return 'Doctor';
      case 'nurse':
        return 'Nurse';
      case 'caretaker':
        return 'Caretaker';
      case 'driver':
        return 'Driver';
      case 'receptionist':
        return 'Receptionist';
      default:
        return role
            .split('_')
            .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  /// Copy with overridden fields.
  EmployeeModel copyWith({String? role, String? status}) {
    return EmployeeModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl,
      joinedAt: joinedAt,
    );
  }

  @override
  String toString() => 'EmployeeModel(id: $id, name: $name, role: $role)';
}

/// List of all assignable role keys (must match backend enum values).
class AppRoles {
  AppRoles._();

  static const String superAdmin = 'super_admin';
  static const String doctor = 'doctor';
  static const String nurse = 'nurse';
  static const String caretaker = 'caretaker';
  static const String driver = 'driver';
  static const String receptionist = 'receptionist';

  /// All roles Super Admin can assign to other users.
  static const List<String> assignable = [
    doctor,
    nurse,
    caretaker,
    driver,
    receptionist,
  ];

  /// Filter labels for the role filter chip row.
  static const List<String> filterLabels = [
    'All',
    'Doctor',
    'Nurse',
    'Caretaker',
    'Driver',
    'Receptionist',
  ];

  /// Maps display label back to role key.
  static String labelToKey(String label) {
    switch (label) {
      case 'Doctor':
        return doctor;
      case 'Nurse':
        return nurse;
      case 'Caretaker':
        return caretaker;
      case 'Driver':
        return driver;
      case 'Receptionist':
        return receptionist;
      default:
        return '';
    }
  }
}
