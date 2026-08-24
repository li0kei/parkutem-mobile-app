class ParkingZone {
  final String id;
  final String zoneCode;
  final String zoneName;
  final String locationName;
  final String mapLabel;
  final double? latitude;
  final double? longitude;

  const ParkingZone({
    required this.id,
    required this.zoneCode,
    required this.zoneName,
    required this.locationName,
    required this.mapLabel,
    required this.latitude,
    required this.longitude,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    return ParkingZone(
      id: json['id']?.toString() ?? '',
      zoneCode: json['zone_code']?.toString() ?? '-',
      zoneName: json['zone_name']?.toString() ?? 'Parking Zone',
      locationName: json['location_name']?.toString() ?? '-',
      mapLabel: json['map_label']?.toString() ?? '',
      latitude: _toDouble(json['map_latitude']),
      longitude: _toDouble(json['map_longitude']),
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  String get displayName {
    if (mapLabel.trim().isNotEmpty) return mapLabel.trim();
    if (locationName != '-' && locationName.trim().isNotEmpty) {
      return locationName;
    }
    return zoneName;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
