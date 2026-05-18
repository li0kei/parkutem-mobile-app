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

// =====================================================
// NOTIFICATION SETTINGS SCREEN STATE
// =====================================================

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;

  bool _reservationReminders = true;
  bool _thirtyMinuteReminder = true;
  bool _fifteenMinuteReminder = true;

  bool _walletAlerts = true;
  bool _lowBalanceAlerts = true;
  bool _paymentDeductionAlerts = true;

  bool _anprAlerts = true;
  bool _entryExitAlerts = true;
  bool _accessDeniedAlerts = true;

  bool _supportIssueUpdates = true;
  bool _soundEnabled = false;
  bool _vibrationEnabled = true;

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
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildMasterCard(),
              const SizedBox(height: 20),
              _buildReservationCard(),
              const SizedBox(height: 20),
              _buildWalletCard(),
              const SizedBox(height: 20),
              _buildAnprCard(),
              const SizedBox(height: 20),
              _buildSupportCard(),
              const SizedBox(height: 20),
              _buildDeviceCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
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

  // =====================================================
  // INFO CARD
  // =====================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Updated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Receive reminders for reservations, wallet payments, ANPR entry/exit, and support issue updates.',
                  style: TextStyle(
                    color: Color(0xFFDCEBFF),
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
  // MASTER CARD
  // =====================================================

  Widget _buildMasterCard() {
    return _SectionCard(
      title: 'General',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.notifications_rounded,
            title: 'Enable Notifications',
            subtitle: 'Allow ParkUTeM to send important alerts',
            value: _allNotifications,
            onChanged: (value) {
              setState(() {
                _allNotifications = value;
              });
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RESERVATION CARD
  // =====================================================

  Widget _buildReservationCard() {
    return _SectionCard(
      title: 'Reservation Reminders',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.event_available_rounded,
            title: 'Reservation Updates',
            subtitle: 'Notify when reservation is created or updated',
            value: _reservationReminders,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _reservationReminders = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.timer_rounded,
            title: '30 Minutes Before Reservation',
            subtitle: 'Reminder before your reserved time starts',
            value: _thirtyMinuteReminder,
            enabled: _allNotifications && _reservationReminders,
            onChanged: (value) {
              setState(() {
                _thirtyMinuteReminder = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.hourglass_bottom_rounded,
            title: '15 Minutes Before Parking Ends',
            subtitle: 'Reminder before your selected parking duration ends',
            value: _fifteenMinuteReminder,
            enabled: _allNotifications && _reservationReminders,
            onChanged: (value) {
              setState(() {
                _fifteenMinuteReminder = value;
              });
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WALLET CARD
  // =====================================================

  Widget _buildWalletCard() {
    return _SectionCard(
      title: 'Wallet & Payment',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallet Alerts',
            subtitle: 'Notify wallet top up and balance changes',
            value: _walletAlerts,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _walletAlerts = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.warning_amber_rounded,
            title: 'Low Balance Alert',
            subtitle: 'Notify when wallet balance is low',
            value: _lowBalanceAlerts,
            enabled: _allNotifications && _walletAlerts,
            onChanged: (value) {
              setState(() {
                _lowBalanceAlerts = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.payments_rounded,
            title: 'Payment Deduction Alert',
            subtitle: 'Notify after reservation or parking fee is deducted',
            value: _paymentDeductionAlerts,
            enabled: _allNotifications && _walletAlerts,
            onChanged: (value) {
              setState(() {
                _paymentDeductionAlerts = value;
              });
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ANPR CARD
  // =====================================================

  Widget _buildAnprCard() {
    return _SectionCard(
      title: 'ANPR Access Alerts',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.camera_alt_rounded,
            title: 'ANPR Detection Alerts',
            subtitle: 'Notify when your vehicle plate is detected',
            value: _anprAlerts,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _anprAlerts = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.login_rounded,
            title: 'Entry / Exit Alerts',
            subtitle: 'Notify when ANPR records your vehicle entry or exit',
            value: _entryExitAlerts,
            enabled: _allNotifications && _anprAlerts,
            onChanged: (value) {
              setState(() {
                _entryExitAlerts = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.block_rounded,
            title: 'Access Denied Alerts',
            subtitle: 'Notify when ANPR rejects or flags your plate',
            value: _accessDeniedAlerts,
            enabled: _allNotifications && _anprAlerts,
            onChanged: (value) {
              setState(() {
                _accessDeniedAlerts = value;
              });
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SUPPORT CARD
  // =====================================================

  Widget _buildSupportCard() {
    return _SectionCard(
      title: 'Support & Issue Updates',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.support_agent_rounded,
            title: 'Support Issue Updates',
            subtitle: 'Notify when admin updates or resolves your issue',
            value: _supportIssueUpdates,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _supportIssueUpdates = value;
              });
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DEVICE CARD
  // =====================================================

  Widget _buildDeviceCard() {
    return _SectionCard(
      title: 'Device Preferences',
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'Notification Sound',
            subtitle: 'Play sound when an alert is received',
            value: _soundEnabled,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),
          _SwitchTile(
            icon: Icons.vibration_rounded,
            title: 'Vibration',
            subtitle: 'Vibrate when an important alert is received',
            value: _vibrationEnabled,
            enabled: _allNotifications,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
            showDivider: false,
          ),
          const SizedBox(height: 16),
          _FirebaseNote(),
        ],
      ),
    );
  }

  // =====================================================
  // SAVE BUTTON
  // =====================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save Preferences'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
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

  void _saveSettings() {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Notification preferences saved for this prototype.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryBlue,
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

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final bool showDivider;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        enabled ? AppTheme.primaryBlue : const Color(0xFF94A3B8);

    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: activeColor,
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
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: AppTheme.primaryBlue,
                onChanged: enabled ? onChanged : null,
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
      ),
    );
  }
}

class _FirebaseNote extends StatelessWidget {
  const _FirebaseNote();

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
            Icons.cloud_queue_rounded,
            color: AppTheme.primaryBlue,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Firebase Cloud Messaging can be connected later for real push notifications. '
              'For this prototype, these preferences show the planned notification flow.',
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