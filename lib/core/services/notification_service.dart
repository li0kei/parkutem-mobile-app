// =====================================================
// IMPORTS
// =====================================================

import '../../models/user_notification.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// NOTIFICATION SERVICE
// =====================================================

class NotificationService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER NOTIFICATIONS
  // =====================================================

  Future<List<UserNotification>> getCurrentUserNotifications() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return [];
    }

    try {
      final dynamic response = await _client.rpc(
        'get_university_user_notifications',
        params: {'p_university_id': currentUser.universityId},
      );

      if (response is! List) {
        return [];
      }

      return response.map((record) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          record as Map,
        );

        return UserNotification.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // =====================================================
  // GET UNREAD COUNT
  // =====================================================

  Future<int> getUnreadCount() async {
    final List<UserNotification> notifications =
        await getCurrentUserNotifications();

    return notifications.where((item) => !item.isRead).length;
  }

  // =====================================================
  // MARK ONE AS READ
  // =====================================================

  Future<bool> markOneAsRead(String notificationId) async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return false;
    }

    try {
      final dynamic result = await _client.rpc(
        'mark_university_user_notification_as_read',
        params: {
          'p_university_id': currentUser.universityId,
          'p_notification_id': notificationId,
        },
      );

      if (result is bool) {
        return result;
      }

      return result.toString().toLowerCase() == 'true';
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================

  Future<int> markAllAsRead() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return 0;
    }

    try {
      final dynamic result = await _client.rpc(
        'mark_university_user_notifications_as_read',
        params: {'p_university_id': currentUser.universityId},
      );

      if (result is int) {
        return result;
      }

      return int.tryParse(result.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
