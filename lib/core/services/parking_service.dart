// =====================================================
// IMPORTS
// =====================================================

import '../../models/parking_bay.dart';
import 'supabase_service.dart';

// =====================================================
// PARKING SERVICE
// =====================================================

class ParkingService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET PARKING BAYS
  // =====================================================

  Future<List<ParkingBay>> getParkingBays() async {
    final List<dynamic> records = await _client.rpc(
      'get_mobile_parking_bays',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return ParkingBay.fromJson(data);
    }).toList();
  }

  // =====================================================
  // GET PARKING BAYS BY ZONE
  // =====================================================

  Future<List<ParkingBay>> getParkingBaysByZone(String zoneCode) async {
    final List<ParkingBay> bays = await getParkingBays();

    if (zoneCode.toLowerCase() == 'all') {
      return bays;
    }

    return bays.where((bay) {
      return bay.zoneCode?.toLowerCase() == zoneCode.toLowerCase();
    }).toList();
  }
}                                        