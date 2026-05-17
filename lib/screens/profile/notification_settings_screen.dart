import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// =====================================================
// NOTIFICATION SETTINGS SCREEN
// =====================================================

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _parkingAlerts = true;
  bool _reservationReminders = true;
  bool _paymentAlerts = true;
  bool _anprAlerts = true;
  bool _soundEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSettingsCard(),
            ],
          ),
        ),
      ),
    );
  }

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
                'Notification Settings',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage parking alerts and reminders',
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
    );
  }

  Widget _buildInfoCard() {
    return _InfoCard(
      icon: Icons.notifications_active_rounded,
      title: 'Stay Updated',
      description:
          'Receive important alerts about reservation status, ANPR detection, wallet deduction, and parking reminders.',
    );
  }

  Widget _buildSettingsCard() {
    return _SectionCard(
      title: 'Notification Preferences',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.local_parking_rounded,
            title: 'Parking Alerts',
            subtitle: 'Notify when parking availability changes',
            value: _parkingAlerts,
            onChanged: (value) => setState(() => _parkingAlerts = value),
          ),
          _SwitchTile(
            icon: Icons.alarm_rounded,
            title: 'Reservation Reminders',
            subtitle: 'Remind before reservation starts or ends',
            value: _reservationReminders,
            onChanged: (value) =>
                setState(() => _reservationReminders = value),
          ),
          _SwitchTile(
            icon: Icons.payments_rounded,
            title: 'Payment Alerts',
            subtitle: 'Notify wallet top up and deductions',
            value: _paymentAlerts,
            onChanged: (value) => setState(() => _paymentAlerts = value),
          ),
          _SwitchTile(
            icon: Icons.camera_alt_rounded,
            title: 'ANPR Alerts',
            subtitle: 'Notify vehicle entry and exit detection',
            value: _anprAlerts,
            onChanged: (value) => setState(() => _anprAlerts = value),
          ),
          _SwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'Notification Sound',
            subtitle: 'Play sound when alert is received',
            value: _soundEnabled,
            showDivider: false,
            onChanged: (value) => setState(() => _soundEnabled = value),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REUSABLE WIDGETS
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.3,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
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
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool showDivider;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: AppTheme.primaryBlue,
              onChanged: onChanged,
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 13),
          const Divider(height: 1, color: Color(0xFFE8EEF7)),
          const SizedBox(height: 13),
        ],
      ],
    );
  }
}