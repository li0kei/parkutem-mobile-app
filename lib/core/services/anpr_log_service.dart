// =====================================================
// IMPORTS
// =====================================================

import '../../models/anpr_log_record.dart';
import 'supabase_service.dart';

// =====================================================
// ANPR LOG SERVICE
// =====================================================

class AnprLogService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER ANPR LOGS
  // =====================================================

  Future<List<AnprLogRecord>> getCurrentUserAnprLogs() async {
    final List<dynamic> records = await _client.rpc(
      'get_current_user_anpr_logs',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return AnprLogRecord.fromJson(data);
    }).toList();
  }
}