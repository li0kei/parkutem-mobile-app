// =====================================================
// IMPORTS
// =====================================================

import '../../models/reservation_record.dart';
import 'supabase_service.dart';

// =====================================================
// RESERVATION HISTORY SERVICE
// =====================================================

class ReservationHistoryService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER RESERVATIONS
  // =====================================================

  Future<List<ReservationRecord>> getCurrentUserReservations() async {
    final List<dynamic> records = await _client.rpc(
      'get_current_user_reservations',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return ReservationRecord.fromJson(data);
    }).toList();
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