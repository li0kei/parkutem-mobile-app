import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';
import 'notification_preference_service.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background notification received.');
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final NotificationPreferenceService _preferenceService =
      NotificationPreferenceService();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'parkutem_alerts',
        'ParkUTeM Alerts',
        description: 'Parking, ANPR, reservation, wallet and support alerts.',
        importance: Importance.high,
      );

  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await saveCurrentToken();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _messaging.onTokenRefresh.listen(_saveTokenToSupabase);
  }

  static Future<void> _requestPermission() async {
    final preferences = await _preferenceService.load();
    if (!preferences.enabled) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: preferences.sound,
    );
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('ParkUTeM notification opened.');
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

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final preferences = await _preferenceService.load();
    final type = message.data['type']?.toString();

    if (!preferences.allowsType(type)) {
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
          playSound: preferences.sound,
          enableVibration: preferences.vibration,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification opened: ${message.data['type'] ?? 'system'}');
  }

  static Future<void> saveCurrentToken() async {
    final token = await _messaging.getToken();

    if (token == null || token.trim().isEmpty) {
      return;
    }

    await _saveTokenToSupabase(token);
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    final currentUser = await AuthService().getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
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
    } catch (error) {
      debugPrint('FCM token sync failed.');
    }
  }
}
