// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/support_issue_result.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// SUPPORT ISSUE SERVICE
// =====================================================

class SupportIssueService {
  final SupabaseClient _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // CREATE CURRENT USER SUPPORT ISSUE
  // =====================================================

  Future<SupportIssueResult> createCurrentUserSupportIssue({
    required String title,
    required String issueType,
    required String priority,
    required String description,
    String? relatedPlate,
    String? relatedBay,
    String? relatedBookingReference,
  }) async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      throw const AuthException('No active user session found.');
    }

    final String cleanTitle = title.trim();
    final String cleanIssueType = issueType.trim();
    final String cleanPriority = priority.trim();
    final String cleanDescription = description.trim();

    if (cleanTitle.isEmpty) {
      throw const AuthException('Issue title is required.');
    }

    if (cleanIssueType.isEmpty) {
      throw const AuthException('Issue type is required.');
    }

    if (cleanPriority.isEmpty) {
      throw const AuthException('Priority is required.');
    }

    if (cleanDescription.isEmpty) {
      throw const AuthException('Description is required.');
    }

    try {
      final dynamic response = await _client.rpc(
        'create_university_user_support_issue',
        params: {
          'p_university_id': currentUser.universityId,
          'p_title': cleanTitle,
          'p_issue_type': cleanIssueType,
          'p_priority': cleanPriority,
          'p_description': cleanDescription,
          'p_related_plate': _cleanNullable(relatedPlate),
          'p_related_bay': _cleanNullable(relatedBay),
          'p_related_booking_reference': _cleanNullable(
            relatedBookingReference,
          ),
        },
      );

      final Map<String, dynamic> data = _parseSupportIssueResponse(response);

      return SupportIssueResult.fromJson(data);
    } catch (error) {
      throw AuthException(_cleanErrorMessage(error));
    }
  }

  // =====================================================
  // CLEAN NULLABLE
  // =====================================================

  String? _cleanNullable(String? value) {
    if (value == null) {
      return null;
    }

    final String cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }

  // =====================================================
  // PARSE SUPPORT ISSUE RESPONSE
  // =====================================================

  Map<String, dynamic> _parseSupportIssueResponse(dynamic response) {
    if (response == null) {
      throw const AuthException('Support issue was not created.');
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

    throw const AuthException('Support issue failed. Invalid result format.');
  }

  // =====================================================
  // CLEAN ERROR MESSAGE
  // =====================================================

  String _cleanErrorMessage(Object error) {
    final String rawMessage = error.toString();

    if (rawMessage.contains('No active user session')) {
      return 'No active user session found.';
    }

    if (rawMessage.contains('Issue title is required')) {
      return 'Issue title is required.';
    }

    if (rawMessage.contains('Issue type is required')) {
      return 'Issue type is required.';
    }

    if (rawMessage.contains('Priority is required')) {
      return 'Priority is required.';
    }

    if (rawMessage.contains('Description is required')) {
      return 'Description is required.';
    }

    if (rawMessage.contains('University user not found')) {
      return 'University user not found.';
    }

    if (rawMessage.contains('Account is not active')) {
      return 'This account is not active. Please contact admin.';
    }

    if (rawMessage.contains('Could not find the function')) {
      return 'Support issue function is not ready in Supabase.';
    }

    return rawMessage
        .replaceAll('AuthException(message: ', '')
        .replaceAll('PostgrestException(message: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll(')', '')
        .trim();
  }
}
