// =====================================================
// IMPORTS
// =====================================================

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// BACKGROUND HANDLER
// =====================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification received: ${message.messageId}');
}

// =====================================================
// PUSH NOTIFICATION SERVICE
// =====================================================

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'parkutem_alerts',
        'ParkUTeM Alerts',
        description: 'Parking, ANPR, reservation, and wallet notifications.',
        importance: Importance.high,
      );

  // =====================================================
  // INIT
  // =====================================================

  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();

    await saveCurrentToken();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _messaging.onTokenRefresh.listen((token) async {
      await _saveTokenToSupabase(token);
    });
  }

  // =====================================================
  // REQUEST PERMISSION
  // =====================================================

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // =====================================================
  // LOCAL NOTIFICATION SETUP
  // =====================================================

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings notificationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: notificationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped payload: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  // =====================================================
  // FOREGROUND MESSAGE
  // =====================================================

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // =====================================================
  // NOTIFICATION TAP
  // =====================================================

  static void _handleNotificationTap(RemoteMessage message) {
    final String? type = message.data['type'];
    final String? targetId = message.data['target_id'];

    debugPrint('Notification tapped type: $type');
    debugPrint('Notification tapped target id: $targetId');
  }

  // =====================================================
  // SAVE CURRENT FCM TOKEN
  // =====================================================

  static Future<void> saveCurrentToken() async {
    final String? token = await _messaging.getToken();

    debugPrint('FCM TOKEN: $token');

    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _saveTokenToSupabase(token);
  }

  // =====================================================
  // SAVE TOKEN TO SUPABASE
  // =====================================================

  static Future<void> _saveTokenToSupabase(String token) async {
    final currentUser = await AuthService().getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      debugPrint('No custom university user session. FCM token not saved yet.');
      return;
    }

    try {
      await SupabaseService.client.rpc(
        'save_university_user_notification_token',
        params: {
          'p_university_id': currentUser.universityId,
          'p_fcm_token': token,
          'p_platform': Platform.operatingSystem,
        },
      );

      debugPrint('FCM token saved for ${currentUser.universityId}.');
    } catch (error) {
      debugPrint('FCM token was not saved: $error');
    }
  }
}
