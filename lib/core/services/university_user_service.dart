// =====================================================
// IMPORTS
// =====================================================

import '../../models/university_user.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// UNIVERSITY USER SERVICE
// =====================================================

class UniversityUserService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER PROFILE
  // Always refresh from Supabase, then update local session.
  // =====================================================

  Future<UniversityUser?> getCurrentUserProfile() async {
    final UniversityUser? localUser =
        await _authService.getCurrentUniversityUser();

    if (localUser == null || localUser.universityId.trim().isEmpty) {
      return null;
    }

    try {
      final dynamic response = await _client.rpc(
        'get_university_user_profile',
        params: {
          'p_university_id': localUser.universityId,
        },
      );

      final Map<String, dynamic> data = _parseProfileResponse(response);
      final UniversityUser freshUser = UniversityUser.fromJson(data);

      await _authService.refreshLocalUser(freshUser);

      return freshUser;
    } catch (_) {
      return localUser;
    }
  }

  // =====================================================
  // UPDATE LAST ACTIVITY
  // =====================================================

  Future<void> updateLastActivity() async {
    final UniversityUser? localUser =
        await _authService.getCurrentUniversityUser();

    if (localUser == null || localUser.universityId.trim().isEmpty) {
      return;
    }

    try {
      await _client
          .from('university_users')
          .update({
            'last_activity_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('university_id', localUser.universityId);
    } catch (_) {
      return;
    }
  }

  // =====================================================
  // PARSE PROFILE RESPONSE
  // =====================================================

  Map<String, dynamic> _parseProfileResponse(dynamic response) {
    if (response == null) {
      throw Exception('Profile response is empty.');
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

    throw Exception('Invalid profile response format.');
  }
}