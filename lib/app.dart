import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';

import 'screens/home/home_screen.dart';
import 'screens/parking/parking_screen.dart';
import 'screens/payment/payment_method_screen.dart';
import 'screens/reservation/reservation_screen.dart';
import 'screens/wallet/wallet_screen.dart';

import 'screens/profile/device_sessions_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/profile/notification_screen.dart';
import 'screens/profile/notification_settings_screen.dart';
import 'screens/profile/parking_history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/security_screen.dart';
import 'screens/profile/university_portal_screen.dart';
import 'screens/profile/vehicle_registration_screen.dart';

// =====================================================
// ROOT APPLICATION
// =====================================================

class ParkUTeMApp extends StatelessWidget {
  const ParkUTeMApp({super.key});

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkUTeM',
      debugShowCheckedModeBanner: false,

      // =====================================================
      // THEME
      // =====================================================

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // =====================================================
      // STARTUP
      // =====================================================

      home: const SplashScreen(),

      // =====================================================
      // ROUTES
      // =====================================================

      routes: {
        '/auth': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),

        '/home': (context) => const HomeScreen(),
        '/parking': (context) => const ParkingScreen(),
        '/reserve': (context) => const ReservationScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/payment-method': (context) => const PaymentMethodScreen(),

        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/notification-settings': (context) =>
            const NotificationSettingsScreen(),
        '/security': (context) => const SecurityScreen(),
        '/parking-history': (context) => const ParkingHistoryScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/university-portal': (context) => const UniversityPortalScreen(),
        '/device-sessions': (context) => const DeviceSessionsScreen(),
        '/vehicle-registration': (context) =>
            const VehicleRegistrationScreen(),
      },

      // =====================================================
      // UNKNOWN ROUTE FALLBACK
      // =====================================================

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const AuthGate(),
        );
      },
    );
  }
}