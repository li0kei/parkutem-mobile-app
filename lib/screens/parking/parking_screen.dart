import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/parking_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parking_bay.dart';
import '../../models/parking_zone.dart';
import '../../widgets/app_bottom_navigation.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  static const LatLng _campusCenter = LatLng(2.3083, 102.3177);

  final ParkingService _parkingService = ParkingService();

  List<ParkingBay> _bays = [];
  List<ParkingZone> _zones = [];

  String _selectedZone = 'All';
  ParkingBayStatus? _selectedStatus;

  bool _isLoading = true;
  String? _error;
  DateTime? _lastLoadedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _parkingService.getParkingBays(),
        _parkingService.getParkingZonesForMap(),
      ]);

      if (!mounted) return;

      final bays = results[0] as List<ParkingBay>;
      final zones = results[1] as List<ParkingZone>;

      setState(() {
        _bays = bays;
        _zones = zones;
        _lastLoadedAt = DateTime.now();
        _isLoading = false;

        if (_selectedZone != 'All' && !_zoneCodes.contains(_selectedZone)) {
          _selectedZone = 'All';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<String> get _zoneCodes {
    final values = <String>{};

    for (final bay in _bays) {
      final code = bay.zoneCode?.trim();
      if (code != null && code.isNotEmpty && code != '-') {
        values.add(code);
      }
    }

    final result = values.toList()..sort((a, b) => a.compareTo(b));

    return result;
  }

  List<ParkingBay> get _filteredBays {
    return _bays.where((bay) {
      final zoneMatch = _selectedZone == 'All' || bay.zoneCode == _selectedZone;
      final statusMatch =
          _selectedStatus == null || bay.status == _selectedStatus;
      return zoneMatch && statusMatch;
    }).toList();
  }

  int get _availableCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.available).length;

  int get _occupiedCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.occupied).length;

  int get _reservedCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.reserved).length;

  void _navigateFromBottomBar(int index) {
    final routes = ['/home', '/parking', '/reserve', '/wallet', '/profile'];
    if (index == 1) return;
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  void _selectZone(String zoneCode) {
    setState(() => _selectedZone = zoneCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text(
          'Live Parking',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    const Text(
                      'Live bay status and parking areas configured by ParkUTeM Admin.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _buildError()
                    else ...[
                      _buildMap(),
                      const SizedBox(height: 16),
                      _buildSummary(),
                      const SizedBox(height: 18),
                      _buildZoneFilters(),
                      const SizedBox(height: 12),
                      _buildStatusFilters(),
                      const SizedBox(height: 22),
                      _buildListHeader(),
                      const SizedBox(height: 10),
                      _buildBayList(),
                    ],
                  ],
                ),
              ),
            ),
            AppBottomNavigation(currentIndex: 1, onTap: _navigateFromBottomBar),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_zones.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: AppTheme.muted, size: 34),
            SizedBox(height: 10),
            Text(
              'Parking map is not available right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'The live bay list below is still available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted, fontSize: 12.5),
            ),
          ],
        ),
      );
    }

    final markers = _zones.map((zone) {
      final selected = _selectedZone == zone.zoneCode;

      return Marker(
        point: LatLng(zone.latitude!, zone.longitude!),
        width: 54,
        height: 54,
        child: Semantics(
          button: true,
          label: '${zone.displayName}, Zone ${zone.zoneCode}',
          child: GestureDetector(
            onTap: () => _selectZone(zone.zoneCode),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryBlue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : AppTheme.primaryBlue,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_parking_rounded,
                color: selected ? Colors.white : AppTheme.primaryBlue,
                size: 25,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 245,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4F8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _campusCenter,
                initialZoom: 15.8,
                minZoom: 14,
                maxZoom: 19,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.parkutem_app',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Material(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _selectZone('All'),
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Text(
                      'Show all',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: Colors.white.withValues(alpha: 0.88),
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(color: AppTheme.muted, fontSize: 8.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Available',
              value: '$_availableCount',
              color: const Color(0xFF067647),
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              label: 'Occupied',
              value: '$_occupiedCount',
              color: const Color(0xFFB42318),
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              label: 'Reserved',
              value: '$_reservedCount',
              color: const Color(0xFFB54708),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All areas',
            selected: _selectedZone == 'All',
            onTap: () => _selectZone('All'),
          ),
          for (final code in _zoneCodes) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Zone $code',
              selected: _selectedZone == code,
              onTap: () => _selectZone(code),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final entries = <(String, ParkingBayStatus?)>[
      ('All status', null),
      ('Available', ParkingBayStatus.available),
      ('Occupied', ParkingBayStatus.occupied),
      ('Reserved', ParkingBayStatus.reserved),
      ('Maintenance', ParkingBayStatus.maintenance),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _FilterChip(
            label: entry.$1,
            selected: _selectedStatus == entry.$2,
            compact: true,
            onTap: () => setState(() => _selectedStatus = entry.$2),
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    final timestamp = _lastLoadedAt;
    final time = timestamp == null
        ? ''
        : '${timestamp.hour.toString().padLeft(2, '0')}:'
              '${timestamp.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: Text(
            '${_filteredBays.length} bays',
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (time.isNotEmpty)
          Text(
            'Updated $time',
            style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
          ),
      ],
    );
  }

  Widget _buildBayList() {
    final bays = _filteredBays;

    if (bays.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Text(
          'No parking bays match these filters.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.muted),
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < bays.length; index++) ...[
          _BayRow(
            bay: bays[index],
            onReserve: bays[index].status == ParkingBayStatus.available
                ? () => Navigator.of(
                    context,
                  ).pushNamed('/reserve', arguments: bays[index])
                : null,
            onTap: () => _showBayDetails(bays[index]),
          ),
          if (index != bays.length - 1) const SizedBox(height: 9),
        ],
      ],
    );
  }

  Future<void> _showBayDetails(ParkingBay bay) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bay.bayNumber,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(bay.zone, style: const TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 18),
              _DetailLine(label: 'Status', value: bay.status.label),
              if (bay.hasLiveSensor)
                _DetailLine(label: 'Sensor', value: bay.sensorStatus),
              if ((bay.currentPlateNumber ?? '').trim().isNotEmpty)
                _DetailLine(
                  label: 'Current vehicle',
                  value: bay.currentPlateNumber!,
                ),
              const SizedBox(height: 18),
              if (bay.status == ParkingBayStatus.available)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(
                        this.context,
                      ).pushNamed('/reserve', arguments: bay);
                    },
                    child: const Text('Reserve this bay'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppTheme.muted, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Unable to load live parking.',
            style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: _load, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppTheme.border);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryBlue : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 9 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppTheme.primaryBlue : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.ink,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _BayRow extends StatelessWidget {
  final ParkingBay bay;
  final VoidCallback onTap;
  final VoidCallback? onReserve;

  const _BayRow({
    required this.bay,
    required this.onTap,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (bay.status) {
      ParkingBayStatus.available => const Color(0xFF067647),
      ParkingBayStatus.occupied => const Color(0xFFB42318),
      ParkingBayStatus.reserved => const Color(0xFFB54708),
      ParkingBayStatus.maintenance => AppTheme.muted,
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bay.bayNumber,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bay.zone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  bay.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onReserve != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onReserve,
                  tooltip: 'Reserve',
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppTheme.muted)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
