// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

// =====================================================
// AUTH SERVICE
// =====================================================

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // =====================================================
  // SIGN IN WITH UNIVERSITY ID
  // =====================================================

  Future<AuthResponse> signInWithUniversityId({
    required String universityId,
    required String password,
  }) async {
    final String cleanUniversityId = universityId.trim();

    if (cleanUniversityId.isEmpty) {
      throw const AuthException('Student/Staff ID is required.');
    }

    if (password.isEmpty) {
      throw const AuthException('Password is required.');
    }

    final List<dynamic> records = await _client.rpc(
      'lookup_university_login',
      params: {
        'p_university_id': cleanUniversityId,
      },
    );

    if (records.isEmpty) {
      throw const AuthException(
        'Student/Staff ID not found in UTeM records.',
      );
    }

    final Map<String, dynamic> universityUser =
        Map<String, dynamic>.from(records.first as Map);

    final String email = universityUser['email']?.toString().trim() ?? '';

    if (email.isEmpty) {
      throw const AuthException(
        'This university record does not have an email address.',
      );
    }

    final String accountStatus =
        universityUser['account_status']?.toString().toLowerCase() ?? 'inactive';

    if (accountStatus != 'active') {
      throw AuthException(
        'This account is currently $accountStatus. Please contact admin.',
      );
    }

    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =====================================================
  // SIGN OUT
  // =====================================================

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}