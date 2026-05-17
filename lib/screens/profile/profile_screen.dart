// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/university_user_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/university_user.dart';
import '../../widgets/app_bottom_navigation.dart';

import '../../core/services/vehicle_service.dart';
import '../../models/vehicle_record.dart';

// =====================================================
// PROFILE SCREEN
// =====================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// =====================================================
// PROFILE SCREEN STATE
// =====================================================

class _ProfileScreenState extends State<ProfileScreen> {
 final UniversityUserService _universityUserService = UniversityUserService();
  final VehicleService _vehicleService = VehicleService();
  final AuthService _authService = AuthService();

  UniversityUser? _profile;
  VehicleRecord? _vehicle;
  bool _isLoading = true;
  String? _errorMessage;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =====================================================
  // LOAD PROFILE
  // =====================================================

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
     final UniversityUser? profile =
      await _universityUserService.getCurrentUserProfile();

    final VehicleRecord? vehicle = await _vehicleService.getPrimaryVehicle();

      await _universityUserService.updateLastActivity();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _profile = null;
          _errorMessage = 'Profile record was not found.';
          _isLoading = false;
        });
        return;
      }

     setState(() {
      _profile = profile;
      _vehicle = vehicle;
      _isLoading = false;
    });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // =====================================================
// OPEN VEHICLE REGISTRATION
// =====================================================

Future<void> _openVehicleRegistration() async {
  final Object? result = await Navigator.of(context).pushNamed(
    '/vehicle-registration',
  );

  if (!mounted) return;

  if (result == true) {
    await _loadProfile();
  }
}

  // =====================================================
  // HELPERS
  // =====================================================

  String _getInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'PU';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatRole(String role) {
    if (role.toLowerCase() == 'staff') {
      return 'UTeM Staff';
    }

    return 'UTeM Student';
  }

  String _formatStatusLabel(String value) {
  if (value.trim().isEmpty) return '-';

  return value
      .split('_')
      .map((part) {
        if (part.isEmpty) return part;
        return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
      })
      .join(' ');
}

  String _formatFacultyDepartment(UniversityUser profile) {
    if (profile.faculty == '-' && profile.department == '-') {
      return '-';
    }

    if (profile.department == '-') {
      return profile.faculty;
    }

    if (profile.faculty == '-') {
      return profile.department;
    }

    return '${profile.faculty} / ${profile.department}';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 22),
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else if (_profile != null) ...[
                        _buildProfileCard(_profile!),
                        const SizedBox(height: 24),
                        _buildVehicleStickerCard(_vehicle),
                        const SizedBox(height: 24),
                        _buildAccountInfoCard(_profile!),
                        const SizedBox(height: 24),
                        _buildMenuSection(context),
                        const SizedBox(height: 24),
                        _buildLogoutButton(context),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
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
        InkWell(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage university account and vehicle details',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _loadProfile,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load profile',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PROFILE CARD
  // =====================================================

  Widget _buildProfileCard(UniversityUser profile) {
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
            color: AppTheme.primaryBlue.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(profile.fullName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatRole(profile.role),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _LightProfileBadge(label: profile.universityId),
              _LightProfileBadge(
                label: profile.accountStatus.toUpperCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }

// =====================================================
// VEHICLE STICKER CARD
// =====================================================

Widget _buildVehicleStickerCard(VehicleRecord? vehicle) {
  if (vehicle == null) {
    return _SectionCard(
      title: 'Vehicle & Sticker',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppTheme.primaryBlue,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No vehicle registered',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vehicle data will appear after sticker registration',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                label: 'No Record',
                color: Color(0xFFF59E0B),
              ),
              _StatusBadge(
                label: 'ANPR Disabled',
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _InfoNote(
            text:
                'Register your vehicle first. Admin will review the sticker status and enable ANPR access after approval.',
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openVehicleRegistration,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Register Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final Color stickerColor = vehicle.stickerStatus == 'active'
      ? const Color(0xFF22C55E)
      : vehicle.stickerStatus == 'pending'
          ? const Color(0xFFF59E0B)
          : const Color(0xFFEF4444);

  final Color anprColor = vehicle.isAnprEnabled
      ? AppTheme.primaryCyan
      : const Color(0xFF94A3B8);

  return _SectionCard(
    title: 'Vehicle & Sticker',
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: AppTheme.primaryBlue,
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.plateNumber,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.vehicleDescription,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusBadge(
              label: _formatStatusLabel(vehicle.stickerStatus),
              color: stickerColor,
            ),
            _StatusBadge(
              label: 'ANPR ${_formatStatusLabel(vehicle.anprAccessStatus)}',
              color: anprColor,
            ),
            _StatusBadge(
              label: vehicle.userType.toUpperCase(),
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoNote(
          text: vehicle.isAnprEnabled
              ? 'ANPR access is enabled. Your plate can be verified automatically at entry and exit.'
              : 'ANPR access is not enabled yet. Please wait for admin approval or contact support.',
        ),
      ],
    ),
  );
}
  // =====================================================
  // ACCOUNT INFO CARD
  // =====================================================

  Widget _buildAccountInfoCard(UniversityUser profile) {
    return _SectionCard(
      title: 'University Account',
      child: Column(
        children: [
          _ProfileInfoRow(
            icon: Icons.badge_rounded,
            label: 'Student/Staff ID',
            value: profile.universityId,
          ),
          _ProfileInfoRow(
            icon: Icons.person_rounded,
            label: 'Full Name',
            value: profile.fullName,
          ),
          _ProfileInfoRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: profile.email,
          ),
          _ProfileInfoRow(
            icon: Icons.apartment_rounded,
            label: 'Faculty / Department',
            value: _formatFacultyDepartment(profile),
          ),
          _ProfileInfoRow(
            icon: Icons.verified_user_rounded,
            label: 'Account Status',
            value: profile.accountStatus.toUpperCase(),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MENU SECTION
  // =====================================================

  Widget _buildMenuSection(BuildContext context) {
    return _SectionCard(
      title: 'Account Settings',
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notification Settings',
            subtitle: 'Manage parking alerts and reminders',
            onTap: () => Navigator.of(context).pushNamed('/notification-settings'),
          ),
          _ProfileMenuTile(
            icon: Icons.lock_rounded,
            title: 'Security',
            subtitle: 'Password managed by university portal',
            onTap: () => Navigator.of(context).pushNamed('/security'),
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Parking History',
            subtitle: 'View entry, exit and reservation logs',
            onTap: () => Navigator.of(context).pushNamed('/parking-history'),
          ),
          _ProfileMenuTile(
            icon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'Contact parking administrator',
            onTap: () => Navigator.of(context).pushNamed('/help-support'),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LOGOUT BUTTON
  // =====================================================

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(
            color: Color(0xFFFECACA),
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

  // =====================================================
  // LOGOUT DIALOG
  // =====================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'You will return to the login screen.',
            style: TextStyle(
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final NavigatorState navigator = Navigator.of(context);

                Navigator.of(dialogContext).pop();

                await _authService.signOut();

                if (!mounted) return;

                navigator.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFEF4444),
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
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 4,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/parking');
          return;
        }

        if (index == 2) {
          Navigator.of(context).pushReplacementNamed('/reserve');
          return;
        }

        if (index == 3) {
          Navigator.of(context).pushReplacementNamed('/wallet');
          return;
        }

        if (index == 4) return;
      },
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
              letterSpacing: -0.3,
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
// LIGHT PROFILE BADGE
// =====================================================

class _LightProfileBadge extends StatelessWidget {
  final String label;

  const _LightProfileBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// =====================================================
// STATUS BADGE
// =====================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// =====================================================
// INFO NOTE
// =====================================================

class _InfoNote extends StatelessWidget {
  final String text;

  const _InfoNote({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
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
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryBlue,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF0F172A).withValues(alpha: 0.72),
                fontSize: 12.2,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PROFILE INFO ROW
// =====================================================

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _ProfileInfoRow({
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
// PROFILE MENU TILE
// =====================================================

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _ProfileMenuTile({
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ],
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