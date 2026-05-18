// =====================================================
// USER NOTIFICATION TYPE
// =====================================================

enum UserNotificationType {
  reservation,
  wallet,
  anpr,
  support,
  reminder,
  system,
}

// =====================================================
// USER NOTIFICATION MODEL
// =====================================================

class UserNotification {
  final String id;
  final UserNotificationType type;
  final String title;
  final String message;
  final String? relatedReference;
  final String? relatedRoute;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const UserNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.relatedReference,
    required this.relatedRoute,
    required this.metadata,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  // =====================================================
  // COPY WITH
  // =====================================================

  UserNotification copyWith({
    String? id,
    UserNotificationType? type,
    String? title,
    String? message,
    String? relatedReference,
    String? relatedRoute,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return UserNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedReference: relatedReference ?? this.relatedReference,
      relatedRoute: relatedRoute ?? this.relatedRoute,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =====================================================
  // FROM JSON
  // =====================================================

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id']?.toString() ?? '',
      type: _mapType(json['notification_type']?.toString()),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '-',
      relatedReference: json['related_reference']?.toString(),
      relatedRoute: json['related_route']?.toString(),
      metadata: _mapMetadata(json['metadata']),
      isRead: json['is_read'] == true,
      readAt: _toDateTime(json['read_at']),
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static UserNotificationType _mapType(String? value) {
    switch (value?.toLowerCase()) {
      case 'reservation':
        return UserNotificationType.reservation;
      case 'wallet':
        return UserNotificationType.wallet;
      case 'anpr':
        return UserNotificationType.anpr;
      case 'support':
        return UserNotificationType.support;
      case 'reminder':
        return UserNotificationType.reminder;
      case 'system':
      default:
        return UserNotificationType.system;
    }
  }

  static Map<String, dynamic> _mapMetadata(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    final DateTime? parsed = DateTime.tryParse(value.toString());

    if (parsed == null) return null;

    return parsed.toUtc().add(const Duration(hours: 8));
  }
}