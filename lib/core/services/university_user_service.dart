// =====================================================
// IMPORTS
// =====================================================

import '../../models/university_user.dart';
import 'supabase_service.dart';

// =====================================================
// UNIVERSITY USER SERVICE
// =====================================================

class UniversityUserService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER PROFILE
  // =====================================================

  Future<UniversityUser?> getCurrentUserProfile() async {
    final String? email = _client.auth.currentUser?.email;

    if (email == null || email.trim().isEmpty) {
      return null;
    }

    final Map<String, dynamic>? data = await _client
        .from('university_users')
        .select()
        .eq('email', email.trim())
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UniversityUser.fromJson(data);
  }

  // =====================================================
  // UPDATE LAST ACTIVITY
  // =====================================================

  Future<void> updateLastActivity() async {
    final String? email = _client.auth.currentUser?.email;

    if (email == null || email.trim().isEmpty) {
      return;
    }

    await _client
        .from('university_users')
        .update({
          'last_activity_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('email', email.trim());
  }
}