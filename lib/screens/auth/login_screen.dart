// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/university_user.dart';
import '../../widgets/app_background.dart';

// =====================================================
// LOGIN SCREEN
// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// =====================================================
// LOGIN SCREEN STATE
// =====================================================

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // HANDLE LOGIN
  // =====================================================

  Future<void> _handleLogin() async {
    final String identifier = _idController.text.trim();
    final String password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your Student/Staff ID or email and password.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UniversityUser universityUser = await _authService
          .signInWithUniversityId(universityId: identifier, password: password);

      debugPrint(
        'Login success: ${universityUser.universityId} | mustChangePassword: ${universityUser.mustChangePassword}',
      );

      await PushNotificationService.saveCurrentToken();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();

      if (universityUser.mustChangePassword) {
        _showMessage(
          'Temporary password detected. Please change your password.',
        );

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/security', (route) => false);

        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on AuthException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 42),
                  _buildLogoSection(),
                  const SizedBox(height: 34),
                  _buildWelcomeText(),
                  const SizedBox(height: 30),
                  _buildLoginForm(),
                  const SizedBox(height: 22),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildUniversityNote(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // LOGO SECTION
  // =====================================================

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryCyan.withValues(alpha: 0.28),
                blurRadius: 42,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(AppAssets.parkutemLogo, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 22),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Park',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'UTeM',
                style: TextStyle(
                  color: AppTheme.primaryCyan,
                  fontSize: 39,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Smart Campus Parking',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // WELCOME TEXT
  // =====================================================

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login using your university ID or email',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOGIN FORM
  // =====================================================

  Widget _buildLoginForm() {
    return Column(
      children: [
        _LoginInputField(
          controller: _idController,
          hintText: 'Student ID, Staff ID, or Email',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.text,
          enabled: !_isLoading,
          onSubmitted: (_) {
            FocusScope.of(context).nextFocus();
          },
        ),
        const SizedBox(height: 14),
        _LoginInputField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: !_isPasswordVisible,
          enabled: !_isLoading,
          onSubmitted: (_) => _handleLogin(),
          suffixIcon: IconButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withValues(alpha: 0.55),
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildLoginOptions(),
      ],
    );
  }

  // =====================================================
  // LOGIN OPTIONS
  // =====================================================

  Widget _buildLoginOptions() {
    return Row(
      children: [
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: _rememberMe ? AppTheme.primaryCyan : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _rememberMe
                    ? AppTheme.primaryCyan
                    : Colors.white.withValues(alpha: 0.35),
                width: 1.4,
              ),
              boxShadow: _rememberMe
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ]
                  : [],
            ),
            child: _rememberMe
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'Remember me',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  _showMessage(
                    'Please contact admin to reset your temporary password.',
                  );
                },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppTheme.primaryCyan,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOGIN BUTTON
  // =====================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  // =====================================================
  // UNIVERSITY NOTE
  // =====================================================

  Widget _buildUniversityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppTheme.primaryCyan,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only preloaded UTeM student/staff accounts can access this app. '
              'Use your matric/staff ID or email with the temporary password provided by admin.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 12.5,
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
// LOGIN INPUT FIELD
// =====================================================

class _LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final void Function(String)? onSubmitted;

  const _LoginInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        textInputAction: obscureText
            ? TextInputAction.done
            : TextInputAction.next,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: AppTheme.primaryCyan,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.58),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
