// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/slim_loading_bar.dart';
import 'auth_gate.dart';

// =====================================================
// SPLASH SCREEN
// =====================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// =====================================================
// SPLASH SCREEN STATE
// =====================================================

class _SplashScreenState extends State<SplashScreen> {
  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // =====================================================
                // LOGO
                // =====================================================

                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.24),
                        blurRadius: 45,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Image.asset(
                      AppAssets.parkutemLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // =====================================================
                // APP NAME
                // =====================================================

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Park',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      TextSpan(
                        text: 'UTeM',
                        style: TextStyle(
                          color: AppTheme.primaryCyan,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Smart Campus Parking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.8,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'ANPR  •  Reservation  •  Live Parking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),

                const Spacer(flex: 2),

                // =====================================================
                // LOADING BAR
                // =====================================================

                const SlimLoadingBar(),

                const SizedBox(height: 16),

                Text(
                  'Initializing ParkUTeM...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 42),
              ],
            ),
          ),
        ),
      ),
    );
  }
}