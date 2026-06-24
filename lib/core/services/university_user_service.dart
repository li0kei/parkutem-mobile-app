// =====================================================
// IMPORTS
// =====================================================

import '../../models/university_user.dart';
import 'auth_service.dart';

// =====================================================
// UNIVERSITY USER SERVICE
// =====================================================

class UniversityUserService {
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER PROFILE
  // =====================================================

  Future<UniversityUser?> getCurrentUserProfile() async {
    return _authService.getCurrentUniversityUser();
  }

  // =====================================================
  // UPDATE LAST ACTIVITY
  // =====================================================

  Future<void> updateLastActivity() async {
    // Custom mobile login does not use Supabase Auth session.
    // Last activity is already updated during verify_university_login().
    // Keep this as no-op to avoid RLS/auth.currentUser issue.
    return;
  }
}
