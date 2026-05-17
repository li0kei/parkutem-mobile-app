// =====================================================
// WALLET TRANSACTION TYPE
// =====================================================

enum WalletTransactionType {
  topUp,
  reservationFee,
  parkingFee,
  refund,
}

// =====================================================
// WALLET TRANSACTION MODEL
// =====================================================

class WalletTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final bool isDebit;
  final DateTime dateTime;
  final WalletTransactionType type;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.isDebit,
    required this.dateTime,
    required this.type,
  });

  // =====================================================
  // FROM SUPABASE JSON
  // =====================================================

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final String paymentType = json['payment_type']?.toString() ?? '';
    final String paymentMethod =
        json['payment_method']?.toString() ?? 'simulated';
    final String paymentStatus =
        json['payment_status']?.toString() ?? 'pending';
    final String reference =
        json['transaction_reference']?.toString() ?? '-';

    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      title: _mapTitle(
        paymentType: paymentType,
        paymentStatus: paymentStatus,
      ),
      description: _mapDescription(
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        reference: reference,
      ),
      amount: _toDouble(json['amount']),
      isDebit: _isDebit(
        paymentType: paymentType,
        paymentStatus: paymentStatus,
      ),
      dateTime: _toDateTime(json['paid_at']) ??
          _toDateTime(json['created_at']) ??
          DateTime.now(),
      type: _mapType(
        paymentType: paymentType,
        paymentStatus: paymentStatus,
      ),
    );
  }

  // =====================================================
  // MAPPERS
  // =====================================================

  static WalletTransactionType _mapType({
    required String paymentType,
    required String paymentStatus,
  }) {
    if (paymentStatus == 'refunded') {
      return WalletTransactionType.refund;
    }

    switch (paymentType) {
      case 'wallet_topup':
        return WalletTransactionType.topUp;
      case 'reservation_fee':
        return WalletTransactionType.reservationFee;
      case 'parking_fee':
        return WalletTransactionType.parkingFee;
      default:
        return WalletTransactionType.parkingFee;
    }
  }

  static bool _isDebit({
    required String paymentType,
    required String paymentStatus,
  }) {
    if (paymentStatus == 'refunded') {
      return false;
    }

    return paymentType == 'reservation_fee' || paymentType == 'parking_fee';
  }

  static String _mapTitle({
    required String paymentType,
    required String paymentStatus,
  }) {
    if (paymentStatus == 'refunded') {
      return 'Refund';
    }

    switch (paymentType) {
      case 'wallet_topup':
        return 'Wallet Top Up';
      case 'reservation_fee':
        return 'Reservation Fee';
      case 'parking_fee':
        return 'Parking Fee';
      default:
        return 'Payment Transaction';
    }
  }

  static String _mapDescription({
    required String paymentMethod,
    required String paymentStatus,
    required String reference,
  }) {
    final String method = paymentMethod.toUpperCase();

    if (paymentStatus == 'paid') {
      return '$method payment successful • $reference';
    }

    if (paymentStatus == 'pending') {
      return '$method payment pending • $reference';
    }

    if (paymentStatus == 'failed') {
      return '$method payment failed • $reference';
    }

    if (paymentStatus == 'refunded') {
      return '$method payment refunded • $reference';
    }

    return '$method payment • $reference';
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}