// =====================================================
// IMPORTS
// =====================================================

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/university_user.dart';
import 'supabase_service.dart';

// =====================================================
// AUTH SERVICE
// =====================================================

class AuthService {
  AuthService();

  final SupabaseClient _client = SupabaseService.client;

  static const String _userSessionKey = 'parkutem_university_user_session';

  static final StreamController<UniversityUser?> _authController =
      StreamController<UniversityUser?>.broadcast();

  // =====================================================
  // LEGACY SUPABASE AUTH GETTERS
  // Keep this for compatibility with old code.
  // =====================================================

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // =====================================================
  // CUSTOM UNIVERSITY AUTH STREAM
  // =====================================================

  Stream<UniversityUser?> get universityAuthStateChanges {
    return _authController.stream;
  }

  // =====================================================
  // GET STORED UNIVERSITY USER
  // =====================================================

  Future<UniversityUser?> getCurrentUniversityUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawUser = prefs.getString(_userSessionKey);

    if (rawUser == null || rawUser.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(rawUser) as Map,
      );

      return UniversityUser.fromJson(json);
    } catch (_) {
      await prefs.remove(_userSessionKey);
      return null;
    }
  }

  // =====================================================
  // CHECK SIGNED IN
  // =====================================================

  Future<bool> isSignedIn() async {
    final UniversityUser? user = await getCurrentUniversityUser();

    return user != null;
  }

  // =====================================================
  // SIGN IN WITH UNIVERSITY ID / EMAIL
  // =====================================================

  Future<UniversityUser> signInWithUniversityId({
    required String universityId,
    required String password,
  }) async {
    final String identifier = universityId.trim();
    final String cleanPassword = password.trim();

    if (identifier.isEmpty) {
      throw const AuthException('Student/Staff ID or email is required.');
    }

    if (cleanPassword.isEmpty) {
      throw const AuthException('Password is required.');
    }

    try {
      final dynamic response = await _client.rpc(
        'verify_university_login',
        params: {'p_identifier': identifier, 'p_plain_password': cleanPassword},
      );

      final Map<String, dynamic> userJson = _parseRpcUserResponse(response);
      final UniversityUser universityUser = UniversityUser.fromJson(userJson);

      await _saveUniversityUser(universityUser);

      _authController.add(universityUser);

      return universityUser;
    } catch (error) {
      throw AuthException(_cleanAuthError(error));
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final UniversityUser? currentUser = await getCurrentUniversityUser();

    if (currentUser == null) {
      throw const AuthException('No active user session found.');
    }

    final String cleanCurrentPassword = currentPassword.trim();
    final String cleanNewPassword = newPassword.trim();

    if (cleanCurrentPassword.isEmpty) {
      throw const AuthException('Current password is required.');
    }

    if (cleanNewPassword.length < 8) {
      throw const AuthException('New password must be at least 8 characters.');
    }

    try {
      await _client.rpc(
        'change_university_user_password',
        params: {
          'p_user_id': currentUser.id,
          'p_current_password': cleanCurrentPassword,
          'p_new_password': cleanNewPassword,
        },
      );

      final UniversityUser updatedUser = currentUser.copyWith(
        mustChangePassword: false,
      );

      await _saveUniversityUser(updatedUser);

      _authController.add(updatedUser);
    } catch (error) {
      throw AuthException(_cleanAuthError(error));
    }
  }

  // =====================================================
  // REFRESH LOCAL USER SESSION
  // =====================================================

  Future<void> refreshLocalUser(UniversityUser user) async {
    await _saveUniversityUser(user);
    _authController.add(user);
  }

  // =====================================================
  // SIGN OUT
  // =====================================================

  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userSessionKey);

    if (_client.auth.currentSession != null) {
      await _client.auth.signOut();
    }

    _authController.add(null);
  }

  // =====================================================
  // SAVE UNIVERSITY USER
  // =====================================================

  Future<void> _saveUniversityUser(UniversityUser user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
  }

  // =====================================================
  // PARSE RPC RESPONSE
  // =====================================================

  Map<String, dynamic> _parseRpcUserResponse(dynamic response) {
    if (response == null) {
      throw const AuthException('Invalid login response from server.');
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    if (response is List && response.isNotEmpty) {
      final dynamic firstRecord = response.first;

      if (firstRecord is Map<String, dynamic>) {
        return firstRecord;
      }

      if (firstRecord is Map) {
        return Map<String, dynamic>.from(firstRecord);
      }
    }

    if (response is String && response.trim().isNotEmpty) {
      final dynamic decoded = jsonDecode(response);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw const AuthException('Unable to read login response from server.');
  }

  // =====================================================
  // CLEAN AUTH ERROR
  // =====================================================

  String _cleanAuthError(Object error) {
    final String rawMessage = error.toString();

    if (rawMessage.contains('Invalid ID/email or password')) {
      return 'Invalid Student/Staff ID or password.';
    }

    if (rawMessage.contains('Account is not active')) {
      return 'This account is not active. Please contact admin.';
    }

    if (rawMessage.contains('Password must be at least')) {
      return 'Password must be at least 8 characters.';
    }

    if (rawMessage.contains('Current password is incorrect')) {
      return 'Current password is incorrect.';
    }

    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('Failed host lookup')) {
      return 'Network error. Please check your internet connection.';
    }

    return rawMessage
        .replaceAll('AuthException(message: ', '')
        .replaceAll('PostgrestException(message: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll(')', '')
        .trim();
  }
}
