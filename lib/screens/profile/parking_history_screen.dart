// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/anpr_log_service.dart';
import '../../core/services/reservation_history_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/anpr_log_record.dart';
import '../../models/reservation_record.dart';

// =====================================================
// PARKING HISTORY SCREEN
// =====================================================

class ParkingHistoryScreen extends StatefulWidget {
  const ParkingHistoryScreen({super.key});

  @override
  State<ParkingHistoryScreen> createState() => _ParkingHistoryScreenState();
}

// =====================================================
// PARKING HISTORY SCREEN STATE
// =====================================================

class _ParkingHistoryScreenState extends State<ParkingHistoryScreen> {
  final ReservationHistoryService _reservationHistoryService =
      ReservationHistoryService();

  final AnprLogService _anprLogService = AnprLogService();

  final TextEditingController _searchController = TextEditingController();

  List<ReservationRecord> _reservations = [];
  List<AnprLogRecord> _anprLogs = [];

  String _searchQuery = '';
  _HistoryFilter _selectedFilter = _HistoryFilter.all;

  bool _isLoading = true;
  String? _errorMessage;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD HISTORY
  // =====================================================

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<ReservationRecord> reservations =
          await _reservationHistoryService.getCurrentUserReservations();

      final List<AnprLogRecord> anprLogs =
          await _anprLogService.getCurrentUserAnprLogs();

      if (!mounted) return;

      setState(() {
        _reservations = reservations;
        _anprLogs = anprLogs;
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
  // SUMMARY HELPERS
  // =====================================================

  int get _totalEvents => _reservations.length + _anprLogs.length;

  int get _totalReservations => _reservations.length;

  int get _totalAnprLogs => _anprLogs.length;

  double get _totalFeesPaid {
    return _reservations.fold(0, (total, reservation) {
      return total + reservation.totalPaid;
    });
  }

  List<_HistoryItem> get _allHistoryItems {
    final List<_HistoryItem> items = [
      ..._reservations.map(_HistoryItem.fromReservation),
      ..._anprLogs.map(_HistoryItem.fromAnprLog),
    ];

    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return items;
  }

  List<_HistoryItem> get _filteredHistoryItems {
    return _allHistoryItems.where((item) {
      final String query = _searchQuery.trim().toLowerCase();

      final bool filterMatch = _matchesFilter(item);
      final bool searchMatch = query.isEmpty || item.searchText.contains(query);

      return filterMatch && searchMatch;
    }).toList();
  }

  bool _matchesFilter(_HistoryItem item) {
    switch (_selectedFilter) {
      case _HistoryFilter.all:
        return true;
      case _HistoryFilter.reservations:
        return item.type == _HistoryItemType.reservation;
      case _HistoryFilter.entry:
        return item.anprLog?.isEntry == true;
      case _HistoryFilter.exit:
        return item.anprLog?.isExit == true;
      case _HistoryFilter.allowed:
        return item.anprLog?.isAllowed == true;
      case _HistoryFilter.denied:
        return item.anprLog != null && item.anprLog!.isAllowed == false;
      case _HistoryFilter.upcoming:
        return item.reservation?.status == ReservationRecordStatus.upcoming;
      case _HistoryFilter.active:
        return item.reservation?.status == ReservationRecordStatus.active;
      case _HistoryFilter.completed:
        return item.reservation?.status == ReservationRecordStatus.completed;
      case _HistoryFilter.cancelled:
        return item.reservation?.status == ReservationRecordStatus.cancelled;
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (_isLoading)
                  _buildLoadingState()
                else if (_errorMessage != null)
                  _buildErrorState()
                else ...[
                  _buildSummary(),
                  const SizedBox(height: 20),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 14),
                  _buildHistoryList(),
                ],
              ],
            ),
          ),
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
        _BackButton(onTap: () => Navigator.of(context).pop()),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parking History',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Reservations and ANPR entry/exit logs',
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
          onTap: _loadHistory,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
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
            'Loading parking history...',
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
            'Unable to load history',
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
            onPressed: _loadHistory,
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
  // SUMMARY
  // =====================================================

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: AppTheme.primaryBlue.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryItem(
            value: _totalEvents.toString(),
            label: 'Total Logs',
          ),
          _SummaryItem(
            value: _totalReservations.toString(),
            label: 'Reservations',
          ),
          _SummaryItem(
            value: _totalAnprLogs.toString(),
            label: 'ANPR Logs',
          ),
          _SummaryItem(
            value: 'RM${_totalFeesPaid.toStringAsFixed(0)}',
            label: 'Fees',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SEARCH AND FILTERS
  // =====================================================

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8EEF7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: AppTheme.primaryBlue,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search reference, bay, plate, gate...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF64748B),
              ),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _HistoryFilterChip(
                label: 'All',
                isSelected: _selectedFilter == _HistoryFilter.all,
                color: AppTheme.primaryBlue,
                onTap: () => _setFilter(_HistoryFilter.all),
              ),
              _HistoryFilterChip(
                label: 'Reservations',
                isSelected: _selectedFilter == _HistoryFilter.reservations,
                color: AppTheme.primaryBlue,
                onTap: () => _setFilter(_HistoryFilter.reservations),
              ),
              _HistoryFilterChip(
                label: 'Entry',
                isSelected: _selectedFilter == _HistoryFilter.entry,
                color: const Color(0xFF22C55E),
                onTap: () => _setFilter(_HistoryFilter.entry),
              ),
              _HistoryFilterChip(
                label: 'Exit',
                isSelected: _selectedFilter == _HistoryFilter.exit,
                color: const Color(0xFF64748B),
                onTap: () => _setFilter(_HistoryFilter.exit),
              ),
              _HistoryFilterChip(
                label: 'Allowed',
                isSelected: _selectedFilter == _HistoryFilter.allowed,
                color: const Color(0xFF22C55E),
                onTap: () => _setFilter(_HistoryFilter.allowed),
              ),
              _HistoryFilterChip(
                label: 'Denied',
                isSelected: _selectedFilter == _HistoryFilter.denied,
                color: const Color(0xFFEF4444),
                onTap: () => _setFilter(_HistoryFilter.denied),
              ),
              _HistoryFilterChip(
                label: 'Upcoming',
                isSelected: _selectedFilter == _HistoryFilter.upcoming,
                color: const Color(0xFFF59E0B),
                onTap: () => _setFilter(_HistoryFilter.upcoming),
              ),
              _HistoryFilterChip(
                label: 'Active',
                isSelected: _selectedFilter == _HistoryFilter.active,
                color: const Color(0xFF22C55E),
                onTap: () => _setFilter(_HistoryFilter.active),
              ),
              _HistoryFilterChip(
                label: 'Completed',
                isSelected: _selectedFilter == _HistoryFilter.completed,
                color: AppTheme.primaryBlue,
                onTap: () => _setFilter(_HistoryFilter.completed),
              ),
              _HistoryFilterChip(
                label: 'Cancelled',
                isSelected: _selectedFilter == _HistoryFilter.cancelled,
                color: const Color(0xFFEF4444),
                onTap: () => _setFilter(_HistoryFilter.cancelled),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setFilter(_HistoryFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // =====================================================
  // SECTION HEADER
  // =====================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Parking Timeline',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '${_filteredHistoryItems.length} records',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // HISTORY LIST
  // =====================================================

  Widget _buildHistoryList() {
    final List<_HistoryItem> items = _filteredHistoryItems;

    if (items.isEmpty) {
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
              Icons.history_rounded,
              color: Color(0xFF94A3B8),
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No history records found',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Reservations and ANPR logs will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        if (item.type == _HistoryItemType.anpr && item.anprLog != null) {
          return _AnprHistoryTile(log: item.anprLog!);
        }

        if (item.reservation != null) {
          return _ReservationHistoryTile(reservation: item.reservation!);
        }

        return const SizedBox.shrink();
      }).toList(),
    );
  }
}

// =====================================================
// HISTORY FILTER
// =====================================================

enum _HistoryFilter {
  all,
  reservations,
  entry,
  exit,
  allowed,
  denied,
  upcoming,
  active,
  completed,
  cancelled,
}

// =====================================================
// HISTORY ITEM TYPE
// =====================================================

enum _HistoryItemType {
  reservation,
  anpr,
}

// =====================================================
// HISTORY ITEM
// =====================================================

class _HistoryItem {
  final _HistoryItemType type;
  final ReservationRecord? reservation;
  final AnprLogRecord? anprLog;
  final DateTime dateTime;
  final String searchText;

  const _HistoryItem({
    required this.type,
    required this.reservation,
    required this.anprLog,
    required this.dateTime,
    required this.searchText,
  });

  factory _HistoryItem.fromReservation(ReservationRecord reservation) {
    return _HistoryItem(
      type: _HistoryItemType.reservation,
      reservation: reservation,
      anprLog: null,
      dateTime: reservation.reservationStartAt,
      searchText: [
        reservation.reservationReference,
        reservation.plateNumber,
        reservation.bayCode,
        reservation.zoneCode,
        reservation.locationName,
        reservation.status.label,
      ].join(' ').toLowerCase(),
    );
  }

  factory _HistoryItem.fromAnprLog(AnprLogRecord log) {
    return _HistoryItem(
      type: _HistoryItemType.anpr,
      reservation: null,
      anprLog: log,
      dateTime: log.detectedAt,
      searchText: [
        log.detectedPlateNumber,
        log.plateNumber,
        log.bayCode,
        log.zoneCode,
        log.gateLocation,
        log.locationName,
        log.detectionLabel,
        log.accessDecisionLabel,
        log.accessStatusLabel,
        log.reason,
      ].join(' ').toLowerCase(),
    );
  }
}

// =====================================================
// BACK BUTTON
// =====================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8EEF7),
          ),
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
    );
  }
}

// =====================================================
// SUMMARY ITEM
// =====================================================

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
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
// HISTORY FILTER CHIP
// =====================================================

class _HistoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _HistoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// RESERVATION HISTORY TILE
// =====================================================

class _ReservationHistoryTile extends StatelessWidget {
  final ReservationRecord reservation;

  const _ReservationHistoryTile({
    required this.reservation,
  });

  Color get _statusColor {
    switch (reservation.status) {
      case ReservationRecordStatus.upcoming:
        return const Color(0xFFF59E0B);
      case ReservationRecordStatus.active:
        return const Color(0xFF22C55E);
      case ReservationRecordStatus.completed:
        return AppTheme.primaryBlue;
      case ReservationRecordStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  IconData get _statusIcon {
    switch (reservation.status) {
      case ReservationRecordStatus.upcoming:
        return Icons.event_available_rounded;
      case ReservationRecordStatus.active:
        return Icons.local_parking_rounded;
      case ReservationRecordStatus.completed:
        return Icons.check_circle_rounded;
      case ReservationRecordStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: _historyCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _HistoryIconBox(
                icon: _statusIcon,
                color: _statusColor,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.reservationReference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _titleStyle(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.bayLabel} • ${reservation.locationLabel}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _subtitleStyle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: reservation.status.label,
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _HistoryInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Schedule',
            value: _formatDateTimeRange(
              reservation.reservationStartAt,
              reservation.reservationEndAt,
            ),
          ),
          const SizedBox(height: 10),
          _HistoryInfoRow(
            icon: Icons.timelapse_rounded,
            label: 'Duration',
            value: reservation.durationLabel,
          ),
          const SizedBox(height: 10),
          _HistoryInfoRow(
            icon: Icons.directions_car_filled_rounded,
            label: 'Vehicle',
            value: reservation.plateNumber,
          ),
          const SizedBox(height: 12),
          Divider(
            color: const Color(0xFFE8EEF7).withValues(alpha: 0.85),
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FeeChip(
                  label: 'Reservation',
                  value: 'RM${reservation.reservationFee.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeeChip(
                  label: 'After 7PM',
                  value: 'RM${reservation.after7ParkingFee.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeeChip(
                  label: 'Total',
                  value: 'RM${reservation.totalPaid.toStringAsFixed(2)}',
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ANPR HISTORY TILE
// =====================================================

class _AnprHistoryTile extends StatelessWidget {
  final AnprLogRecord log;

  const _AnprHistoryTile({
    required this.log,
  });

  Color get _color {
    if (!log.isAllowed) {
      return const Color(0xFFEF4444);
    }

    if (log.isEntry) {
      return const Color(0xFF22C55E);
    }

    return const Color(0xFF64748B);
  }

  IconData get _icon {
    if (!log.isAllowed) {
      return Icons.block_rounded;
    }

    if (log.isEntry) {
      return Icons.login_rounded;
    }

    return Icons.logout_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final double confidence =
        log.confidenceScore > 0 ? log.confidenceScore : log.confidence;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: _historyCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _HistoryIconBox(
                icon: _icon,
                color: _color,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANPR ${log.detectionLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _titleStyle(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.detectedPlateNumber} • ${log.gateLocation}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _subtitleStyle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: log.accessDecisionLabel,
                color: _color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _HistoryInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Detected',
            value: _formatDateTime(log.detectedAt),
          ),
          const SizedBox(height: 10),
          _HistoryInfoRow(
            icon: Icons.local_parking_rounded,
            label: 'Location',
            value: '${log.bayLabel} • ${log.locationLabel}',
          ),
          const SizedBox(height: 10),
          _HistoryInfoRow(
            icon: Icons.verified_user_rounded,
            label: 'Access',
            value: '${log.accessStatusLabel} • ${log.reason}',
          ),
          const SizedBox(height: 10),
          _HistoryInfoRow(
            icon: Icons.center_focus_strong_rounded,
            label: 'Confidence',
            value: confidence <= 0 ? '-' : '${confidence.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SHARED HISTORY WIDGETS
// =====================================================

class _HistoryIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _HistoryIconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

class _HistoryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HistoryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          fontSize: 11.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FeeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _FeeChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        highlight ? const Color(0xFF22C55E) : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color.withValues(alpha: 0.78),
              fontSize: 10.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SHARED HELPERS
// =====================================================

BoxDecoration _historyCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color(0xFFE8EEF7),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.035),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

TextStyle _titleStyle() {
  return const TextStyle(
    color: Color(0xFF0F172A),
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
  );
}

TextStyle _subtitleStyle() {
  return const TextStyle(
    color: Color(0xFF64748B),
    fontSize: 12.2,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}

String _formatDateTimeRange(DateTime start, DateTime end) {
  return '${_formatDate(start)}, ${_formatTime(start)} - ${_formatTime(end)}';
}

String _formatDateTime(DateTime value) {
  return '${_formatDate(value)}, ${_formatTime(value)}';
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