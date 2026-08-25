import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/university_user.dart';
import 'supabase_service.dart';

class MobilePaymentSessionService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _sessionTokenKey = 'parkutem_mobile_payment_session';

  final SupabaseClient _client = SupabaseService.client;

  Future<UniversityUser> loginAndCreateSession({
    required String identifier,
    required String password,
  }) async {
    final cleanIdentifier = identifier.trim();
    final cleanPassword = password.trim();

    if (cleanIdentifier.isEmpty || cleanPassword.isEmpty) {
      throw const AuthException('Student/Staff ID and password are required.');
    }

    try {
      final response = await _client.functions.invoke(
        'mobile-auth-login',
        body: {'identifier': cleanIdentifier, 'password': cleanPassword},
      );

      final data = _asMap(response.data);
      if (data['success'] != true) {
        throw AuthException(
          data['error']?.toString() ??
              'Unable to create a secure mobile session.',
        );
      }

      final token = data['sessionToken']?.toString() ?? '';
      final userData = _asMap(data['user']);

      if (token.isEmpty || userData.isEmpty) {
        throw const AuthException('Invalid mobile login response.');
      }

      await _storage.write(key: _sessionTokenKey, value: token);
      return UniversityUser.fromJson(userData);
    } on AuthException {
      rethrow;
    } on FunctionException catch (error) {
      throw AuthException(_functionErrorMessage(error));
    } catch (error) {
      throw AuthException(_cleanError(error));
    }
  }

  Future<String?> getSessionToken() async {
    final value = await _storage.read(key: _sessionTokenKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> revokeCurrentSession() async {
    final token = await getSessionToken();

    try {
      if (token != null) {
        await _client.functions.invoke(
          'mobile-auth-logout',
          body: {'sessionToken': token},
        );
      }
    } catch (_) {
      // Local logout must still complete if the network is unavailable.
    } finally {
      await _storage.delete(key: _sessionTokenKey);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _functionErrorMessage(FunctionException error) {
    final details = error.details;

    if (details is Map) {
      final message = details['error']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    if (details is String && details.trim().isNotEmpty) {
      return details.trim();
    }

    return 'Unable to create a secure mobile session.';
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceAll('FunctionException(status: 400, details: ', '')
        .replaceAll('AuthException(message: ', '')
        .replaceAll('Exception: ', '')
        .trim();
  }
}
