// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/support_issue_result.dart';
import 'supabase_service.dart';

// =====================================================
// SUPPORT ISSUE SERVICE
// =====================================================

class SupportIssueService {
  final SupabaseClient _client = SupabaseService.client;

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
    final List<dynamic> records = await _client.rpc(
      'create_current_user_support_issue',
      params: {
        'p_title': title,
        'p_issue_type': issueType,
        'p_priority': priority,
        'p_description': description,
        'p_related_plate': relatedPlate,
        'p_related_bay': relatedBay,
        'p_related_booking_reference': relatedBookingReference,
      },
    );

    if (records.isEmpty) {
      throw Exception('Support issue was not created.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      records.first as Map,
    );

    return SupportIssueResult.fromJson(data);
  }
}