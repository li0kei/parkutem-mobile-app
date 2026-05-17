import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

// =====================================================
// APP BOTTOM NAVIGATION
// =====================================================

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _BottomNavItem(
            icon: Icons.local_parking_rounded,
            label: 'Parking',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _BottomNavItem(
            icon: Icons.event_available_rounded,
            label: 'Reserve',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _BottomNavItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallet',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _BottomNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// BOTTOM NAV ITEM
// =====================================================

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppTheme.primaryBlue;
    final Color inactiveColor = const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 27,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}