import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/university_user.dart';

class DeviceSessionsScreen extends StatefulWidget {
  const DeviceSessionsScreen({super.key});

  @override
  State<DeviceSessionsScreen> createState() => _DeviceSessionsScreenState();
}

class _DeviceSessionsScreenState extends State<DeviceSessionsScreen> {
  final AuthService _authService = AuthService();

  UniversityUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _authService.getCurrentUniversityUser();
    if (!mounted) return;

    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text(
          'Device Session',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const Text(
                  'ParkUTeM currently keeps the signed-in university account on this device.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.smartphone_rounded,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'This device',
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _user == null
                                  ? 'No active ParkUTeM session'
                                  : '${_user!.universityId} • Active session',
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Color(0xFF067647),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Text(
                    'Remote multi-device session control is not part of the current account model, '
                    'so this page only shows the session that the app can actually manage.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_user != null)
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out this device'),
                  ),
              ],
            ),
    );
  }
}
