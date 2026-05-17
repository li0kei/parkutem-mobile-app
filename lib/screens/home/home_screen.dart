// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/parking_service.dart';
import '../../core/services/reservation_history_service.dart';
import '../../core/services/university_user_service.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parking_bay.dart';
import '../../models/reservation_record.dart';
import '../../models/university_user.dart';
import '../../models/vehicle_record.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/home_action_card.dart';

// =====================================================
// HOME SCREEN
// =====================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// =====================================================
// HOME SCREEN STATE
// =====================================================

class _HomeScreenState extends State<HomeScreen> {
  final UniversityUserService _universityUserService = UniversityUserService();
  final VehicleService _vehicleService = VehicleService();
  final ReservationHistoryService _reservationHistoryService =
      ReservationHistoryService();
  final ParkingService _parkingService = ParkingService();

  UniversityUser? _profile;
  VehicleRecord? _vehicle;
  List<ReservationRecord> _upcomingReservations = [];
  List<ParkingBay> _parkingBays = [];

  bool _isLoading = true;
  String? _errorMessage;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadHomeDashboard();
  }

  // =====================================================
  // LOAD HOME DASHBOARD
  // =====================================================

  Future<void> _loadHomeDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UniversityUser? profile =
          await _universityUserService.getCurrentUserProfile();

      final VehicleRecord? vehicle = await _vehicleService.getPrimaryVehicle();

      final List<ReservationRecord> reservations =
          await _reservationHistoryService.getUpcomingReservations();

      final List<ParkingBay> bays = await _parkingService.getParkingBays();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _vehicle = vehicle;
        _upcomingReservations = reservations;
        _parkingBays = bays;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // PARKING COUNTS
  // =====================================================

  int get _totalBays => _parkingBays.length;

  int get _availableBays {
    return _parkingBays
        .where((bay) => bay.status == ParkingBayStatus.available)
        .length;
  }

  int get _occupiedBays {
    return _parkingBays
        .where((bay) => bay.status == ParkingBayStatus.occupied)
        .length;
  }

  int get _reservedBays {
    return _parkingBays
        .where((bay) => bay.status == ParkingBayStatus.reserved)
        .length;
  }

  ReservationRecord? get _nearestReservation {
    if (_upcomingReservations.isEmpty) return null;

    final List<ReservationRecord> sorted = List.from(_upcomingReservations)
      ..sort(
        (a, b) => a.reservationStartAt.compareTo(b.reservationStartAt),
      );

    return sorted.first;
  }

  String get _greeting {
    final int hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning,';
    if (hour < 18) return 'Good Afternoon,';

    return 'Good Evening,';
  }

  String get _userName => _profile?.fullName ?? 'UTeM User';

  String get _userType {
    final String role = _profile?.role ?? 'student';

    if (role.toLowerCase() == 'staff') {
      return 'UTeM Staff';
    }

    return 'UTeM Student';
  }

  double get _walletBalance => _profile?.walletBalance ?? 0;

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHomeDashboard,
                color: AppTheme.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 22),
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else ...[
                        _buildVehicleCard(context),
                        const SizedBox(height: 18),
                        _buildMainActionCard(context),
                        const SizedBox(height: 26),
                        _buildParkingOverviewHeader(context),
                        const SizedBox(height: 14),
                        _buildParkingOverviewCards(),
                        const SizedBox(height: 24),
                        _buildActiveReservationCard(context),
                        const SizedBox(height: 24),
                        _buildWalletPreviewCard(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildRecentActivity(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _userType,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _loadHomeDashboard,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 27,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 58),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load dashboard',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadHomeDashboard,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // VEHICLE CARD
  // =====================================================

  Widget _buildVehicleCard(BuildContext context) {
    if (_vehicle == null) {
      return _buildNoVehicleCard(context);
    }

    final bool isActive = _vehicle!.stickerStatus == 'active';
    final bool isAnprEnabled = _vehicle!.isAnprEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 95,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryBlue : const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Sticker & Vehicle',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _vehicle!.plateNumber,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _vehicle!.vehicleDescription,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMiniBadge(
                      label: _formatStatusLabel(_vehicle!.stickerStatus),
                      color: isActive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF59E0B),
                    ),
                    _buildMiniBadge(
                      label: isAnprEnabled ? 'ANPR Enabled' : 'ANPR Disabled',
                      color: isAnprEnabled
                          ? AppTheme.primaryCyan
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppTheme.primaryBlue,
              size: 39,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppTheme.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No vehicle registered',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Register your vehicle to enable sticker and ANPR access.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            child: const Text(
              'Open',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =====================================================
  // MAIN ACTION CARD
  // =====================================================

  Widget _buildMainActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          HomeActionCard(
            icon: Icons.local_parking_rounded,
            title: 'Find Parking',
            subtitle: 'View available bays',
            onTap: () => Navigator.of(context).pushNamed('/parking'),
          ),
          HomeActionCard(
            icon: Icons.event_available_rounded,
            title: 'Reserve Bay',
            subtitle: 'Book your parking',
            onTap: () => Navigator.of(context).pushNamed('/reserve'),
          ),
          HomeActionCard(
            icon: Icons.verified_user_rounded,
            title: 'My Sticker',
            subtitle: 'Vehicle & ANPR status',
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PARKING OVERVIEW
  // =====================================================

  Widget _buildParkingOverviewHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Parking Overview',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/parking'),
          child: const Text(
            'View All',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            DashboardStatCard(
              icon: Icons.local_parking_rounded,
              title: 'Total Bays',
              value: _totalBays.toString(),
              subtitle: 'Campus bays',
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 14),
            DashboardStatCard(
              icon: Icons.directions_car_rounded,
              title: 'Available',
              value: _availableBays.toString(),
              subtitle: 'Live update',
              color: const Color(0xFF22C55E),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            DashboardStatCard(
              icon: Icons.car_crash_rounded,
              title: 'Occupied',
              value: _occupiedBays.toString(),
              subtitle: 'Currently used',
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(width: 14),
            DashboardStatCard(
              icon: Icons.event_busy_rounded,
              title: 'Reserved',
              value: _reservedBays.toString(),
              subtitle: 'Booked bays',
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }

  // =====================================================
  // ACTIVE RESERVATION CARD
  // =====================================================

  Widget _buildActiveReservationCard(BuildContext context) {
    final ReservationRecord? reservation = _nearestReservation;

    if (reservation == null) {
      return _SectionCard(
        title: 'Upcoming Reservation',
        actionText: 'Reserve',
        onActionTap: () => Navigator.of(context).pushNamed('/reserve'),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No upcoming reservation',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Reserve a parking bay before arriving.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      title: 'Upcoming Reservation',
      actionText: 'Details',
      onActionTap: () => Navigator.of(context).pushNamed('/parking-history'),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppTheme.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reservation.bayLabel} • ${reservation.locationLabel}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTimeRange(
                    reservation.reservationStartAt,
                    reservation.reservationEndAt,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildMiniBadge(
            label: reservation.status.label,
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WALLET PREVIEW
  // =====================================================

  Widget _buildWalletPreviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryCyan,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM${_walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Used for reservation and after-7PM parking fee',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/wallet'),
            child: const Text(
              'Top Up',
              style: TextStyle(
                color: AppTheme.primaryCyan,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // QUICK ACTIONS
  // =====================================================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
           _SmallQuickAction(
              icon: Icons.event_available_rounded,
              title: 'New Booking',
              onTap: () => Navigator.of(context).pushNamed('/reserve'),
            ),
            const SizedBox(width: 12),
            _SmallQuickAction(
              icon: Icons.badge_rounded,
              title: 'Sticker',
              onTap: () => Navigator.of(context).pushNamed('/profile'),
            ),
            const SizedBox(width: 12),
            _SmallQuickAction(
              icon: Icons.history_rounded,
              title: 'History',
              onTap: () => Navigator.of(context).pushNamed('/parking-history'),
            ),
            const SizedBox(width: 12),
            _SmallQuickAction(
              icon: Icons.person_rounded,
              title: 'Profile',
              onTap: () => Navigator.of(context).pushNamed('/profile'),
            ),
          ],
        ),
      ],
    );
  }

  // =====================================================
  // RECENT ACTIVITY
  // =====================================================

  Widget _buildRecentActivity(BuildContext context) {
    final ReservationRecord? reservation = _nearestReservation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ActivityTile(
            icon: _vehicle?.isAnprEnabled == true
                ? Icons.verified_rounded
                : Icons.pending_actions_rounded,
            title: _vehicle == null
                ? 'No vehicle registered yet'
                : _vehicle!.isAnprEnabled
                    ? 'Vehicle approved for ANPR'
                    : 'Vehicle pending ANPR approval',
            subtitle: _vehicle?.plateNumber ?? 'Register your vehicle first',
            trailing: _vehicle == null
                ? 'None'
                : _formatStatusLabel(_vehicle!.stickerStatus),
            color: _vehicle?.isAnprEnabled == true
                ? const Color(0xFF22C55E)
                : const Color(0xFFF59E0B),
          ),
          ActivityTile(
            icon: Icons.event_available_rounded,
            title: reservation == null
                ? 'No upcoming reservation'
                : 'Reservation ${reservation.status.label}',
            subtitle: reservation == null
                ? 'Book a bay before arriving'
                : reservation.reservationReference,
            trailing: reservation == null ? '-' : reservation.bayCode,
            color: AppTheme.primaryBlue,
          ),
          ActivityTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallet balance updated',
            subtitle: 'Current available wallet balance',
            trailing: 'RM${_walletBalance.toStringAsFixed(2)}',
            color: const Color(0xFFF59E0B),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) return;

        if (index == 1) {
          Navigator.of(context).pushNamed('/parking');
          return;
        }

        if (index == 2) {
          Navigator.of(context).pushNamed('/reserve');
          return;
        }

        if (index == 3) {
          Navigator.of(context).pushNamed('/wallet');
          return;
        }

        if (index == 4) {
          Navigator.of(context).pushNamed('/profile');
          return;
        }
      },
    );
  }

  // =====================================================
  // FORMAT HELPERS
  // =====================================================

  String _formatStatusLabel(String value) {
    if (value.trim().isEmpty) return '-';

    return value
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;

          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String _formatDateTimeRange(DateTime start, DateTime end) {
    return '${_formatDate(start)}, ${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatDate(DateTime value) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _formatTime(DateTime value) {
    final int hour = value.hour;
    final int minute = value.minute;

    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final String minuteText = minute.toString().padLeft(2, '0');

    return '$displayHour:$minuteText $period';
  }
}

// =====================================================
// SECTION CARD
// =====================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.actionText,
    required this.onActionTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// =====================================================
// SMALL QUICK ACTION
// =====================================================

class _SmallQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SmallQuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE8EEF7),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}