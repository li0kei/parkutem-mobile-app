// =====================================================
// UNIVERSITY USER MODEL
// =====================================================

class UniversityUser {
  final String id;
  final String universityId;
  final String fullName;
  final String role;
  final String email;
  final String? phoneNumber;
  final String faculty;
  final String department;
  final double walletBalance;
  final String accountStatus;
  final bool mustChangePassword;
  final DateTime? lastLoginAt;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UniversityUser({
    required this.id,
    required this.universityId,
    required this.fullName,
    required this.role,
    required this.email,
    required this.phoneNumber,
    required this.faculty,
    required this.department,
    required this.walletBalance,
    required this.accountStatus,
    required this.mustChangePassword,
    required this.lastLoginAt,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory UniversityUser.fromJson(Map<String, dynamic> json) {
    return UniversityUser(
      id: json['id']?.toString() ?? '',
      universityId: json['university_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: _toNullableString(json['phone_number']),
      faculty: json['faculty']?.toString() ?? '-',
      department: json['department']?.toString() ?? '-',
      walletBalance: _toDouble(json['wallet_balance']),
      accountStatus: json['account_status']?.toString() ?? 'inactive',
      mustChangePassword: _toBool(json['must_change_password']),
      lastLoginAt: _toDateTime(json['last_login_at']),
      lastActivityAt: _toDateTime(json['last_activity_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  // =====================================================
  // TO JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'full_name': fullName,
      'role': role,
      'email': email,
      'phone_number': phoneNumber,
      'faculty': faculty,
      'department': department,
      'wallet_balance': walletBalance,
      'account_status': accountStatus,
      'must_change_password': mustChangePassword,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  UniversityUser copyWith({
    String? id,
    String? universityId,
    String? fullName,
    String? role,
    String? email,
    String? phoneNumber,
    String? faculty,
    String? department,
    double? walletBalance,
    String? accountStatus,
    bool? mustChangePassword,
    DateTime? lastLoginAt,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UniversityUser(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      walletBalance: walletBalance ?? this.walletBalance,
      accountStatus: accountStatus ?? this.accountStatus,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final String text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
