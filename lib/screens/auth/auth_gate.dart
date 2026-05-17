// =====================================================
// IMPORTS
// =====================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

// =====================================================
// AUTH GATE SCREEN
// =====================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static const String routeName = '/auth';

  @override
  State<AuthGate> createState() => _AuthGateState();
}

// =====================================================
// AUTH GATE STATE
// =====================================================

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  StreamSubscription<AuthState>? _authSubscription;
  Session? _session;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    _session = _authService.currentSession;

    _authSubscription = _authService.authStateChanges.listen((authState) {
      if (!mounted) return;

      setState(() {
        _session = authState.session;
      });
    });
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}