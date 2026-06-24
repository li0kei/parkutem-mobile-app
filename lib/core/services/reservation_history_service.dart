// =====================================================
// IMPORTS
// =====================================================

import '../../models/reservation_record.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// RESERVATION HISTORY SERVICE
// =====================================================

class ReservationHistoryService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER RESERVATIONS
  // =====================================================

  Future<List<ReservationRecord>> getCurrentUserReservations() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return [];
    }

    try {
      final dynamic response = await _client.rpc(
        'get_university_user_reservations',
        params: {'p_university_id': currentUser.universityId},
      );

      if (response is! List) {
        return [];
      }

      return response.map((record) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          record as Map,
        );

        return ReservationRecord.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // =====================================================
  // GET UPCOMING RESERVATIONS
  // =====================================================

  Future<List<ReservationRecord>> getUpcomingReservations() async {
    final List<ReservationRecord> reservations =
        await getCurrentUserReservations();

    return reservations.where((reservation) {
      return reservation.status == ReservationRecordStatus.upcoming ||
          reservation.status == ReservationRecordStatus.active;
    }).toList();
  }
}
