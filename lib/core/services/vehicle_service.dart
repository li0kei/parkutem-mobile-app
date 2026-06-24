// =====================================================
// IMPORTS
// =====================================================

import '../../models/vehicle_record.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// =====================================================
// VEHICLE SERVICE
// =====================================================

class VehicleService {
  final _client = SupabaseService.client;
  final AuthService _authService = AuthService();

  // =====================================================
  // GET CURRENT USER VEHICLES
  // =====================================================

  Future<List<VehicleRecord>> getCurrentUserVehicles() async {
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      return [];
    }

    final List<dynamic> records = await _client.rpc(
      'get_university_user_vehicle_records',
      params: {'p_university_id': currentUser.universityId},
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
    final currentUser = await _authService.getCurrentUniversityUser();

    if (currentUser == null || currentUser.universityId.trim().isEmpty) {
      throw Exception('No active user session found.');
    }

    final String cleanPlateNumber = plateNumber.trim();
    final String cleanVehicleModel = vehicleModel.trim();
    final String cleanVehicleColor = vehicleColor.trim();

    if (cleanPlateNumber.isEmpty) {
      throw Exception('Plate number is required.');
    }

    final dynamic record = await _client.rpc(
      'register_university_user_vehicle',
      params: {
        'p_university_id': currentUser.universityId,
        'p_plate_number': cleanPlateNumber,
        'p_vehicle_model': cleanVehicleModel.isEmpty ? '-' : cleanVehicleModel,
        'p_vehicle_color': cleanVehicleColor.isEmpty ? '-' : cleanVehicleColor,
      },
    );

    if (record == null) {
      throw Exception('Vehicle registration failed. No record returned.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(record as Map);

    return VehicleRecord.fromJson(data);
  }
}
