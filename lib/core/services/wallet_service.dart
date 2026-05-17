// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

// =====================================================
// WALLET SERVICE
// =====================================================

class WalletService {
  final SupabaseClient _client = SupabaseService.client;

  // =====================================================
  // PROCESS WALLET TOP UP
  // =====================================================

  Future<WalletTopUpResult> processTopUp({
    required double amount,
    String paymentMethod = 'simulated',
  }) async {
    if (amount < 5) {
      throw const AuthException('Minimum top up amount is RM5.00.');
    }

    final List<dynamic> records = await _client.rpc(
      'process_wallet_topup',
      params: {
        'p_amount': amount,
        'p_payment_method': paymentMethod,
      },
    );

    if (records.isEmpty) {
      throw const AuthException('Wallet top up failed. No result returned.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      records.first as Map,
    );

    return WalletTopUpResult.fromJson(data);
  }
}

// =====================================================
// WALLET TOP UP RESULT
// =====================================================

class WalletTopUpResult {
  final String userId;
  final double newWalletBalance;
  final String transactionId;
  final String transactionReference;

  const WalletTopUpResult({
    required this.userId,
    required this.newWalletBalance,
    required this.transactionId,
    required this.transactionReference,
  });

  factory WalletTopUpResult.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResult(
      userId: json['user_id']?.toString() ?? '',
      newWalletBalance: _toDouble(json['new_wallet_balance']),
      transactionId: json['transaction_id']?.toString() ?? '',
      transactionReference: json['transaction_reference']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}