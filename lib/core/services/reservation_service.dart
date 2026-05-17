// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/reservation_result.dart';
import 'supabase_service.dart';

// =====================================================
// RESERVATION SERVICE
// =====================================================

class ReservationService {
  final SupabaseClient _client = SupabaseService.client;

  // =====================================================
  // CREATE CURRENT USER RESERVATION
  // =====================================================

  Future<ReservationResult> createCurrentUserReservation({
    required String bayId,
    required DateTime reservationStartAt,
    required DateTime reservationEndAt,
  }) async {
    if (bayId.trim().isEmpty) {
      throw Exception('Parking bay is required.');
    }

    if (!reservationEndAt.isAfter(reservationStartAt)) {
      throw Exception('Reservation end time must be after start time.');
    }

    final List<dynamic> records = await _client.rpc(
      'create_current_user_reservation',
      params: {
        'p_bay_id': bayId,

        // IMPORTANT:
        // ParkUTeM is Malaysia-based, so reservation time should be treated
        // as Malaysia campus time, not emulator/device UTC time.
        'p_reservation_start_at': _toMalaysiaTimestamp(reservationStartAt),
        'p_reservation_end_at': _toMalaysiaTimestamp(reservationEndAt),
      },
    );

    if (records.isEmpty) {
      throw Exception('Reservation failed. No result returned.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      records.first as Map,
    );

    return ReservationResult.fromJson(data);
  }

  // =====================================================
  // MALAYSIA TIMESTAMP FORMATTER
  // =====================================================

  String _toMalaysiaTimestamp(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    final String second = value.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:$second+08:00';
  }
}