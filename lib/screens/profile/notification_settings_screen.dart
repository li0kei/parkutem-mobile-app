import 'package:flutter/material.dart';

import '../../core/services/notification_preference_service.dart';
import '../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationPreferenceService _service =
      NotificationPreferenceService();

  NotificationPreferences _preferences = NotificationPreferences.defaults;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await _service.load();
    if (!mounted) return;

    setState(() {
      _preferences = value;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _service.save(_preferences);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification preferences saved.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _update(NotificationPreferences value) {
    setState(() => _preferences = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const Text(
                  'Choose how ParkUTeM handles foreground alerts on this device.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _SettingSection(
                  title: 'General',
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Allow foreground alerts',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Master switch for alerts shown while ParkUTeM is open.',
                      ),
                      value: _preferences.enabled,
                      onChanged: (value) {
                        _update(_preferences.copyWith(enabled: value));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingSection(
                  title: 'Alert categories',
                  enabled: _preferences.enabled,
                  children: [
                    _PreferenceSwitch(
                      title: 'Reservations',
                      subtitle: 'Booking confirmations and reminders.',
                      value: _preferences.reservation,
                      onChanged: (value) =>
                          _update(_preferences.copyWith(reservation: value)),
                    ),

                    _PreferenceSwitch(
                      title: 'ANPR & parking',
                      subtitle: 'Entry, exit and access decision alerts.',
                      value: _preferences.anpr,
                      onChanged: (value) =>
                          _update(_preferences.copyWith(anpr: value)),
                    ),
                    _PreferenceSwitch(
                      title: 'Support',
                      subtitle: 'Updates to issues submitted to ParkUTeM.',
                      value: _preferences.support,
                      onChanged: (value) =>
                          _update(_preferences.copyWith(support: value)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingSection(
                  title: 'Device behaviour',
                  enabled: _preferences.enabled,
                  children: [
                    _PreferenceSwitch(
                      title: 'Sound',
                      subtitle: 'Play a sound for foreground alerts.',
                      value: _preferences.sound,
                      onChanged: (value) =>
                          _update(_preferences.copyWith(sound: value)),
                    ),
                    _PreferenceSwitch(
                      title: 'Vibration',
                      subtitle: 'Vibrate for foreground alerts when supported.',
                      value: _preferences.vibration,
                      onChanged: (value) =>
                          _update(_preferences.copyWith(vibration: value)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save preferences'),
                ),
              ],
            ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool enabled;

  const _SettingSection({
    required this.title,
    required this.children,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
