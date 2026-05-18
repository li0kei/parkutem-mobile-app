import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// =====================================================
// SECURITY SCREEN
// =====================================================

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
              _buildSecurityStatus(),
              const SizedBox(height: 24),
              _buildSecurityInfo(),
              const SizedBox(height: 24),
              _buildSecurityActions(context),
              const SizedBox(height: 24),
              _buildSecurityTips(),
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
                'Security',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'University-managed authentication',
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
  // SECURITY STATUS
  // =====================================================

  Widget _buildSecurityStatus() {
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
              Icons.verified_user_rounded,
              color: AppTheme.primaryCyan,
              size: 33,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Secured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Only preloaded UTeM student/staff accounts can access ParkUTeM.',
                  style: TextStyle(
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
  // SECURITY INFO
  // =====================================================

  Widget _buildSecurityInfo() {
    return const _SectionCard(
      title: 'Login Information',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'Login Method',
            value: 'Student/Staff ID + Password',
          ),
          _InfoRow(
            icon: Icons.lock_rounded,
            label: 'Password Control',
            value: 'Managed by Supabase Auth / university account',
          ),
          _InfoRow(
            icon: Icons.storage_rounded,
            label: 'Account Source',
            value: 'Supabase university_users record',
          ),
          _InfoRow(
            icon: Icons.verified_rounded,
            label: 'Access Policy',
            value: 'Only preloaded UTeM accounts can login',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY ACTIONS
  // =====================================================

  Widget _buildSecurityActions(BuildContext context) {
    return _SectionCard(
      title: 'Security Actions',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.open_in_new_rounded,
            title: 'Open University Portal',
            subtitle: 'Password changes are handled outside ParkUTeM',
            onTap: () {
              Navigator.of(context).pushNamed('/university-portal');
            },
          ),
          _ActionTile(
            icon: Icons.devices_rounded,
            title: 'Device Sessions',
            subtitle: 'View active device sessions placeholder',
            showDivider: false,
            onTap: () {
              Navigator.of(context).pushNamed('/device-sessions');
            },
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY TIPS
  // =====================================================

  Widget _buildSecurityTips() {
    return const _SectionCard(
      title: 'Security Notes',
      child: Column(
        children: [
          _TipTile(
            icon: Icons.shield_rounded,
            title: 'No Public Registration',
            description:
                'ParkUTeM mobile app only allows UTeM student/staff records that already exist in the database.',
          ),
          _TipTile(
            icon: Icons.alternate_email_rounded,
            title: 'ID-Based Login',
            description:
                'Students and staff login using their university ID, while Supabase Auth uses the registered email internally.',
          ),
          _TipTile(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin Controlled Access',
            description:
                'If an account is inactive or suspended, login will be blocked automatically.',
            showDivider: false,
          ),
        ],
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
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
// TIP TILE
// =====================================================

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool showDivider;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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