// =====================================================
// IMPORTS
// =====================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// WALLET SERVICE
// =====================================================

class WalletService {
  final SupabaseClient _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // PROCESS WALLET TOP UP
  // =====================================================

  Future<WalletTopUpResult> processTopUp({
    required double amount,
    String paymentMethod = 'simulated',
  }) async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      throw const AuthException('No active user session found.');
    }

    if (amount < 5) {
      throw const AuthException('Minimum top up amount is RM5.00.');
    }

    try {
      final dynamic response = await _client.rpc(
        'process_university_user_wallet_topup',
        params: {
          'p_university_id': currentUser.universityId,
          'p_amount': amount,
          'p_payment_method': paymentMethod,
        },
      );

      final Map<String, dynamic> data = _parseTopUpResponse(response);

      return WalletTopUpResult.fromJson(data);
    } catch (error) {
      throw AuthException(_cleanErrorMessage(error));
    }
  }

  // =====================================================
  // PARSE TOP UP RESPONSE
  // =====================================================

  Map<String, dynamic> _parseTopUpResponse(dynamic response) {
    if (response == null) {
      throw const AuthException('Wallet top up failed. No result returned.');
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

    throw const AuthException('Wallet top up failed. Invalid result format.');
  }

  // =====================================================
  // CLEAN ERROR MESSAGE
  // =====================================================

  String _cleanErrorMessage(Object error) {
    final String rawMessage = error.toString();

    if (rawMessage.contains('No active user session')) {
      return 'No active user session found.';
    }

    if (rawMessage.contains('Minimum top up amount')) {
      return 'Minimum top up amount is RM5.00.';
    }

    if (rawMessage.contains('University user not found')) {
      return 'University user not found.';
    }

    if (rawMessage.contains('Account is not active')) {
      return 'This account is not active. Please contact admin.';
    }

    if (rawMessage.contains('Could not find the function')) {
      return 'Wallet top up function is not ready in Supabase.';
    }

    return rawMessage
        .replaceAll('AuthException(message: ', '')
        .replaceAll('PostgrestException(message: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll(')', '')
        .trim();
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
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
