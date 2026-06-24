// =====================================================
// IMPORTS
// =====================================================

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/supabase_service.dart';
import 'firebase_options.dart';

// =====================================================
// MAIN
// =====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };

  runZonedGuarded(
    () async {
      String? startupError;

      try {
        await dotenv.load(fileName: '.env');
      } catch (error, stackTrace) {
        startupError = 'Failed to load .env file: $error';
        debugPrint(startupError);
        debugPrintStack(stackTrace: stackTrace);
      }

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      } catch (error, stackTrace) {
        debugPrint('Firebase init failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      try {
        await SupabaseService.initialize();
      } catch (error, stackTrace) {
        startupError = 'Supabase init failed: $error';
        debugPrint(startupError);
        debugPrintStack(stackTrace: stackTrace);
      }

      runApp(
        startupError == null
            ? const ParkUTeMApp()
            : StartupErrorApp(message: startupError),
      );

      try {
        await PushNotificationService.init();
      } catch (error, stackTrace) {
        debugPrint('Push notification init failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}

// =====================================================
// STARTUP ERROR APP
// =====================================================

class StartupErrorApp extends StatelessWidget {
  final String message;

  const StartupErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkUTeM Startup Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFECACA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 44,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Unable to start ParkUTeM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
