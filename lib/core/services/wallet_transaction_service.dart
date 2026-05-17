// =====================================================
// IMPORTS
// =====================================================

import '../../models/wallet_transaction.dart';
import 'supabase_service.dart';

// =====================================================
// WALLET TRANSACTION SERVICE
// =====================================================

class WalletTransactionService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER WALLET TRANSACTIONS
  // =====================================================

  Future<List<WalletTransaction>> getCurrentUserTransactions() async {
    final List<dynamic> records = await _client.rpc(
      'get_current_user_wallet_transactions',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return WalletTransaction.fromJson(data);
    }).toList();
  }
}