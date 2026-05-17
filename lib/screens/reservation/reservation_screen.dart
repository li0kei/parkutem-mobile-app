// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/parking_service.dart';
import '../../core/services/reservation_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parking_bay.dart';
import '../../models/reservation_result.dart';
import '../../widgets/app_bottom_navigation.dart';

// =====================================================
// RESERVATION SCREEN
// =====================================================

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

// =====================================================
// RESERVATION SCREEN STATE
// =====================================================

class _ReservationScreenState extends State<ReservationScreen> {
  final ParkingService _parkingService = ParkingService();
  final ReservationService _reservationService = ReservationService();

  String _selectedZone = 'All';
  ParkingBay? _selectedBay;

  List<ParkingBay> _parkingBays = [];

  bool _isLoadingBays = true;
  bool _isSubmitting = false;
  bool _isRouteArgumentLoaded = false;
  String? _bayLoadError;

  DateTime _selectedDate = DateTime.now();

  String _selectedDuration = '2 Hours';
  TimeOfDay _selectedPresetStartTime = const TimeOfDay(hour: 14, minute: 0);

  TimeOfDay? _customStartTime;
  TimeOfDay? _customEndTime;
  bool _isCustomTimeSlot = false;

  final double _fixedReservationFee = 2.00;
  final double _parkingFeePerHour = 1.00;

  final List<String> _durations = const [
    '1 Hour',
    '2 Hours',
    '3 Hours',
  ];

  final List<TimeOfDay> _presetStartTimes = const [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
  ];

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadParkingBays();
  }

  // =====================================================
  // ROUTE ARGUMENT
  // =====================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isRouteArgumentLoaded) return;

    final Object? argument = ModalRoute.of(context)?.settings.arguments;

    if (argument is ParkingBay) {
      _selectedZone = argument.zoneCode ?? 'All';
      _selectedBay = argument;
    }

    _isRouteArgumentLoaded = true;
  }

  // =====================================================
  // LOAD PARKING BAYS
  // =====================================================

  Future<void> _loadParkingBays() async {
    setState(() {
      _isLoadingBays = true;
      _bayLoadError = null;
    });

    try {
      final List<ParkingBay> bays = await _parkingService.getParkingBays();

      ParkingBay? latestSelectedBay = _selectedBay;

      if (_selectedBay != null) {
        final List<ParkingBay> matchingBays = bays
            .where((bay) => bay.id == _selectedBay!.id)
            .toList();

        if (matchingBays.isNotEmpty &&
            matchingBays.first.status == ParkingBayStatus.available) {
          latestSelectedBay = matchingBays.first;
        } else {
          latestSelectedBay = null;
        }
      }

      if (!mounted) return;

      setState(() {
        _parkingBays = bays;
        _selectedBay = latestSelectedBay;
        _isLoadingBays = false;

        if (_selectedZone != 'All' && !_zones.contains(_selectedZone)) {
          _selectedZone = 'All';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _bayLoadError = error.toString();
        _isLoadingBays = false;
      });
    }
  }

  // =====================================================
  // ZONE DATA
  // =====================================================

  List<String> get _zones {
    final Set<String> zoneCodes = {};

    for (final ParkingBay bay in _parkingBays) {
      final String? zoneCode = bay.zoneCode;

      if (zoneCode != null && zoneCode.trim().isNotEmpty && zoneCode != '-') {
        zoneCodes.add(zoneCode);
      }
    }

    final List<String> sortedCodes = zoneCodes.toList()
      ..sort((a, b) => a.compareTo(b));

    return [
      'All',
      ...sortedCodes,
    ];
  }

  String _formatZoneLabel(String zoneCode) {
    if (zoneCode == 'All') return 'All';

    return 'Zone $zoneCode';
  }

  // =====================================================
  // AVAILABLE BAYS
  // =====================================================

  List<ParkingBay> get _availableBays {
    return _parkingBays.where((bay) {
      final bool zoneMatch =
          _selectedZone == 'All' || bay.zoneCode == _selectedZone;

      final bool statusMatch = bay.status == ParkingBayStatus.available;

      return zoneMatch && statusMatch;
    }).toList();
  }

  // =====================================================
  // DURATION HELPERS
  // =====================================================

  int get _durationHours {
    switch (_selectedDuration) {
      case '1 Hour':
        return 1;
      case '2 Hours':
        return 2;
      case '3 Hours':
        return 3;
      default:
        return 2;
    }
  }

  int get _customDurationMinutes {
    if (_customStartTime == null || _customEndTime == null) return 0;

    final int startMinutes =
        (_customStartTime!.hour * 60) + _customStartTime!.minute;

    final int endMinutes =
        (_customEndTime!.hour * 60) + _customEndTime!.minute;

    return endMinutes - startMinutes;
  }

  String get _customDurationLabel {
    final int minutes = _customDurationMinutes;

    if (minutes <= 0) return 'Invalid duration';

    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes minutes';
    }

    if (remainingMinutes == 0) {
      return '$hours hour${hours == 1 ? '' : 's'}';
    }

    return '$hours hour${hours == 1 ? '' : 's'} $remainingMinutes minutes';
  }

  String get _reservationDurationLabel {
    if (_isCustomTimeSlot) {
      return _customDurationLabel;
    }

    return _selectedDuration;
  }

  String _durationFeeLabel(String duration) {
    return 'Preset duration';
  }

  // =====================================================
  // RESERVATION FEE
  // =====================================================

  double get _reservationFee {
    return _fixedReservationFee;
  }

  // =====================================================
  // PARKING FEE AFTER 7PM
  // =====================================================

  double get _parkingFee {
    final TimeOfDay? startTime =
        _isCustomTimeSlot ? _customStartTime : _selectedPresetStartTime;

    final TimeOfDay? endTime = _isCustomTimeSlot
        ? _customEndTime
        : _addHoursToTime(_selectedPresetStartTime, _durationHours);

    if (startTime == null || endTime == null) return 0.00;

    final int startMinutes = (startTime.hour * 60) + startTime.minute;
    int endMinutes = (endTime.hour * 60) + endTime.minute;

    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }

    const int chargeStartMinutes = 19 * 60;

    if (endMinutes <= chargeStartMinutes) {
      return 0.00;
    }

    final int chargedStartMinutes =
        startMinutes < chargeStartMinutes ? chargeStartMinutes : startMinutes;

    final int chargeableMinutes = endMinutes - chargedStartMinutes;

    if (chargeableMinutes <= 0) return 0.00;

    final double chargeableHours = chargeableMinutes / 60;

    return chargeableHours.ceilToDouble() * _parkingFeePerHour;
  }

  double get _totalToPay {
    return _reservationFee + _parkingFee;
  }

  // =====================================================
  // DATE HELPERS
  // =====================================================

  String get _selectedDateLabel {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selected == today) return 'Today';
    if (selected == tomorrow) return 'Tomorrow';

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

    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> _pickReservationDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day).add(
        const Duration(days: 60),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // =====================================================
  // TIME HELPERS
  // =====================================================

  TimeOfDay _addHoursToTime(TimeOfDay time, int hours) {
    final int totalMinutes = (time.hour * 60) + time.minute + (hours * 60);
    final int normalizedMinutes = totalMinutes % (24 * 60);

    return TimeOfDay(
      hour: normalizedMinutes ~/ 60,
      minute: normalizedMinutes % 60,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String _presetSlotLabel(TimeOfDay startTime) {
    final TimeOfDay endTime = _addHoursToTime(startTime, _durationHours);

    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  String get _reservationDateTimeLabel {
    if (_isCustomTimeSlot &&
        _customStartTime != null &&
        _customEndTime != null) {
      return '$_selectedDateLabel, '
          '${_formatTimeOfDay(_customStartTime!)} - '
          '${_formatTimeOfDay(_customEndTime!)}';
    }

    return '$_selectedDateLabel, ${_presetSlotLabel(_selectedPresetStartTime)}';
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  DateTime get _reservationStartAt {
    final TimeOfDay startTime =
        _isCustomTimeSlot ? _customStartTime! : _selectedPresetStartTime;

    return _combineDateAndTime(_selectedDate, startTime);
  }

  DateTime get _reservationEndAt {
    final TimeOfDay endTime = _isCustomTimeSlot
        ? _customEndTime!
        : _addHoursToTime(_selectedPresetStartTime, _durationHours);

    DateTime endDateTime = _combineDateAndTime(_selectedDate, endTime);

    if (!endDateTime.isAfter(_reservationStartAt)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime;
  }

  void _setCustomTimeSlot({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    _customStartTime = startTime;
    _customEndTime = endTime;
    _isCustomTimeSlot = true;
  }

  Future<void> _pickCustomTimeSlot() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _customStartTime ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Select start time',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: _customEndTime ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: 'Select end time',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (endTime == null) return;

    final int startMinutes = (startTime.hour * 60) + startTime.minute;
    final int endMinutes = (endTime.hour * 60) + endTime.minute;

    if (endMinutes <= startMinutes) {
      _showMessage('End time must be later than start time.');
      return;
    }

    setState(() {
      _setCustomTimeSlot(
        startTime: startTime,
        endTime: endTime,
      );
    });
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
                      _buildReservationSummary(),
                      const SizedBox(height: 24),
                      _buildZoneSelector(),
                      const SizedBox(height: 24),
                      _buildBaySelector(),
                      const SizedBox(height: 24),
                      _buildDateSelector(),
                      const SizedBox(height: 24),
                      _buildDurationSelector(),
                      const SizedBox(height: 24),
                      _buildTimeSlotSelector(),
                      const SizedBox(height: 24),
                      _buildPaymentSummary(),
                      const SizedBox(height: 24),
                      _buildPolicyNote(),
                      const SizedBox(height: 24),
                      _buildConfirmButton(),
                      const SizedBox(height: 20),
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
                'Reserve Parking',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Book an available bay before arriving',
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
  // RESERVATION SUMMARY
  // =====================================================

  Widget _buildReservationSummary() {
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
            color: AppTheme.primaryBlue.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.local_parking_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Reservation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _selectedBay == null
                      ? 'No bay selected yet'
                      : '${_selectedBay!.zone} • Bay ${_selectedBay!.bayNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _reservationDateTimeLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Total: RM${_totalToPay.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ZONE SELECTOR
  // =====================================================

  Widget _buildZoneSelector() {
    return _SectionContainer(
      title: 'Select Parking Zone',
      child: SizedBox(
        height: 43,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _zones.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final String zone = _zones[index];
            final bool isSelected = zone == _selectedZone;

            return _SelectionPill(
              label: _formatZoneLabel(zone),
              isSelected: isSelected,
              onTap: _isSubmitting
                  ? () {}
                  : () {
                      setState(() {
                        _selectedZone = zone;
                        _selectedBay = null;
                      });
                    },
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // BAY SELECTOR
  // =====================================================

  Widget _buildBaySelector() {
    if (_isLoadingBays) {
      return _SectionContainer(
        title: 'Choose Available Bay',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      );
    }

    if (_bayLoadError != null) {
      return _SectionContainer(
        title: 'Choose Available Bay',
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load parking bays',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _bayLoadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
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

    final List<ParkingBay> bays = _availableBays;

    return _SectionContainer(
      title: 'Choose Available Bay',
      child: bays.isEmpty
          ? _buildEmptyBayState()
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 108,
              ),
              itemBuilder: (context, index) {
                final ParkingBay bay = bays[index];
                final bool isSelected = _selectedBay?.id == bay.id;

                return _BaySelectionCard(
                  bay: bay,
                  isSelected: isSelected,
                  onTap: _isSubmitting
                      ? () {}
                      : () {
                          setState(() {
                            _selectedBay = bay;
                          });
                        },
                );
              },
            ),
    );
  }

  Widget _buildEmptyBayState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: Color(0xFF94A3B8),
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No available bay in this zone',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another parking zone or pull to refresh.',
            textAlign: TextAlign.center,
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

  // =====================================================
  // DATE SELECTOR
  // =====================================================

  Widget _buildDateSelector() {
    return _SectionContainer(
      title: 'Select Reservation Date',
      child: InkWell(
        onTap: _isSubmitting ? null : _pickReservationDate,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDateLabel,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to change reservation date',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DURATION SELECTOR
  // =====================================================

  Widget _buildDurationSelector() {
    return _SectionContainer(
      title: 'Select Preset Duration',
      child: Row(
        children: _durations.map((duration) {
          final bool isSelected = duration == _selectedDuration;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: duration == _durations.last ? 0 : 10,
              ),
              child: _CompactChoiceCard(
                label: duration,
                subtitle: _durationFeeLabel(duration),
                isSelected: isSelected,
                onTap: _isSubmitting
                    ? () {}
                    : () {
                        setState(() {
                          _selectedDuration = duration;
                          _isCustomTimeSlot = false;
                          _customStartTime = null;
                          _customEndTime = null;
                        });
                      },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =====================================================
  // TIME SLOT SELECTOR
  // =====================================================

  Widget _buildTimeSlotSelector() {
    return _SectionContainer(
      title: 'Select Time Slot',
      child: Column(
        children: [
          ..._presetStartTimes.map((startTime) {
            final bool isSelected =
                !_isCustomTimeSlot && startTime == _selectedPresetStartTime;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TimeSlotCard(
                slot: '$_selectedDateLabel, ${_presetSlotLabel(startTime)}',
                subtitle: 'Preset campus reservation slot',
                isSelected: isSelected,
                onTap: _isSubmitting
                    ? () {}
                    : () {
                        setState(() {
                          _selectedPresetStartTime = startTime;
                          _isCustomTimeSlot = false;
                          _customStartTime = null;
                          _customEndTime = null;
                        });
                      },
              ),
            );
          }),
          _TimeSlotCard(
            slot: _isCustomTimeSlot
                ? _reservationDateTimeLabel
                : 'Custom Time Slot',
            subtitle: _isCustomTimeSlot
                ? 'Custom duration: $_customDurationLabel'
                : 'Choose your own start and end time',
            isSelected: _isCustomTimeSlot,
            icon: Icons.edit_calendar_rounded,
            onTap: _isSubmitting ? () {} : _pickCustomTimeSlot,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PAYMENT SUMMARY
  // =====================================================

  Widget _buildPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _PaymentRow(
            label: 'Reservation Duration',
            value: _reservationDurationLabel,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          _PaymentRow(
            label: 'Reservation Fee',
            value: 'RM${_reservationFee.toStringAsFixed(2)}',
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          _PaymentRow(
            label: 'Parking Fee After 7PM',
            value: 'RM${_parkingFee.toStringAsFixed(2)}',
            color: _parkingFee > 0 ? const Color(0xFFF59E0B) : Colors.white,
          ),
          const SizedBox(height: 14),
          Divider(
            color: Colors.white.withValues(alpha: 0.12),
            height: 1,
          ),
          const SizedBox(height: 14),
          _PaymentRow(
            label: 'Total to Pay',
            value: 'RM${_totalToPay.toStringAsFixed(2)}',
            color: const Color(0xFF22C55E),
            isBold: true,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // POLICY NOTE
  // =====================================================

  Widget _buildPolicyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryBlue,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reservation fee is a fixed one-time charge when students or staff book a bay in advance. '
              'Normal student/staff parking is free from 7:00 AM to 7:00 PM without reservation. '
              'Parking fee after 7:00 PM is calculated for reserved time slots in this prototype.',
              style: TextStyle(
                color: const Color(0xFF0F172A).withValues(alpha: 0.74),
                fontSize: 12.4,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CONFIRM BUTTON
  // =====================================================

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryCyan,
              AppTheme.primaryBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.26),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _confirmReservation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  'Confirm Reservation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }

  // =====================================================
  // CONFIRM RESERVATION
  // =====================================================

  Future<void> _confirmReservation() async {
    if (_selectedBay == null) {
      _showMessage('Please select an available parking bay.');
      return;
    }

    if (_selectedBay!.status != ParkingBayStatus.available) {
      _showMessage('Selected bay is no longer available.');
      return;
    }

    if (_isCustomTimeSlot && _customDurationMinutes <= 0) {
      _showMessage('Please select a valid custom time slot.');
      return;
    }

    if (_reservationStartAt.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      _showMessage('Please choose a future reservation time.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ReservationResult result =
          await _reservationService.createCurrentUserReservation(
        bayId: _selectedBay!.id,
        reservationStartAt: _reservationStartAt,
        reservationEndAt: _reservationEndAt,
      );

      if (!mounted) return;

      await _showReservationSuccessDialog(result);

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      if (!mounted) return;

      _showMessage('Reservation failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showReservationSuccessDialog(ReservationResult result) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Reservation Confirmed',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Reference: ${result.reservationReference}\n\n'
            'Bay ${_selectedBay!.bayNumber} at ${_selectedBay!.zone} has been reserved.\n\n'
            'Date & Time: $_reservationDateTimeLabel\n'
            'Duration: $_reservationDurationLabel\n'
            'Reservation fee: RM${result.reservationFee.toStringAsFixed(2)}\n'
            'Parking fee after 7PM: RM${result.after7ParkingFee.toStringAsFixed(2)}\n'
            'Total paid: RM${result.totalPaid.toStringAsFixed(2)}\n'
            'Wallet balance: RM${result.newWalletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 2,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/parking');
          return;
        }

        if (index == 2) return;

        if (index == 3) {
          Navigator.of(context).pushReplacementNamed('/wallet');
          return;
        }

        if (index == 4) {
          Navigator.of(context).pushReplacementNamed('/profile');
          return;
        }

        _showMessage('${_navName(index)} screen will be added next.');
      },
    );
  }

  String _navName(int index) {
    switch (index) {
      case 3:
        return 'Wallet';
      case 4:
        return 'Profile';
      default:
        return 'Feature';
    }
  }
}

// =====================================================
// SECTION CONTAINER
// =====================================================

class _SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionContainer({
    required this.title,
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
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// =====================================================
// SELECTION PILL
// =====================================================

class _SelectionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionPill({
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
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BAY SELECTION CARD
// =====================================================

class _BaySelectionCard extends StatelessWidget {
  final ParkingBay bay;
  final bool isSelected;
  final VoidCallback onTap;

  const _BaySelectionCard({
    required this.bay,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.local_parking_rounded,
              color: isSelected ? Colors.white : const Color(0xFF22C55E),
              size: 24,
            ),
            const Spacer(),
            Text(
              bay.bayNumber,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              bay.zone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.76)
                    : const Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// COMPACT CHOICE CARD
// =====================================================

class _CompactChoiceCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactChoiceCard({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.78)
                    : const Color(0xFF64748B),
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TIME SLOT CARD
// =====================================================

class _TimeSlotCard extends StatelessWidget {
  final String slot;
  final String? subtitle;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeSlotCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.icon = Icons.access_time_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              color: isSelected ? Colors.white : AppTheme.primaryBlue,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.74)
                            : const Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PAYMENT ROW
// =====================================================

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _PaymentRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}