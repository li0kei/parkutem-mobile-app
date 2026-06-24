// =====================================================
// IMPORTS
// =====================================================

import '../../models/wallet_transaction.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// WALLET TRANSACTION SERVICE
// =====================================================

class WalletTransactionService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER WALLET TRANSACTIONS
  // =====================================================

  Future<List<WalletTransaction>> getCurrentUserTransactions() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return [];
    }

    try {
      final dynamic response = await _client.rpc(
        'get_university_user_wallet_transactions',
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

        return WalletTransaction.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
