// =====================================================
// IMPORTS
// =====================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../models/university_user.dart';
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

  StreamSubscription<UniversityUser?>? _authSubscription;

  UniversityUser? _currentUser;
  bool _isLoading = true;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();

    _authSubscription = _authService.universityAuthStateChanges.listen((user) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  // =====================================================
  // LOAD CURRENT USER
  // =====================================================

  Future<void> _loadCurrentUser() async {
    try {
      final UniversityUser? user = await _authService
          .getCurrentUniversityUser();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
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
    if (_isLoading) {
      return const _AuthLoadingScreen();
    }

    if (_currentUser == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}

// =====================================================
// AUTH LOADING SCREEN
// =====================================================

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
