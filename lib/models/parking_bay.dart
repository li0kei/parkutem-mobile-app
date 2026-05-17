// =====================================================
// PARKING BAY STATUS
// =====================================================

enum ParkingBayStatus {
  available,
  occupied,
  reserved,
  maintenance,
}

// =====================================================
// PARKING BAY STATUS EXTENSION
// =====================================================

extension ParkingBayStatusExtension on ParkingBayStatus {
  String get label {
    switch (this) {
      case ParkingBayStatus.available:
        return 'Available';
      case ParkingBayStatus.occupied:
        return 'Occupied';
      case ParkingBayStatus.reserved:
        return 'Reserved';
      case ParkingBayStatus.maintenance:
        return 'Maintenance';
    }
  }

  static ParkingBayStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'occupied':
        return ParkingBayStatus.occupied;
      case 'reserved':
        return ParkingBayStatus.reserved;
      case 'maintenance':
        return ParkingBayStatus.maintenance;
      case 'available':
      default:
        return ParkingBayStatus.available;
    }
  }
}

// =====================================================
// PARKING BAY MODEL
// =====================================================

class ParkingBay {
  final String id;
  final String zone;
  final String bayNumber;
  final ParkingBayStatus status;
  final String allowedFor;
  final bool isPremium;

  final String sensorStatus;
  final String? currentPlateNumber;
  final String? currentUserType;
  final DateTime? lastUpdatedAt;

  final String? zoneCode;
  final String? zoneName;
  final String? locationName;

  const ParkingBay({
    required this.id,
    required this.zone,
    required this.bayNumber,
    required this.status,
    required this.allowedFor,
    this.isPremium = false,
    this.sensorStatus = 'placeholder',
    this.currentPlateNumber,
    this.currentUserType,
    this.lastUpdatedAt,
    this.zoneCode,
    this.zoneName,
    this.locationName,
  });

  // =====================================================
  // FROM SUPABASE JSON
  // =====================================================

  factory ParkingBay.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? zoneData = json['parking_zones'] is Map
        ? Map<String, dynamic>.from(json['parking_zones'] as Map)
        : null;

    final String zoneCode =
        zoneData?['zone_code']?.toString() ?? json['zone_code']?.toString() ?? '-';

    final String zoneName =
        zoneData?['zone_name']?.toString() ?? json['zone_name']?.toString() ?? 'Zone $zoneCode';

    final String locationName =
        zoneData?['location_name']?.toString() ??
            json['location_name']?.toString() ??
            '-';

    return ParkingBay(
      id: json['id']?.toString() ?? '',
      zone: locationName == '-'
          ? zoneName
          : '$zoneName • $locationName',
      bayNumber: json['bay_code']?.toString() ?? '-',
      status: ParkingBayStatusExtension.fromString(
        json['status']?.toString(),
      ),
      allowedFor: json['current_user_type']?.toString() ?? 'All Users',
      isPremium: false,
      sensorStatus: json['sensor_status']?.toString() ?? 'placeholder',
      currentPlateNumber: json['current_plate_number']?.toString(),
      currentUserType: json['current_user_type']?.toString(),
      lastUpdatedAt: _toDateTime(json['last_updated_at']),
      zoneCode: zoneCode,
      zoneName: zoneName,
      locationName: locationName,
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}