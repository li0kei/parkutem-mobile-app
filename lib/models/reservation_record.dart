// =====================================================
// RESERVATION RECORD STATUS
// =====================================================

enum ReservationRecordStatus {
  upcoming,
  active,
  completed,
  cancelled,
}

// =====================================================
// RESERVATION RECORD STATUS EXTENSION
// =====================================================

extension ReservationRecordStatusExtension on ReservationRecordStatus {
  String get label {
    switch (this) {
      case ReservationRecordStatus.upcoming:
        return 'Upcoming';
      case ReservationRecordStatus.active:
        return 'Active';
      case ReservationRecordStatus.completed:
        return 'Completed';
      case ReservationRecordStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ReservationRecordStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return ReservationRecordStatus.active;
      case 'completed':
        return ReservationRecordStatus.completed;
      case 'cancelled':
        return ReservationRecordStatus.cancelled;
      case 'upcoming':
      default:
        return ReservationRecordStatus.upcoming;
    }
  }
}

// =====================================================
// RESERVATION RECORD MODEL
// =====================================================

class ReservationRecord {
  final String id;
  final String reservationReference;
  final String? bayId;
  final String universityId;
  final String userName;
  final String userType;
  final String plateNumber;
  final String normalizedPlateNumber;

  final DateTime reservationStartAt;
  final DateTime reservationEndAt;

  final double reservationFee;
  final double after7ParkingFee;
  final String paymentMethod;
  final ReservationRecordStatus status;
  final String? remarks;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String bayCode;
  final String zoneCode;
  final String zoneName;
  final String locationName;

  const ReservationRecord({
    required this.id,
    required this.reservationReference,
    required this.bayId,
    required this.universityId,
    required this.userName,
    required this.userType,
    required this.plateNumber,
    required this.normalizedPlateNumber,
    required this.reservationStartAt,
    required this.reservationEndAt,
    required this.reservationFee,
    required this.after7ParkingFee,
    required this.paymentMethod,
    required this.status,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.bayCode,
    required this.zoneCode,
    required this.zoneName,
    required this.locationName,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory ReservationRecord.fromJson(Map<String, dynamic> json) {
    return ReservationRecord(
      id: json['id']?.toString() ?? '',
      reservationReference:
          json['reservation_reference']?.toString() ?? '-',
      bayId: json['bay_id']?.toString(),
      universityId: json['university_id']?.toString() ?? '-',
      userName: json['user_name']?.toString() ?? '-',
      userType: json['user_type']?.toString() ?? '-',
      plateNumber: json['plate_number']?.toString() ?? '-',
      normalizedPlateNumber:
          json['normalized_plate_number']?.toString() ?? '-',
      reservationStartAt:
          _toDateTime(json['reservation_start_at']) ?? DateTime.now(),
      reservationEndAt:
          _toDateTime(json['reservation_end_at']) ?? DateTime.now(),
      reservationFee: _toDouble(json['reservation_fee']),
      after7ParkingFee: _toDouble(json['after_7_parking_fee']),
      paymentMethod: json['payment_method']?.toString() ?? 'wallet',
      status: ReservationRecordStatusExtension.fromString(
        json['status']?.toString(),
      ),
      remarks: json['remarks']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      bayCode: json['bay_code']?.toString() ?? '-',
      zoneCode: json['zone_code']?.toString() ?? '-',
      zoneName: json['zone_name']?.toString() ?? '-',
      locationName: json['location_name']?.toString() ?? '-',
    );
  }

  // =====================================================
  // DISPLAY HELPERS
  // =====================================================

  String get bayLabel {
    if (zoneCode == '-' && bayCode == '-') {
      return 'Bay not assigned';
    }

    if (zoneCode == '-') {
      return bayCode;
    }

    return '$bayCode • Zone $zoneCode';
  }

  String get locationLabel {
    if (locationName != '-') {
      return locationName;
    }

    if (zoneName != '-') {
      return zoneName;
    }

    return 'Campus Parking';
  }

  String get durationLabel {
    final Duration duration = reservationEndAt.difference(reservationStartAt);

    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;

    if (hours <= 0) {
      return '$minutes minutes';
    }

    if (minutes == 0) {
      return '$hours hour${hours == 1 ? '' : 's'}';
    }

    return '$hours hour${hours == 1 ? '' : 's'} $minutes minutes';
  }

  double get totalPaid {
    return reservationFee + after7ParkingFee;
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
  
// =====================================================
// DATE TIME HELPER
// =====================================================

static DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final DateTime? parsed = DateTime.tryParse(value.toString());

  if (parsed == null) return null;

  // Supabase timestamptz is usually returned in UTC.
  // ParkUTeM uses Malaysia campus time, so display as UTC+8.
  return parsed.toUtc().add(const Duration(hours: 8));
}
}