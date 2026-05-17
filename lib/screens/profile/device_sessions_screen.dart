import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// =====================================================
// DEVICE SESSIONS SCREEN
// =====================================================

class DeviceSessionsScreen extends StatefulWidget {
  const DeviceSessionsScreen({super.key});

  @override
  State<DeviceSessionsScreen> createState() => _DeviceSessionsScreenState();
}

class _DeviceSessionsScreenState extends State<DeviceSessionsScreen> {
  List<_DeviceSession> _sessions = const [
    _DeviceSession(
      deviceName: 'Current Android Device',
      location: 'Melaka, Malaysia',
      lastActive: 'Active now',
      isCurrent: true,
      icon: Icons.phone_android_rounded,
    ),
    _DeviceSession(
      deviceName: 'Chrome on Windows',
      location: 'Sungai Way, Malaysia',
      lastActive: 'Today, 4:42 PM',
      isCurrent: false,
      icon: Icons.desktop_windows_rounded,
    ),
    _DeviceSession(
      deviceName: 'Android Emulator',
      location: 'Development Device',
      lastActive: 'Yesterday, 9:18 PM',
      isCurrent: false,
      icon: Icons.developer_mode_rounded,
    ),
  ];

  int get _otherDeviceCount {
    return _sessions.where((session) => !session.isCurrent).length;
  }

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
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildSessionsList(),
              const SizedBox(height: 24),
              _buildLogoutOtherDevicesButton(),
            ],
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
                'Device Sessions',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage active login sessions',
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

  // =====================================================
  // STATUS CARD
  // =====================================================

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF111D35),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
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
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.devices_rounded,
              color: AppTheme.primaryCyan,
              size: 33,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _otherDeviceCount == 0
                      ? 'Only your current device is logged in.'
                      : '$_otherDeviceCount other device(s) are logged in.',
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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
  // SESSIONS LIST
  // =====================================================

  Widget _buildSessionsList() {
    return _SectionCard(
      title: 'Logged-in Devices',
      child: Column(
        children: _sessions.map((session) {
          final bool isLast = session == _sessions.last;

          return _DeviceSessionTile(
            session: session,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  // =====================================================
  // LOGOUT OTHER DEVICES BUTTON
  // =====================================================

  Widget _buildLogoutOtherDevicesButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _otherDeviceCount == 0 ? null : _logoutOtherDevices,
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          _otherDeviceCount == 0
              ? 'No Other Devices'
              : 'Logout Other Devices',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          disabledForegroundColor: const Color(0xFF94A3B8),
          side: BorderSide(
            color: _otherDeviceCount == 0
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFFECACA),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void _logoutOtherDevices() {
    setState(() {
      _sessions = _sessions.where((session) => session.isCurrent).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Other devices have been logged out.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0F172A),
      ),
    );
  }
}

// =====================================================
// DEVICE SESSION MODEL
// =====================================================

class _DeviceSession {
  final String deviceName;
  final String location;
  final String lastActive;
  final bool isCurrent;
  final IconData icon;

  const _DeviceSession({
    required this.deviceName,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
    required this.icon,
  });
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

class _DeviceSessionTile extends StatelessWidget {
  final _DeviceSession session;
  final bool showDivider;

  const _DeviceSessionTile({
    required this.session,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        session.isCurrent ? const Color(0xFF22C55E) : AppTheme.primaryBlue;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                session.icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.deviceName,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    session.location,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    session.lastActive,
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (session.isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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