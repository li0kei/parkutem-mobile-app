import '../../models/parking_bay.dart';
import '../../models/parking_zone.dart';
import 'supabase_service.dart';

class ParkingService {
  final _client = SupabaseService.client;

  Future<List<ParkingBay>> getParkingBays() async {
    final dynamic response = await _client.rpc('get_mobile_parking_bays');

    if (response is! List) {
      return [];
    }

    return response.map((record) {
      return ParkingBay.fromJson(Map<String, dynamic>.from(record as Map));
    }).toList();
  }

  Future<List<ParkingBay>> getParkingBaysByZone(String zoneCode) async {
    final List<ParkingBay> bays = await getParkingBays();

    if (zoneCode.toLowerCase() == 'all') {
      return bays;
    }

    return bays.where((bay) {
      return bay.zoneCode?.toLowerCase() == zoneCode.toLowerCase();
    }).toList();
  }

  // Map coordinates are managed by Admin in parking_zones. The bay RPC does
  // not return map coordinates, so the mobile app reads the public zone
  // metadata separately. Failure here must never block the live bay list.
  Future<List<ParkingZone>> getParkingZonesForMap() async {
    try {
      final dynamic response = await _client
          .from('parking_zones')
          .select(
            'id, zone_code, zone_name, location_name, map_label, '
            'map_latitude, map_longitude, is_active',
          )
          .eq('is_active', true)
          .order('zone_code', ascending: true);

      if (response is! List) {
        return [];
      }

      return response
          .map((record) {
            return ParkingZone.fromJson(
              Map<String, dynamic>.from(record as Map),
            );
          })
          .where((zone) => zone.hasCoordinates)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
