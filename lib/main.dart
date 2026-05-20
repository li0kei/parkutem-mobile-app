// =====================================================
// IMPORTS
// =====================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/supabase_service.dart';

// =====================================================
// MAIN
// =====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SupabaseService.initialize();

  await PushNotificationService.init();

  runApp(const ParkUTeMApp());
}