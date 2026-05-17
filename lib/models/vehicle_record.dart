// =====================================================
// VEHICLE RECORD MODEL
// =====================================================

class VehicleRecord {
  final String id;
  final String plateNumber;
  final String normalizedPlateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String ownerName;
  final String universityId;
  final String userType;
  final String faculty;
  final String stickerStatus;
  final String anprAccessStatus;
  final DateTime? registeredAt;
  final DateTime? expiryAt;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleRecord({
    required this.id,
    required this.plateNumber,
    required this.normalizedPlateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.ownerName,
    required this.universityId,
    required this.userType,
    required this.faculty,
    required this.stickerStatus,
    required this.anprAccessStatus,
    required this.registeredAt,
    required this.expiryAt,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory VehicleRecord.fromJson(Map<String, dynamic> json) {
    return VehicleRecord(
      id: json['id']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '-',
      normalizedPlateNumber: json['normalized_plate_number']?.toString() ?? '-',
      vehicleModel: json['vehicle_model']?.toString() ?? '-',
      vehicleColor: json['vehicle_color']?.toString() ?? '-',
      ownerName: json['owner_name']?.toString() ?? '-',
      universityId: json['university_id']?.toString() ?? '-',
      userType: json['user_type']?.toString() ?? '-',
      faculty: json['faculty']?.toString() ?? '-',
      stickerStatus: json['sticker_status']?.toString() ?? 'pending',
      anprAccessStatus:
          json['anpr_access_status']?.toString() ?? 'disabled',
      registeredAt: _toDateTime(json['registered_at']),
      expiryAt: _toDateTime(json['expiry_at']),
      remarks: json['remarks']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isStickerActive => stickerStatus == 'active';

  bool get isAnprEnabled => anprAccessStatus == 'enabled';

  String get vehicleDescription {
    if (vehicleModel == '-' && vehicleColor == '-') {
      return 'Vehicle details not available';
    }

    if (vehicleColor == '-') {
      return vehicleModel;
    }

    if (vehicleModel == '-') {
      return vehicleColor;
    }

    return '$vehicleModel • $vehicleColor';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}