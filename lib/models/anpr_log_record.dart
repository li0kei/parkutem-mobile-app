// =====================================================
// ANPR LOG TYPE
// =====================================================

enum AnprDetectionType {
  entry,
  exit,
}

// =====================================================
// ANPR ACCESS DECISION
// =====================================================

enum AnprAccessDecision {
  allowed,
  denied,
}

// =====================================================
// ANPR ACCESS STATUS
// =====================================================

enum AnprAccessStatus {
  approved,
  flagged,
  unknown,
}

// =====================================================
// ANPR LOG RECORD MODEL
// =====================================================

class AnprLogRecord {
  final String id;
  final String detectedPlateNumber;
  final String normalizedPlateNumber;
  final double confidenceScore;
  final String userType;

  final AnprDetectionType detectionType;
  final AnprAccessStatus accessStatus;
  final AnprAccessDecision accessDecision;

  final String reason;
  final String? imageUrl;
  final String? sourceDevice;
  final String processingMode;

  final DateTime detectedAt;
  final DateTime? createdAt;

  final String plateNumber;
  final String ownerName;
  final String gateLocation;
  final String parkingZone;
  final double confidence;
  final String paymentStatus;
  final String? remarks;

  final DateTime? entryTime;
  final DateTime? exitTime;

  final String bayCode;
  final String zoneCode;
  final String zoneName;
  final String locationName;

  const AnprLogRecord({
    required this.id,
    required this.detectedPlateNumber,
    required this.normalizedPlateNumber,
    required this.confidenceScore,
    required this.userType,
    required this.detectionType,
    required this.accessStatus,
    required this.accessDecision,
    required this.reason,
    required this.imageUrl,
    required this.sourceDevice,
    required this.processingMode,
    required this.detectedAt,
    required this.createdAt,
    required this.plateNumber,
    required this.ownerName,
    required this.gateLocation,
    required this.parkingZone,
    required this.confidence,
    required this.paymentStatus,
    required this.remarks,
    required this.entryTime,
    required this.exitTime,
    required this.bayCode,
    required this.zoneCode,
    required this.zoneName,
    required this.locationName,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory AnprLogRecord.fromJson(Map<String, dynamic> json) {
    return AnprLogRecord(
      id: json['id']?.toString() ?? '',
      detectedPlateNumber: json['detected_plate_number']?.toString() ?? '-',
      normalizedPlateNumber: json['normalized_plate_number']?.toString() ?? '-',
      confidenceScore: _toDouble(json['confidence_score']),
      userType: json['user_type']?.toString() ?? 'unknown',
      detectionType: _mapDetectionType(json['detection_type']?.toString()),
      accessStatus: _mapAccessStatus(json['access_status']?.toString()),
      accessDecision: _mapAccessDecision(json['access_decision']?.toString()),
      reason: json['reason']?.toString() ?? '-',
      imageUrl: json['image_url']?.toString(),
      sourceDevice: json['source_device']?.toString(),
      processingMode: json['processing_mode']?.toString() ?? 'cloud_anpr',
      detectedAt: _toDateTime(json['detected_at']) ?? DateTime.now(),
      createdAt: _toDateTime(json['created_at']),
      plateNumber: json['plate_number']?.toString() ??
          json['detected_plate_number']?.toString() ??
          '-',
      ownerName: json['owner_name']?.toString() ?? '-',
      gateLocation: json['gate_location']?.toString() ?? 'Main Gate',
      parkingZone: json['parking_zone']?.toString() ?? '-',
      confidence: _toDouble(json['confidence']),
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      remarks: json['remarks']?.toString(),
      entryTime: _toDateTime(json['entry_time']),
      exitTime: _toDateTime(json['exit_time']),
      bayCode: json['bay_code']?.toString() ?? '-',
      zoneCode: json['zone_code']?.toString() ?? '-',
      zoneName: json['zone_name']?.toString() ?? '-',
      locationName: json['location_name']?.toString() ?? '-',
    );
  }

  // =====================================================
  // DISPLAY HELPERS
  // =====================================================

  String get detectionLabel {
    switch (detectionType) {
      case AnprDetectionType.entry:
        return 'Entry';
      case AnprDetectionType.exit:
        return 'Exit';
    }
  }

  String get accessDecisionLabel {
    switch (accessDecision) {
      case AnprAccessDecision.allowed:
        return 'Allowed';
      case AnprAccessDecision.denied:
        return 'Denied';
    }
  }

  String get accessStatusLabel {
    switch (accessStatus) {
      case AnprAccessStatus.approved:
        return 'Approved';
      case AnprAccessStatus.flagged:
        return 'Flagged';
      case AnprAccessStatus.unknown:
        return 'Unknown';
    }
  }

  String get bayLabel {
    if (bayCode != '-' && zoneCode != '-') {
      return '$bayCode • Zone $zoneCode';
    }

    if (bayCode != '-') {
      return bayCode;
    }

    if (parkingZone != '-') {
      return parkingZone;
    }

    return gateLocation;
  }

  String get locationLabel {
    if (locationName != '-') return locationName;
    if (zoneName != '-') return zoneName;
    return gateLocation;
  }

  bool get isAllowed => accessDecision == AnprAccessDecision.allowed;

  bool get isEntry => detectionType == AnprDetectionType.entry;

  bool get isExit => detectionType == AnprDetectionType.exit;

  // =====================================================
  // MAPPERS
  // =====================================================

  static AnprDetectionType _mapDetectionType(String? value) {
    switch (value?.toLowerCase()) {
      case 'exit':
        return AnprDetectionType.exit;
      case 'entry':
      default:
        return AnprDetectionType.entry;
    }
  }

  static AnprAccessDecision _mapAccessDecision(String? value) {
    switch (value?.toLowerCase()) {
      case 'denied':
        return AnprAccessDecision.denied;
      case 'allowed':
      default:
        return AnprAccessDecision.allowed;
    }
  }

  static AnprAccessStatus _mapAccessStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'flagged':
        return AnprAccessStatus.flagged;
      case 'unknown':
        return AnprAccessStatus.unknown;
      case 'approved':
      default:
        return AnprAccessStatus.approved;
    }
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

    final DateTime? parsed = DateTime.tryParse(value.toString());

    if (parsed == null) return null;

    // ParkUTeM display time = Malaysia campus time.
    return parsed.toUtc().add(const Duration(hours: 8));
  }
}