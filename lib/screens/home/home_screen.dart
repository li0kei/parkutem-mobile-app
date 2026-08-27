import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/parking_service.dart';
import '../../core/services/reservation_history_service.dart';
import '../../core/services/university_user_service.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parking_bay.dart';
import '../../models/reservation_record.dart';
import '../../models/university_user.dart';
import '../../models/vehicle_record.dart';
import '../../widgets/app_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UniversityUserService _userService = UniversityUserService();
  final VehicleService _vehicleService = VehicleService();
  final ReservationHistoryService _reservationService =
      ReservationHistoryService();
  final ParkingService _parkingService = ParkingService();
  final NotificationService _notificationService = NotificationService();

  UniversityUser? _profile;
  VehicleRecord? _vehicle;
  List<ReservationRecord> _reservations = [];
  List<ParkingBay> _bays = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        _userService.getCurrentUserProfile(),
        _vehicleService.getPrimaryVehicle(),
        _reservationService.getUpcomingReservations(),
        _parkingService.getParkingBays(),
        _notificationService.getUnreadCount(),
      ]);

      if (!mounted) {
        return;
      }
      setState(() {
        _profile = results[0] as UniversityUser?;
        _vehicle = results[1] as VehicleRecord?;
        _reservations = results[2] as List<ReservationRecord>;
        _bays = results[3] as List<ParkingBay>;
        _unreadCount = results[4] as int;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  int get _available =>
      _bays.where((bay) => bay.status == ParkingBayStatus.available).length;
  int get _occupied =>
      _bays.where((bay) => bay.status == ParkingBayStatus.occupied).length;

  ReservationRecord? get _nextReservation {
    if (_reservations.isEmpty) {
      return null;
    }
    final values = List<ReservationRecord>.from(_reservations)
      ..sort((a, b) => a.reservationStartAt.compareTo(b.reservationStartAt));
    return values.first;
  }

  String get _firstName {
    final value = (_profile?.fullName ?? 'UTeM User').trim();
    if (value.isEmpty) {
      return 'UTeM User';
    }
    return value.split(RegExp(r'\s+')).first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  void _navigateFromBottomBar(int index) {
    final routes = ['/home', '/parking', '/reserve', '/profile'];
    if (index == 0) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _buildError()
                    else ...[
                      _buildParking(),
                      const SizedBox(height: 30),
                      _buildSectionTitle(
                        'Your vehicle',
                        action: 'Manage',
                        onTap: () =>
                            Navigator.of(context).pushNamed('/profile'),
                      ),
                      const SizedBox(height: 8),
                      _buildVehicle(),
                      const Divider(height: 38),
                      _buildSectionTitle(
                        'Next reservation',
                        action: _nextReservation == null
                            ? 'Reserve'
                            : 'History',
                        onTap: () => Navigator.of(context).pushNamed(
                          _nextReservation == null
                              ? '/reserve'
                              : '/parking-history',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReservation(),
                    ],
                  ],
                ),
              ),
            ),
            AppBottomNavigation(currentIndex: 0, onTap: _navigateFromBottomBar),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/notifications');
                if (mounted) {
                  await _load();
                }
              },
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildParking() {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/parking'),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_parking_rounded,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Live parking',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${_bays.length} bays',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _InlineMetric(
                  value: '$_available',
                  label: 'available',
                  color: const Color(0xFF067647),
                ),
                const SizedBox(width: 28),
                _InlineMetric(
                  value: '$_occupied',
                  label: 'occupied',
                  color: const Color(0xFFB42318),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap to view the campus map and individual bay status.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicle() {
    final vehicle = _vehicle;
    if (vehicle == null) {
      return const Text(
        'No vehicle is linked to this account yet.',
        style: TextStyle(color: AppTheme.muted),
      );
    }
    return Row(
      children: [
        const Icon(
          Icons.directions_car_outlined,
          color: AppTheme.primaryBlue,
          size: 26,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.plateNumber,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vehicle.vehicleDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          vehicle.isAnprEnabled ? 'ANPR ready' : 'ANPR off',
          style: TextStyle(
            color: vehicle.isAnprEnabled
                ? const Color(0xFF067647)
                : AppTheme.muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildReservation() {
    final reservation = _nextReservation;
    if (reservation == null) {
      return const Text(
        'No upcoming reservation.',
        style: TextStyle(color: AppTheme.muted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${reservation.bayLabel} · ${reservation.locationLabel}',
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDateTime(reservation.reservationStartAt),
          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title, {
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        const Icon(Icons.cloud_off_outlined, color: AppTheme.muted, size: 34),
        const SizedBox(height: 10),
        const Text(
          'Unable to load ParkUTeM right now.',
          style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Try again')),
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year} · $hour:$minute $period';
  }
}

class _InlineMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _InlineMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
