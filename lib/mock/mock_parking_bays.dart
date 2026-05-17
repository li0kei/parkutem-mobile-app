import '../models/parking_bay.dart';

// =====================================================
// MOCK PARKING BAY DATA
// =====================================================

const List<ParkingBay> mockParkingBays = [
  // =====================================================
  // STUDENT PARKING
  // =====================================================

  ParkingBay(
    id: 'SP-A01',
    zone: 'Student Parking',
    bayNumber: 'A01',
    status: ParkingBayStatus.available,
    allowedFor: 'Student',
  ),
  ParkingBay(
    id: 'SP-A02',
    zone: 'Student Parking',
    bayNumber: 'A02',
    status: ParkingBayStatus.occupied,
    allowedFor: 'Student',
  ),
  ParkingBay(
    id: 'SP-A03',
    zone: 'Student Parking',
    bayNumber: 'A03',
    status: ParkingBayStatus.available,
    allowedFor: 'Student',
  ),
  ParkingBay(
    id: 'SP-A04',
    zone: 'Student Parking',
    bayNumber: 'A04',
    status: ParkingBayStatus.reserved,
    allowedFor: 'Student',
  ),

  // =====================================================
  // STAFF PARKING
  // =====================================================

  ParkingBay(
    id: 'ST-B01',
    zone: 'Staff Parking',
    bayNumber: 'B01',
    status: ParkingBayStatus.available,
    allowedFor: 'Staff',
  ),
  ParkingBay(
    id: 'ST-B02',
    zone: 'Staff Parking',
    bayNumber: 'B02',
    status: ParkingBayStatus.occupied,
    allowedFor: 'Staff',
  ),
  ParkingBay(
    id: 'ST-B03',
    zone: 'Staff Parking',
    bayNumber: 'B03',
    status: ParkingBayStatus.reserved,
    allowedFor: 'Staff',
  ),
  ParkingBay(
    id: 'ST-B04',
    zone: 'Staff Parking',
    bayNumber: 'B04',
    status: ParkingBayStatus.available,
    allowedFor: 'Staff',
  ),

  // =====================================================
  // ZONE A
  // =====================================================

  ParkingBay(
    id: 'ZA-01',
    zone: 'Zone A',
    bayNumber: 'A12',
    status: ParkingBayStatus.available,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZA-02',
    zone: 'Zone A',
    bayNumber: 'A13',
    status: ParkingBayStatus.occupied,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZA-03',
    zone: 'Zone A',
    bayNumber: 'A14',
    status: ParkingBayStatus.reserved,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZA-04',
    zone: 'Zone A',
    bayNumber: 'A15',
    status: ParkingBayStatus.available,
    allowedFor: 'Student/Staff',
  ),

  // =====================================================
  // ZONE B
  // =====================================================

  ParkingBay(
    id: 'ZB-01',
    zone: 'Zone B',
    bayNumber: 'B12',
    status: ParkingBayStatus.available,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZB-02',
    zone: 'Zone B',
    bayNumber: 'B13',
    status: ParkingBayStatus.occupied,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZB-03',
    zone: 'Zone B',
    bayNumber: 'B14',
    status: ParkingBayStatus.available,
    allowedFor: 'Student/Staff',
  ),
  ParkingBay(
    id: 'ZB-04',
    zone: 'Zone B',
    bayNumber: 'B15',
    status: ParkingBayStatus.reserved,
    allowedFor: 'Student/Staff',
  ),
];