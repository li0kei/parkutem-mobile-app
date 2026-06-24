// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/reservation_result.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// RESERVATION SERVICE
// =====================================================

class ReservationService {
  final SupabaseClient _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // CREATE CURRENT USER RESERVATION
  // =====================================================

  Future<ReservationResult> createCurrentUserReservation({
    required String bayId,
    required DateTime reservationStartAt,
    required DateTime reservationEndAt,
  }) async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      throw const AuthException('No active user session found.');
    }

    if (bayId.trim().isEmpty) {
      throw const AuthException('Parking bay is required.');
    }

    if (!reservationEndAt.isAfter(reservationStartAt)) {
      throw const AuthException(
        'Reservation end time must be after start time.',
      );
    }

    try {
      final dynamic response = await _client.rpc(
        'create_university_user_reservation',
        params: {
          'p_university_id': currentUser.universityId,
          'p_bay_id': bayId.trim(),
          'p_reservation_start_at': _toMalaysiaTimestamp(reservationStartAt),
          'p_reservation_end_at': _toMalaysiaTimestamp(reservationEndAt),
        },
      );

      final Map<String, dynamic> data = _parseReservationResponse(response);

      return ReservationResult.fromJson(data);
    } catch (error) {
      throw AuthException(_cleanErrorMessage(error));
    }
  }

  // =====================================================
  // PARSE RESERVATION RESPONSE
  // =====================================================

  Map<String, dynamic> _parseReservationResponse(dynamic response) {
    if (response == null) {
      throw const AuthException('Reservation failed. No result returned.');
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

    throw const AuthException('Reservation failed. Invalid result format.');
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

  // =====================================================
  // CLEAN ERROR MESSAGE
  // =====================================================

  String _cleanErrorMessage(Object error) {
    final String rawMessage = error.toString();

    if (rawMessage.contains('No active user session')) {
      return 'No active user session found.';
    }

    if (rawMessage.contains('Parking bay is required')) {
      return 'Parking bay is required.';
    }

    if (rawMessage.contains('Reservation end time must be after start time')) {
      return 'Reservation end time must be after start time.';
    }

    if (rawMessage.contains('University user not found')) {
      return 'University user not found.';
    }

    if (rawMessage.contains('Account is not active')) {
      return 'This account is not active. Please contact admin.';
    }

    if (rawMessage.contains('Parking bay not found')) {
      return 'Parking bay not found.';
    }

    if (rawMessage.contains('Parking bay is not available')) {
      return 'This parking bay is not available.';
    }

    if (rawMessage.contains('Insufficient wallet balance')) {
      return 'Insufficient wallet balance.';
    }

    if (rawMessage.contains('Could not find the function')) {
      return 'Reservation function is not ready in Supabase.';
    }

    return rawMessage
        .replaceAll('AuthException(message: ', '')
        .replaceAll('PostgrestException(message: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll(')', '')
        .trim();
  }
}
