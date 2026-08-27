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

  final List<String> _durations = const ['1 Hour', '2 Hours', '3 Hours'];

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

    return ['All', ...sortedCodes];
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

    final int endMinutes = (_customEndTime!.hour * 60) + _customEndTime!.minute;

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
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 60)),
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
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime get _reservationStartAt {
    final TimeOfDay startTime = _isCustomTimeSlot
        ? _customStartTime!
        : _selectedPresetStartTime;

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
      _setCustomTimeSlot(startTime: startTime, endTime: endTime);
    });
  }

  // =====================================================
  // BUILD - MOBILE NATIVE RESERVATION FLOW
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reserve',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadParkingBays,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    const Text(
                      'Choose an available bay and reservation time.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildFieldLabel('Parking area'),
                    const SizedBox(height: 8),
                    _buildZoneDropdown(),
                    const SizedBox(height: 22),
                    _buildFieldLabel('Parking bay'),
                    const SizedBox(height: 8),
                    _buildBayPicker(),
                    const SizedBox(height: 22),
                    _buildFieldLabel('Date'),
                    const SizedBox(height: 8),
                    _buildDatePickerRow(),
                    const SizedBox(height: 22),
                    _buildFieldLabel('Duration'),
                    const SizedBox(height: 8),
                    _buildDurationDropdown(),
                    const SizedBox(height: 22),
                    _buildFieldLabel('Time'),
                    const SizedBox(height: 8),
                    _buildTimePickerRow(),
                    const SizedBox(height: 28),
                    _buildFreeParkingNotice(),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _confirmReservation,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text('Confirm reservation'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'UTeM students and staff park free 24/7. No reservation fee or after-7:00 PM parking charge applies.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildZoneDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _zones.contains(_selectedZone) ? _selectedZone : 'All',
      decoration: const InputDecoration(hintText: 'Select parking area'),
      items: _zones
          .map(
            (zone) => DropdownMenuItem<String>(
              value: zone,
              child: Text(_formatZoneLabel(zone)),
            ),
          )
          .toList(),
      onChanged: _isSubmitting
          ? null
          : (value) {
              if (value == null) return;
              setState(() {
                _selectedZone = value;
                _selectedBay = null;
              });
            },
    );
  }

  Widget _buildBayPicker() {
    if (_isLoadingBays) {
      return const _FieldSurface(
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading available bays...'),
          ],
        ),
      );
    }

    if (_bayLoadError != null) {
      return _FieldSurface(
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Unable to load parking bays.',
                style: TextStyle(color: Color(0xFFB42318)),
              ),
            ),
            TextButton(onPressed: _loadParkingBays, child: const Text('Retry')),
          ],
        ),
      );
    }

    final bay = _selectedBay;

    return _FieldSurface(
      onTap: _isSubmitting ? null : _showBayPicker,
      child: Row(
        children: [
          const Icon(Icons.local_parking_rounded, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bay == null
                      ? 'Choose an available bay'
                      : 'Bay ${bay.bayNumber}',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bay == null
                      ? '${_availableBays.length} available in ${_formatZoneLabel(_selectedZone)}'
                      : bay.zone,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ],
      ),
    );
  }

  Future<void> _showBayPicker() async {
    final bays = _availableBays;

    if (bays.isEmpty) {
      _showMessage('No available bay in this parking area.');
      return;
    }

    final ParkingBay? selected = await showModalBottomSheet<ParkingBay>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_formatZoneLabel(_selectedZone)} · ${bays.length} available',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: bays.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final bay = bays[index];
                    return ListTile(
                      title: Text(
                        'Bay ${bay.bayNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(bay.zone),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(sheetContext).pop(bay),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedBay = selected);
    }
  }

  Widget _buildDatePickerRow() {
    return _FieldSurface(
      onTap: _isSubmitting ? null : _pickReservationDate,
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedDateLabel,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ],
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDuration,
      items: _durations
          .map(
            (duration) => DropdownMenuItem<String>(
              value: duration,
              child: Text(duration),
            ),
          )
          .toList(),
      onChanged: _isSubmitting
          ? null
          : (value) {
              if (value == null) return;
              setState(() {
                _selectedDuration = value;
                _isCustomTimeSlot = false;
                _customStartTime = null;
                _customEndTime = null;
              });
            },
    );
  }

  Widget _buildTimePickerRow() {
    return _FieldSurface(
      onTap: _isSubmitting ? null : _showTimePickerSheet,
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reservationDateTimeLabel,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isCustomTimeSlot) ...[
                  const SizedBox(height: 2),
                  Text(
                    _customDurationLabel,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ],
      ),
    );
  }

  Future<void> _showTimePickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose time',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final startTime in _presetStartTimes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    !_isCustomTimeSlot && startTime == _selectedPresetStartTime
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                  title: Text(_presetSlotLabel(startTime)),
                  onTap: () {
                    setState(() {
                      _selectedPresetStartTime = startTime;
                      _isCustomTimeSlot = false;
                      _customStartTime = null;
                      _customEndTime = null;
                    });
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_calendar_outlined),
                title: const Text('Custom time'),
                subtitle: const Text('Choose start and end time'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickCustomTimeSlot();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeParkingNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.14)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, color: AppTheme.primaryBlue, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREE 24/7 for UTeM users',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Student and staff reservations are free, including parking after 7:00 PM.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12.5,
                    height: 1.4,
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

    if (_reservationStartAt.isBefore(
      DateTime.now().add(const Duration(minutes: 5)),
    )) {
      _showMessage('Please choose a future reservation time.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ReservationResult result = await _reservationService
          .createCurrentUserReservation(
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
            'UTeM parking: FREE 24/7',
            style: const TextStyle(color: Color(0xFF475569), height: 1.45),
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
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          Navigator.of(context).pushReplacementNamed('/profile');
          return;
        }
      },
    );
  }
}

class _FieldSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _FieldSurface({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.canvas,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
