// =====================================================
// RESERVATION RESULT MODEL
// =====================================================

class ReservationResult {
  final String reservationId;
  final String reservationReference;
  final double reservationFee;
  final double after7ParkingFee;
  final double totalPaid;
  final double newWalletBalance;
  final String bayStatus;

  const ReservationResult({
    required this.reservationId,
    required this.reservationReference,
    required this.reservationFee,
    required this.after7ParkingFee,
    required this.totalPaid,
    required this.newWalletBalance,
    required this.bayStatus,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory ReservationResult.fromJson(Map<String, dynamic> json) {
    return ReservationResult(
      reservationId: json['reservation_id']?.toString() ?? '',
      reservationReference: json['reservation_reference']?.toString() ?? '',
      reservationFee: _toDouble(json['reservation_fee']),
      after7ParkingFee: _toDouble(json['after_7_parking_fee']),
      totalPaid: _toDouble(json['total_paid']),
      newWalletBalance: _toDouble(json['new_wallet_balance']),
      bayStatus: json['bay_status']?.toString() ?? 'reserved',
    );
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
}