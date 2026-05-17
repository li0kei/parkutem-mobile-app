import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// =====================================================
// UNIVERSITY PORTAL SCREEN
// =====================================================

class UniversityPortalScreen extends StatelessWidget {
  const UniversityPortalScreen({super.key});

  static const String studentId = 'B032410123';
  static const String portalName = 'UTeM Student/Staff Portal';
  static const String portalUrl = 'smp.utem.edu.my';

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
              _buildPortalCard(),
              const SizedBox(height: 24),
              _buildLoginInfoCard(),
              const SizedBox(height: 24),
              _buildPolicyNote(),
              const SizedBox(height: 24),
              _buildOpenPortalButton(context),
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
                'University Portal',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Password and account access are managed here',
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
  // PORTAL CARD
  // =====================================================

  Widget _buildPortalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.24),
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portalName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  portalUrl,
                  style: TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
  // LOGIN INFO CARD
  // =====================================================

  Widget _buildLoginInfoCard() {
    return _SectionCard(
      title: 'Portal Login Details',
      child: const Column(
        children: [
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'University ID',
            value: studentId,
          ),
          _InfoRow(
            icon: Icons.lock_rounded,
            label: 'Password',
            value: 'Same as university portal password',
          ),
          _InfoRow(
            icon: Icons.verified_user_rounded,
            label: 'ParkUTeM Authentication',
            value: 'Uses university credential record',
            showDivider: false,
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
              'ParkUTeM does not manage password changes. Students and staff must update their password through the official university portal.',
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
  // OPEN PORTAL BUTTON
  // =====================================================

  Widget _buildOpenPortalButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('External portal link will be connected later.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF0F172A),
            ),
          );
        },
        icon: const Icon(Icons.open_in_browser_rounded),
        label: const Text('Open University Portal'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
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
                    ),
                  ),
                ],
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