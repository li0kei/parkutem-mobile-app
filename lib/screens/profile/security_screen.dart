// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/university_user.dart';

// =====================================================
// SECURITY SCREEN
// =====================================================

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

// =====================================================
// SECURITY SCREEN STATE
// =====================================================

class _SecurityScreenState extends State<SecurityScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  UniversityUser? _currentUser;

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD CURRENT USER
  // =====================================================

  Future<void> _loadCurrentUser() async {
    try {
      final UniversityUser? user = await _authService
          .getCurrentUniversityUser();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<void> _handleChangePassword() async {
    final String currentPassword = _currentPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showMessage('Current password is required.', isError: true);
      return;
    }

    if (newPassword.length < 8) {
      _showMessage(
        'New password must be at least 8 characters.',
        isError: true,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'New password and confirmation do not match.',
        isError: true,
      );
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage(
        'New password cannot be the same as current password.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) {
        return;
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showMessage('Password changed successfully.');

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on AuthException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =====================================================
  // SIGN OUT
  // =====================================================

  Future<void> _handleSignOut() async {
    await _authService.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : AppTheme.darkCard,
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _SectionCard(
                title: 'No Active Session',
                child: Column(
                  children: [
                    const Text(
                      'Please login again to manage your security settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: _PrimaryButton(
                        label: 'Back to Login',
                        icon: Icons.login_rounded,
                        isLoading: false,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final bool mustChangePassword = _currentUser!.mustChangePassword;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, mustChangePassword),
              const SizedBox(height: 24),
              _buildSecurityStatus(mustChangePassword),
              const SizedBox(height: 24),
              _buildChangePasswordCard(mustChangePassword),
              const SizedBox(height: 24),
              _buildSecurityInfo(),
              const SizedBox(height: 24),
              _buildSecurityActions(context, mustChangePassword),
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

  Widget _buildHeader(BuildContext context, bool mustChangePassword) {
    return Row(
      children: [
        _BackButton(
          onTap: mustChangePassword
              ? _handleSignOut
              : () {
                  Navigator.of(context).pop();
                },
          icon: mustChangePassword
              ? Icons.logout_rounded
              : Icons.arrow_back_rounded,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mustChangePassword
                    ? 'Change your temporary password'
                    : 'University-managed authentication',
                style: const TextStyle(
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

  Widget _buildSecurityStatus(bool mustChangePassword) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: mustChangePassword
              ? const [Color(0xFF92400E), Color(0xFFB45309)]
              : const [Color(0xFF0F172A), Color(0xFF111D35)],
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
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              mustChangePassword
                  ? Icons.key_rounded
                  : Icons.verified_user_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mustChangePassword
                      ? 'Temporary Password Active'
                      : 'Account Secured',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  mustChangePassword
                      ? 'Please change your temporary password before continuing to use ParkUTeM.'
                      : 'Only preloaded UTeM student/staff accounts can access ParkUTeM.',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
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
  // CHANGE PASSWORD CARD
  // =====================================================

  Widget _buildChangePasswordCard(bool mustChangePassword) {
    return _SectionCard(
      title: mustChangePassword ? 'Required Action' : 'Change Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mustChangePassword) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are using a temporary password from admin. Create a new password to continue.',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _PasswordField(
            controller: _currentPasswordController,
            label: 'Current Password',
            hintText: 'Enter current / temporary password',
            isVisible: _isCurrentPasswordVisible,
            enabled: !_isSubmitting,
            onToggleVisibility: () {
              setState(() {
                _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            hintText: 'At least 8 characters',
            isVisible: _isNewPasswordVisible,
            enabled: !_isSubmitting,
            onToggleVisibility: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            hintText: 'Re-enter new password',
            isVisible: _isConfirmPasswordVisible,
            enabled: !_isSubmitting,
            onSubmitted: (_) => _handleChangePassword(),
            onToggleVisibility: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 18),
          _PrimaryButton(
            label: mustChangePassword
                ? 'Change Password & Continue'
                : 'Update Password',
            icon: Icons.lock_reset_rounded,
            isLoading: _isSubmitting,
            onTap: _isSubmitting ? null : _handleChangePassword,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY INFO
  // =====================================================

  Widget _buildSecurityInfo() {
    final UniversityUser user = _currentUser!;

    return _SectionCard(
      title: 'Login Information',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_rounded,
            label: 'Account',
            value: '${user.fullName} • ${user.universityId}',
          ),
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'Login Method',
            value: 'Student/Staff ID or Email + Password',
          ),
          _InfoRow(
            icon: Icons.lock_rounded,
            label: 'Password Control',
            value: 'Managed by ParkUTeM encrypted password hash',
          ),
          _InfoRow(
            icon: Icons.storage_rounded,
            label: 'Account Source',
            value: 'Supabase university_users record',
          ),
          _InfoRow(
            icon: Icons.verified_rounded,
            label: 'Access Policy',
            value: user.accountStatus == 'active'
                ? 'Active account'
                : 'Account status: ${user.accountStatus}',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY ACTIONS
  // =====================================================

  Widget _buildSecurityActions(BuildContext context, bool mustChangePassword) {
    return _SectionCard(
      title: 'Security Actions',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.devices_rounded,
            title: 'Device Sessions',
            subtitle: 'View active device sessions placeholder',
            onTap: mustChangePassword
                ? () {
                    _showMessage(
                      'Please change your temporary password first.',
                      isError: true,
                    );
                  }
                : () {
                    Navigator.of(context).pushNamed('/device-sessions');
                  },
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'Logout from this device',
            showDivider: false,
            onTap: _handleSignOut,
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
            icon: Icons.key_rounded,
            title: 'Temporary Password',
            description:
                'New users receive a temporary password from admin and must change it after first login.',
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
  final IconData icon;

  const _BackButton({required this.onTap, required this.icon});

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
            border: Border.all(color: const Color(0xFFE8EEF7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF0F172A), size: 24),
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

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF7)),
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
// PASSWORD FIELD
// =====================================================

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isVisible;
  final bool enabled;
  final VoidCallback onToggleVisibility;
  final void Function(String)? onSubmitted;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.isVisible,
    required this.enabled,
    required this.onToggleVisibility,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: !isVisible,
          onSubmitted: onSubmitted,
          textInputAction: onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF64748B),
            ),
            suffixIcon: IconButton(
              onPressed: enabled ? onToggleVisibility : null,
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppTheme.primaryCyan,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// PRIMARY BUTTON
// =====================================================

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 9),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
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
            _IconBox(icon: icon, color: AppTheme.primaryBlue),
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
          const Divider(height: 1, color: Color(0xFFE8EEF7)),
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
                  _IconBox(icon: icon, color: AppTheme.primaryBlue),
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
          const Divider(height: 1, color: Color(0xFFE8EEF7)),
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
            _IconBox(icon: icon, color: AppTheme.primaryBlue),
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
          const Divider(height: 1, color: Color(0xFFE8EEF7)),
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

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
