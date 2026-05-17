// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/parking_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parking_bay.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/parking_bay_card.dart';

// =====================================================
// PARKING SCREEN
// =====================================================

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

// =====================================================
// PARKING SCREEN STATE
// =====================================================

class _ParkingScreenState extends State<ParkingScreen> {
  final ParkingService _parkingService = ParkingService();

  List<ParkingBay> _parkingBays = [];

  String _selectedZone = 'All';
  ParkingBayStatus? _selectedStatus;

  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastLoadedAt;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadParkingBays();
  }

  // =====================================================
  // LOAD PARKING BAYS
  // =====================================================

  Future<void> _loadParkingBays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<ParkingBay> bays = await _parkingService.getParkingBays();

      if (!mounted) return;

      setState(() {
        _parkingBays = bays;
        _lastLoadedAt = DateTime.now();
        _isLoading = false;

        if (_selectedZone != 'All' &&
            !_availableZoneCodes.contains(_selectedZone)) {
          _selectedZone = 'All';
        }
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
  // FILTER DATA
  // =====================================================

  List<String> get _availableZoneCodes {
    final Set<String> codes = {};

    for (final ParkingBay bay in _parkingBays) {
      final String? zoneCode = bay.zoneCode;

      if (zoneCode != null && zoneCode.trim().isNotEmpty && zoneCode != '-') {
        codes.add(zoneCode);
      }
    }

    final List<String> sortedCodes = codes.toList()
      ..sort((a, b) => a.compareTo(b));

    return sortedCodes;
  }

  List<String> get _zones {
    return [
      'All',
      ..._availableZoneCodes,
    ];
  }

  List<ParkingBay> get _filteredBays {
    return _parkingBays.where((bay) {
      final bool zoneMatch =
          _selectedZone == 'All' || bay.zoneCode == _selectedZone;

      final bool statusMatch =
          _selectedStatus == null || bay.status == _selectedStatus;

      return zoneMatch && statusMatch;
    }).toList();
  }

  // =====================================================
  // SUMMARY COUNTS
  // =====================================================

  int get _totalCount => _parkingBays.length;

  int get _availableCount => _parkingBays
      .where((bay) => bay.status == ParkingBayStatus.available)
      .length;

  int get _occupiedCount => _parkingBays
      .where((bay) => bay.status == ParkingBayStatus.occupied)
      .length;

  int get _reservedCount => _parkingBays
      .where((bay) => bay.status == ParkingBayStatus.reserved)
      .length;

  String get _updatedLabel {
    if (_lastLoadedAt == null) {
      return 'Not updated yet';
    }

    return 'Updated just now';
  }

  String _formatZoneLabel(String zoneCode) {
    if (zoneCode == 'All') {
      return 'All';
    }

    return 'Zone $zoneCode';
  }

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
                onRefresh: _loadParkingBays,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else ...[
                        _buildSummaryCard(),
                        const SizedBox(height: 22),
                        _buildZoneFilters(),
                        const SizedBox(height: 16),
                        _buildStatusFilters(),
                        const SizedBox(height: 22),
                        _buildSectionHeader(),
                        const SizedBox(height: 14),
                        _buildBayGrid(),
                        const SizedBox(height: 20),
                        _buildLegendCard(),
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
        InkWell(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF0F172A),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parking Availability',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View available, occupied and reserved bays',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _loadParkingBays,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
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
      padding: const EdgeInsets.symmetric(vertical: 60),
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
            'Loading parking bays...',
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
      padding: const EdgeInsets.all(18),
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
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load parking bays',
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
            onPressed: _loadParkingBays,
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
  // SUMMARY CARD
  // =====================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Live Parking Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF22C55E),
                      size: 8,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Supabase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _SummaryItem(
                value: _totalCount.toString(),
                label: 'Total',
                icon: Icons.local_parking_rounded,
              ),
              _SummaryItem(
                value: _availableCount.toString(),
                label: 'Available',
                icon: Icons.check_circle_rounded,
              ),
              _SummaryItem(
                value: _occupiedCount.toString(),
                label: 'Occupied',
                icon: Icons.directions_car_rounded,
              ),
              _SummaryItem(
                value: _reservedCount.toString(),
                label: 'Reserved',
                icon: Icons.event_busy_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ZONE FILTERS
  // =====================================================

  Widget _buildZoneFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parking Zone',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _zones.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final String zone = _zones[index];
              final bool isSelected = zone == _selectedZone;

              return _FilterPill(
                label: _formatZoneLabel(zone),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedZone = zone;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // =====================================================
  // STATUS FILTERS
  // =====================================================

  Widget _buildStatusFilters() {
    final List<_StatusFilterOption> options = [
      const _StatusFilterOption(
        label: 'All',
        color: AppTheme.primaryBlue,
        status: null,
      ),
      const _StatusFilterOption(
        label: 'Available',
        color: Color(0xFF22C55E),
        status: ParkingBayStatus.available,
      ),
      const _StatusFilterOption(
        label: 'Occupied',
        color: Color(0xFFEF4444),
        status: ParkingBayStatus.occupied,
      ),
      const _StatusFilterOption(
        label: 'Reserved',
        color: Color(0xFFF59E0B),
        status: ParkingBayStatus.reserved,
      ),
      const _StatusFilterOption(
        label: 'Maintenance',
        color: Color(0xFF64748B),
        status: ParkingBayStatus.maintenance,
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final _StatusFilterOption option = options[index];

          return _StatusFilterPill(
            label: option.label,
            color: option.color,
            isSelected: _selectedStatus == option.status,
            onTap: () {
              setState(() {
                _selectedStatus = option.status;
              });
            },
          );
        },
      ),
    );
  }

  // =====================================================
  // SECTION HEADER
  // =====================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Parking Bays (${_filteredBays.length})',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Text(
          _updatedLabel,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BAY GRID
  // =====================================================

  Widget _buildBayGrid() {
    final List<ParkingBay> bays = _filteredBays;

    if (bays.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE8EEF7),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: Color(0xFF94A3B8),
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'No parking bays found',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try another zone or status filter.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bays.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 235,
      ),
      itemBuilder: (context, index) {
        final ParkingBay bay = bays[index];

        return ParkingBayCard(
          bay: bay,
          onReserve: () => _handleReserve(bay),
        );
      },
    );
  }

  // =====================================================
  // LEGEND CARD
  // =====================================================

  Widget _buildLegendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Legend',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _LegendItem(
                color: Color(0xFF22C55E),
                label: 'Available',
              ),
              _LegendItem(
                color: Color(0xFFEF4444),
                label: 'Occupied',
              ),
              _LegendItem(
                color: Color(0xFFF59E0B),
                label: 'Reserved',
              ),
              _LegendItem(
                color: Color(0xFF64748B),
                label: 'Maintenance',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RESERVE HANDLER
  // =====================================================

  void _handleReserve(ParkingBay bay) {
    Navigator.of(context).pushNamed(
      '/reserve',
      arguments: bay,
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 1) return;

        if (index == 2) {
          Navigator.of(context).pushNamed('/reserve');
          return;
        }

        if (index == 3) {
          Navigator.of(context).pushReplacementNamed('/wallet');
          return;
        }

        if (index == 4) {
          Navigator.of(context).pushNamed('/profile');
          return;
        }

        _showComingSoon(context, _navName(index));
      },
    );
  }

  String _navName(int index) {
    switch (index) {
      case 2:
        return 'Reservation';
      case 3:
        return 'Wallet';
      case 4:
        return 'Profile';
      default:
        return 'Feature';
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen will be added next.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}

// =====================================================
// STATUS FILTER OPTION
// =====================================================

class _StatusFilterOption {
  final String label;
  final Color color;
  final ParkingBayStatus? status;

  const _StatusFilterOption({
    required this.label,
    required this.color,
    required this.status,
  });
}

// =====================================================
// SUMMARY ITEM
// =====================================================

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 10.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FILTER PILL
// =====================================================

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// STATUS FILTER PILL
// =====================================================

class _StatusFilterPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusFilterPill({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LEGEND ITEM
// =====================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}