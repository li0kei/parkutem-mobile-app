// =====================================================
// IMPORTS
// =====================================================

import '../../models/anpr_log_record.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// ANPR LOG SERVICE
// =====================================================

class AnprLogService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER ANPR LOGS
  // =====================================================

  Future<List<AnprLogRecord>> getCurrentUserAnprLogs() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return [];
    }

    try {
      final dynamic response = await _client.rpc(
        'get_university_user_anpr_logs',
        params: {'p_university_id': currentUser.universityId},
      );

      if (response == null) {
        return [];
      }

      if (response is! List) {
        return [];
      }

      return response.map((record) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          record as Map,
        );

        return AnprLogRecord.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
