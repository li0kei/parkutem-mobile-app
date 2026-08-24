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

      if (!mounted) return;

      setState(() {
        _profile = results[0] as UniversityUser?;
        _vehicle = results[1] as VehicleRecord?;
        _reservations = results[2] as List<ReservationRecord>;
        _bays = results[3] as List<ParkingBay>;
        _unreadCount = results[4] as int;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
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
    if (_reservations.isEmpty) return null;

    final values = List<ReservationRecord>.from(_reservations)
      ..sort((a, b) => a.reservationStartAt.compareTo(b.reservationStartAt));

    return values.first;
  }

  String get _firstName {
    final value = (_profile?.fullName ?? 'UTeM User').trim();
    if (value.isEmpty) return 'UTeM User';
    return value.split(RegExp(r'\s+')).first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _navigateFromBottomBar(int index) {
    final routes = ['/home', '/parking', '/reserve', '/wallet', '/profile'];
    if (index == 0) return;
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    if (_isLoading)
                      const _LoadingPanel()
                    else if (_error != null)
                      _ErrorPanel(onRetry: _load)
                    else ...[
                      _buildParkingNow(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildVehicle(),
                      const SizedBox(height: 16),
                      _buildReservation(),
                      const SizedBox(height: 16),
                      _buildWallet(),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: _load,
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 6),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton.filledTonal(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/notifications');
                if (mounted) {
                  await _load();
                }
              },
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D20),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppTheme.canvas, width: 2),
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
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

  Widget _buildParkingNow() {
    final total = _bays.length;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_parking_rounded, color: AppTheme.primaryBlue),
              SizedBox(width: 9),
              Text(
                'Parking now',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '$_available',
                  label: 'Available',
                  valueColor: const Color(0xFF067647),
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _Metric(
                  value: '$_occupied',
                  label: 'Occupied',
                  valueColor: const Color(0xFFB42318),
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _Metric(
                  value: '$total',
                  label: 'Total bays',
                  valueColor: AppTheme.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/parking'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Open live parking map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.event_available_outlined,
            label: 'Reserve',
            onTap: () => Navigator.of(context).pushNamed('/reserve'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () => Navigator.of(context).pushNamed('/wallet'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => Navigator.of(context).pushNamed('/parking-history'),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicle() {
    final vehicle = _vehicle;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Vehicle',
            action: 'Manage',
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
          const SizedBox(height: 14),
          if (vehicle == null)
            const Text(
              'No vehicle is linked to this account yet.',
              style: TextStyle(color: AppTheme.muted, height: 1.4),
            )
          else
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.directions_car_outlined,
                    color: AppTheme.primaryBlue,
                  ),
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
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.vehicleDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: vehicle.isAnprEnabled ? 'ANPR ready' : 'ANPR off',
                  positive: vehicle.isAnprEnabled,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReservation() {
    final reservation = _nextReservation;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Next reservation',
            action: reservation == null ? 'Reserve' : 'History',
            onTap: () => Navigator.of(
              context,
            ).pushNamed(reservation == null ? '/reserve' : '/parking-history'),
          ),
          const SizedBox(height: 14),
          if (reservation == null)
            const Text(
              'No upcoming reservation.',
              style: TextStyle(color: AppTheme.muted),
            )
          else ...[
            Text(
              '${reservation.bayLabel} • ${reservation.locationLabel}',
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatDateTime(reservation.reservationStartAt),
              style: const TextStyle(color: AppTheme.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWallet() {
    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet balance',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'RM${(_profile?.walletBalance ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/wallet'),
            child: const Text('Open wallet'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year} • $hour:$minute $period';
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _Metric({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppTheme.border);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool positive;

  const _StatusChip({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF067647) : AppTheme.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 90),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorPanel({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppTheme.muted, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Unable to refresh the dashboard.',
            style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
