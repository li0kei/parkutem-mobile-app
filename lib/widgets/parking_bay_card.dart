import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/parking_bay.dart';

// =====================================================
// PARKING BAY CARD
// =====================================================

class ParkingBayCard extends StatelessWidget {
  final ParkingBay bay;
  final VoidCallback? onReserve;

  const ParkingBayCard({
    super.key,
    required this.bay,
    this.onReserve,
  });

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color get statusColor {
  switch (bay.status) {
    case ParkingBayStatus.available:
      return const Color(0xFF22C55E);
    case ParkingBayStatus.occupied:
      return const Color(0xFFEF4444);
    case ParkingBayStatus.reserved:
      return const Color(0xFFF59E0B);
    case ParkingBayStatus.maintenance:
      return const Color(0xFF64748B);
  }
}

  // =====================================================
  // STATUS ICON
  // =====================================================

IconData get statusIcon {
  switch (bay.status) {
    case ParkingBayStatus.available:
      return Icons.check_circle_rounded;
    case ParkingBayStatus.occupied:
      return Icons.directions_car_filled_rounded;
    case ParkingBayStatus.reserved:
      return Icons.event_busy_rounded;
    case ParkingBayStatus.maintenance:
      return Icons.build_circle_rounded;
  }
}

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool canReserve = bay.status == ParkingBayStatus.available;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          // =====================================================
          // TOP ROW
          // =====================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 23,
                ),
              ),
              const Spacer(),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =====================================================
          // BAY NUMBER
          // =====================================================

          Text(
            bay.bayNumber,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            bay.zone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          // =====================================================
          // STATUS BADGE
          // =====================================================

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              bay.status.label,
              style: TextStyle(
                color: statusColor,
                fontSize: 11.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const Spacer(),

          // =====================================================
          // RESERVE BUTTON
          // =====================================================

          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: canReserve ? onReserve : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    canReserve ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                foregroundColor:
                    canReserve ? Colors.white : const Color(0xFF94A3B8),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                canReserve ? 'Reserve' : 'Unavailable',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}