// =====================================================
// IMPORTS
// =====================================================

import '../../models/vehicle_record.dart';
import 'supabase_service.dart';

// =====================================================
// VEHICLE SERVICE
// =====================================================

class VehicleService {
  final _client = SupabaseService.client;

  // =====================================================
  // GET CURRENT USER VEHICLES
  // =====================================================

  Future<List<VehicleRecord>> getCurrentUserVehicles() async {
    final List<dynamic> records = await _client.rpc(
      'get_current_user_vehicle_records',
    );

    return records.map((record) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        record as Map,
      );

      return VehicleRecord.fromJson(data);
    }).toList();
  }

  // =====================================================
  // GET PRIMARY VEHICLE
  // =====================================================

  Future<VehicleRecord?> getPrimaryVehicle() async {
    final List<VehicleRecord> vehicles = await getCurrentUserVehicles();

    if (vehicles.isEmpty) {
      return null;
    }

    return vehicles.first;
  }

  // =====================================================
  // REGISTER CURRENT USER VEHICLE
  // =====================================================

  Future<VehicleRecord> registerCurrentUserVehicle({
    required String plateNumber,
    required String vehicleModel,
    required String vehicleColor,
  }) async {
    final String cleanPlateNumber = plateNumber.trim();
    final String cleanVehicleModel = vehicleModel.trim();
    final String cleanVehicleColor = vehicleColor.trim();

    if (cleanPlateNumber.isEmpty) {
      throw Exception('Plate number is required.');
    }

    final List<dynamic> records = await _client.rpc(
      'register_current_user_vehicle',
      params: {
        'p_plate_number': cleanPlateNumber,
        'p_vehicle_model': cleanVehicleModel.isEmpty ? '-' : cleanVehicleModel,
        'p_vehicle_color': cleanVehicleColor.isEmpty ? '-' : cleanVehicleColor,
      },
    );

    if (records.isEmpty) {
      throw Exception('Vehicle registration failed. No record returned.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      records.first as Map,
    );

    return VehicleRecord.fromJson(data);
  }
}