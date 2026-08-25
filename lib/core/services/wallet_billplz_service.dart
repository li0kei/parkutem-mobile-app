import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mobile_payment_session_service.dart';
import 'supabase_service.dart';

class WalletBillplzService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _pendingReturnTokenKey =
      'parkutem_wallet_billplz_return_token';

  final SupabaseClient _client = SupabaseService.client;
  final MobilePaymentSessionService _sessionService =
      MobilePaymentSessionService();

  Future<WalletBillplzCheckout> createTopUp(double amount) async {
    final token = await _requireSessionToken();

    try {
      final response = await _client.functions.invoke(
        'create-billplz-wallet-topup',
        body: {'sessionToken': token, 'amount': amount},
      );

      final data = _asMap(response.data);
      if (data['success'] != true) {
        throw AuthException(
          data['error']?.toString() ?? 'Unable to prepare Billplz payment.',
        );
      }

      final checkout = WalletBillplzCheckout.fromJson(data);
      if (checkout.paymentUrl.isEmpty || checkout.returnToken.isEmpty) {
        throw const AuthException('Billplz did not return a valid checkout.');
      }

      await _storage.write(
        key: _pendingReturnTokenKey,
        value: checkout.returnToken,
      );

      return checkout;
    } on AuthException {
      rethrow;
    } on FunctionException catch (error) {
      throw AuthException(_functionErrorMessage(error));
    } catch (error) {
      throw AuthException(_cleanError(error));
    }
  }

  Future<WalletBillplzStatus?> resolvePendingTopUp() async {
    final returnToken = await _storage.read(key: _pendingReturnTokenKey);
    if (returnToken == null || returnToken.trim().isEmpty) return null;

    final sessionToken = await _requireSessionToken();

    try {
      final response = await _client.functions.invoke(
        'resolve-billplz-wallet-topup',
        body: {'sessionToken': sessionToken, 'returnToken': returnToken.trim()},
      );

      final data = _asMap(response.data);
      if (data['success'] != true) {
        throw AuthException(
          data['error']?.toString() ?? 'Unable to verify Billplz payment.',
        );
      }

      final result = WalletBillplzStatus.fromJson(data);

      if (result.state == WalletBillplzState.paid ||
          result.state == WalletBillplzState.failed ||
          result.state == WalletBillplzState.expired) {
        await clearPendingTopUp();
      }

      return result;
    } on AuthException {
      rethrow;
    } on FunctionException catch (error) {
      throw AuthException(_functionErrorMessage(error));
    } catch (error) {
      throw AuthException(_cleanError(error));
    }
  }

  Future<void> clearPendingTopUp() {
    return _storage.delete(key: _pendingReturnTokenKey);
  }

  Future<String> _requireSessionToken() async {
    final token = await _sessionService.getSessionToken();
    if (token == null) {
      throw const AuthException(
        'Secure mobile session is missing. Please sign in again.',
      );
    }
    return token;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _functionErrorMessage(FunctionException error) {
    final details = error.details;

    if (details is Map) {
      final message = details['error']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    if (details is String && details.trim().isNotEmpty) {
      return details.trim();
    }

    return 'Unable to complete the Billplz request.';
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceAll('AuthException(message: ', '')
        .replaceAll('Exception: ', '')
        .trim();
  }
}

class WalletBillplzCheckout {
  final String paymentUrl;
  final String returnToken;
  final String transactionReference;
  final double amount;

  const WalletBillplzCheckout({
    required this.paymentUrl,
    required this.returnToken,
    required this.transactionReference,
    required this.amount,
  });

  factory WalletBillplzCheckout.fromJson(Map<String, dynamic> json) {
    return WalletBillplzCheckout(
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      returnToken: json['returnToken']?.toString() ?? '',
      transactionReference: json['transactionReference']?.toString() ?? '',
      amount: _toDouble(json['amount']),
    );
  }
}

enum WalletBillplzState { pending, paid, failed, expired }

class WalletBillplzStatus {
  final WalletBillplzState state;
  final String transactionReference;
  final double amount;

  const WalletBillplzStatus({
    required this.state,
    required this.transactionReference,
    required this.amount,
  });

  factory WalletBillplzStatus.fromJson(Map<String, dynamic> json) {
    final raw = json['state']?.toString().trim().toLowerCase();
    final state = switch (raw) {
      'paid' => WalletBillplzState.paid,
      'failed' => WalletBillplzState.failed,
      'expired' => WalletBillplzState.expired,
      _ => WalletBillplzState.pending,
    };

    return WalletBillplzStatus(
      state: state,
      transactionReference: json['transactionReference']?.toString() ?? '',
      amount: _toDouble(json['amount']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
