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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait<dynamic>([
        _parkingService.getParkingBays(),
        _parkingService.getParkingZonesForMap(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _bays = results[0] as List<ParkingBay>;
        _zones = results[1] as List<ParkingZone>;
        _lastLoadedAt = DateTime.now();
        _isLoading = false;
        if (_selectedZone != 'All' && !_zoneCodes.contains(_selectedZone)) {
          _selectedZone = 'All';
        }
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

  List<String> get _zoneCodes {
    final values = <String>{};
    for (final bay in _bays) {
      final code = bay.zoneCode?.trim();
      if (code != null && code.isNotEmpty && code != '-') {
        values.add(code);
      }
    }
    return values.toList()..sort();
  }

  List<ParkingBay> get _filteredBays => _bays.where((bay) {
    final zoneMatch = _selectedZone == 'All' || bay.zoneCode == _selectedZone;
    final statusMatch =
        _selectedStatus == null || bay.status == _selectedStatus;
    return zoneMatch && statusMatch;
  }).toList();

  int get _availableCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.available).length;
  int get _occupiedCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.occupied).length;
  int get _reservedCount =>
      _bays.where((bay) => bay.status == ParkingBayStatus.reserved).length;

  void _navigateFromBottomBar(int index) {
    final routes = ['/home', '/parking', '/reserve', '/wallet', '/profile'];
    if (index == 1) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Parking',
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
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 120),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _buildError()
                    else ...[
                      _buildMap(),
                      const SizedBox(height: 18),
                      _buildSummary(),
                      const SizedBox(height: 18),
                      _buildFilterRow(),
                      const SizedBox(height: 20),
                      _buildListHeader(),
                      const SizedBox(height: 4),
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
        height: 190,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: AppTheme.muted, size: 32),
            SizedBox(height: 8),
            Text(
              'Map unavailable',
              style: TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Live bay status is still listed below.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final markers = _zones.map((zone) {
      final selected = _selectedZone == zone.zoneCode;
      return Marker(
        point: LatLng(zone.latitude!, zone.longitude!),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => setState(() => _selectedZone = zone.zoneCode),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryBlue : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBlue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.local_parking_rounded,
              color: selected ? Colors.white : AppTheme.primaryBlue,
              size: 23,
            ),
          ),
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 255,
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
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  onTap: () => setState(() => _selectedZone = 'All'),
                  borderRadius: BorderRadius.circular(9),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Text(
                      'Campus',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 7,
              bottom: 5,
              child: Container(
                color: Colors.white.withValues(alpha: 0.86),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(color: AppTheme.muted, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _Count(
            value: _availableCount,
            label: 'Available',
            color: const Color(0xFF067647),
          ),
        ),
        Expanded(
          child: _Count(
            value: _occupiedCount,
            label: 'Occupied',
            color: const Color(0xFFB42318),
          ),
        ),
        Expanded(
          child: _Count(
            value: _reservedCount,
            label: 'Reserved',
            color: const Color(0xFFB54708),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final zoneLabel = _selectedZone == 'All'
        ? 'All areas'
        : 'Zone $_selectedZone';
    final statusLabel = _selectedStatus?.label ?? 'All status';
    return Row(
      children: [
        Expanded(
          child: Text(
            '$zoneLabel · $statusLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12.5),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _showFilters,
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('Filter'),
        ),
      ],
    );
  }

  Future<void> _showFilters() async {
    String zone = _selectedZone;
    ParkingBayStatus? status = _selectedStatus;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter parking',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: zone,
                    decoration: const InputDecoration(labelText: 'Area'),
                    items: ['All', ..._zoneCodes]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value == 'All' ? 'All areas' : 'Zone $value',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setSheetState(() => zone = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<ParkingBayStatus?>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All status')),
                      DropdownMenuItem(
                        value: ParkingBayStatus.available,
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: ParkingBayStatus.occupied,
                        child: Text('Occupied'),
                      ),
                      DropdownMenuItem(
                        value: ParkingBayStatus.reserved,
                        child: Text('Reserved'),
                      ),
                      DropdownMenuItem(
                        value: ParkingBayStatus.maintenance,
                        child: Text('Maintenance'),
                      ),
                    ],
                    onChanged: (value) => setSheetState(() => status = value),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedZone = zone;
                          _selectedStatus = status;
                        });
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Apply filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListHeader() {
    final timestamp = _lastLoadedAt;
    final time = timestamp == null
        ? ''
        : '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_filteredBays.length} bays',
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 34),
        child: Center(
          child: Text(
            'No bays match this filter.',
            style: TextStyle(color: AppTheme.muted),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < bays.length; i++) ...[
          _BayRow(
            bay: bays[i],
            onTap: () => _showBayDetails(bays[i]),
            onReserve: bays[i].status == ParkingBayStatus.available
                ? () => Navigator.of(
                    context,
                  ).pushNamed('/reserve', arguments: bays[i])
                : null,
          ),
          if (i != bays.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }

  Future<void> _showBayDetails(ParkingBay bay) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
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
                fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _buildError() => Column(
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.cloud_off_outlined, color: AppTheme.muted, size: 34),
      const SizedBox(height: 10),
      const Text(
        'Unable to load live parking.',
        style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      OutlinedButton(onPressed: _load, child: const Text('Try again')),
    ],
  );
}

class _Count extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _Count({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '$value',
        style: TextStyle(
          color: color,
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
      ),
    ],
  );
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
    final color = switch (bay.status) {
      ParkingBayStatus.available => const Color(0xFF067647),
      ParkingBayStatus.occupied => const Color(0xFFB42318),
      ParkingBayStatus.reserved => const Color(0xFFB54708),
      ParkingBayStatus.maintenance => AppTheme.muted,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bay.bayNumber,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bay.zone,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              bay.status.label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (onReserve != null) ...[
              const SizedBox(width: 5),
              IconButton(
                onPressed: onReserve,
                tooltip: 'Reserve',
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ],
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
  Widget build(BuildContext context) => Padding(
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
