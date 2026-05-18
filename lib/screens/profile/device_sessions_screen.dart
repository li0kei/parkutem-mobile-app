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

// =====================================================
// DEVICE SESSIONS SCREEN STATE
// =====================================================

class _DeviceSessionsScreenState extends State<DeviceSessionsScreen> {
  bool _isSessionActive = true;

  // =====================================================
  // BUILD
  // =====================================================

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
              _buildCurrentSessionCard(),
              const SizedBox(height: 24),
              _buildSessionManagementCard(),
              const SizedBox(height: 24),
              _buildSecurityNote(),
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
        _BackButton(
          onTap: () => Navigator.of(context).pop(),
        ),
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
                'View current login session',
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
                Text(
                  _isSessionActive ? 'Session Active' : 'Session Ended',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isSessionActive
                      ? 'This device is currently signed in with Supabase Auth.'
                      : 'This device session has been marked as ended for prototype display.',
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
  // CURRENT SESSION CARD
  // =====================================================

  Widget _buildCurrentSessionCard() {
    return const _SectionCard(
      title: 'Current Device',
      child: Column(
        children: [
          _DeviceSessionTile(
            icon: Icons.phone_android_rounded,
            deviceName: 'Android Device',
            sessionLabel: 'This device',
            status: 'Active now',
            detail: 'Signed in through ParkUTeM mobile app',
            color: Color(0xFF22C55E),
            showCurrentBadge: true,
          ),
          SizedBox(height: 16),
          _InfoNote(
            icon: Icons.security_rounded,
            title: 'Session Source',
            description:
                'ParkUTeM uses Supabase Auth session storage. The user stays signed in until logout or session expiry.',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SESSION MANAGEMENT CARD
  // =====================================================

  Widget _buildSessionManagementCard() {
    return _SectionCard(
      title: 'Session Management',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.refresh_rounded,
            title: 'Refresh Session Status',
            subtitle: 'Check current session state',
            onTap: _refreshSessionStatus,
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            title: 'Logout Other Devices',
            subtitle: 'Available later with full session management',
            onTap: _showFutureFeatureMessage,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY NOTE
  // =====================================================

  Widget _buildSecurityNote() {
    return const _SectionCard(
      title: 'Security Notes',
      child: Column(
        children: [
          _InfoNote(
            icon: Icons.verified_user_rounded,
            title: 'UTeM Account Only',
            description:
                'Only preloaded student and staff accounts from university_users can access this mobile app.',
          ),
          SizedBox(height: 14),
          _InfoNote(
            icon: Icons.lock_rounded,
            title: 'Password Handling',
            description:
                'Password verification is handled through Supabase Auth using the email mapped from Student/Staff ID.',
          ),
          SizedBox(height: 14),
          _InfoNote(
            icon: Icons.devices_other_rounded,
            title: 'Future Enhancement',
            description:
                'Full multi-device session listing can be added later when device token tracking or Firebase integration is enabled.',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACTIONS
  // =====================================================

  void _refreshSessionStatus() {
    setState(() {
      _isSessionActive = true;
    });

    _showMessage('Session status refreshed.');
  }

  void _showFutureFeatureMessage() {
    _showMessage(
      'Multi-device logout will be connected later with full session tracking.',
    );
  }

  void _showMessage(String message) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE8EEF7),
        ),
      ),
      content: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// =====================================================
// BACK BUTTON
// =====================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
      ),
    );
  }
}

// =====================================================
// SECTION CARD
// =====================================================

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
            color: Colors.black.withValues(alpha: 0.045),
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

// =====================================================
// DEVICE SESSION TILE
// =====================================================

class _DeviceSessionTile extends StatelessWidget {
  final IconData icon;
  final String deviceName;
  final String sessionLabel;
  final String status;
  final String detail;
  final Color color;
  final bool showCurrentBadge;

  const _DeviceSessionTile({
    required this.icon,
    required this.deviceName,
    required this.sessionLabel,
    required this.status,
    required this.detail,
    required this.color,
    this.showCurrentBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(
          icon: icon,
          color: color,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      deviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (showCurrentBadge) ...[
                    const SizedBox(width: 8),
                    _SmallBadge(
                      label: 'Current',
                      color: color,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                sessionLabel,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// ACTION TILE
// =====================================================

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _IconBox(
                    icon: icon,
                    color: AppTheme.primaryBlue,
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
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFE8EEF7),
          ),
          const SizedBox(height: 13),
        ],
      ],
    );
  }
}

// =====================================================
// INFO NOTE
// =====================================================

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoNote({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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

// =====================================================
// ICON BOX
// =====================================================

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }
}

// =====================================================
// SMALL BADGE
// =====================================================

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}