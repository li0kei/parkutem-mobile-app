// =====================================================
// IMPORTS
// =====================================================

import '../../models/user_notification.dart';
import 'supabase_service.dart';

// =====================================================
// NOTIFICATION SERVICE
// =====================================================

class NotificationService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER NOTIFICATIONS
  // =====================================================

  Future<List<UserNotification>> getCurrentUserNotifications() async {
    final List<dynamic> records = await _client.rpc(
      'get_current_user_notifications',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return UserNotification.fromJson(data);
    }).toList();
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
  final dynamic result = await _client.rpc(
    'mark_current_user_notification_as_read',
    params: {
      'p_notification_id': notificationId,
    },
  );

  if (result is bool) return result;

  return result.toString().toLowerCase() == 'true';
}

  // =====================================================
  // MARK ALL AS READ
  // =====================================================

  Future<int> markAllAsRead() async {
    final dynamic result = await _client.rpc(
      'mark_current_user_notifications_as_read',
    );

    if (result is int) return result;

    return int.tryParse(result.toString()) ?? 0;
  }
}