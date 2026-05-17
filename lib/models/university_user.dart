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
      phoneNumber: json['phone_number']?.toString(),
      faculty: json['faculty']?.toString() ?? '-',
      department: json['department']?.toString() ?? '-',
      walletBalance: _toDouble(json['wallet_balance']),
      accountStatus: json['account_status']?.toString() ?? 'inactive',
      lastActivityAt: _toDateTime(json['last_activity_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}