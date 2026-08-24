import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  final bool enabled;
  final bool reservation;
  final bool wallet;
  final bool anpr;
  final bool support;
  final bool sound;
  final bool vibration;

  const NotificationPreferences({
    required this.enabled,
    required this.reservation,
    required this.wallet,
    required this.anpr,
    required this.support,
    required this.sound,
    required this.vibration,
  });

  static const defaults = NotificationPreferences(
    enabled: true,
    reservation: true,
    wallet: true,
    anpr: true,
    support: true,
    sound: true,
    vibration: true,
  );

  bool allowsType(String? rawType) {
    if (!enabled) return false;

    switch ((rawType ?? '').trim().toLowerCase()) {
      case 'reservation':
      case 'reminder':
        return reservation;
      case 'wallet':
      case 'payment':
        return wallet;
      case 'anpr':
      case 'parking':
        return anpr;
      case 'support':
      case 'issue':
        return support;
      default:
        return true;
    }
  }

  NotificationPreferences copyWith({
    bool? enabled,
    bool? reservation,
    bool? wallet,
    bool? anpr,
    bool? support,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      reservation: reservation ?? this.reservation,
      wallet: wallet ?? this.wallet,
      anpr: anpr ?? this.anpr,
      support: support ?? this.support,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }
}

class NotificationPreferenceService {
  static const _enabledKey = 'notification_enabled';
  static const _reservationKey = 'notification_reservation';
  static const _walletKey = 'notification_wallet';
  static const _anprKey = 'notification_anpr';
  static const _supportKey = 'notification_support';
  static const _soundKey = 'notification_sound';
  static const _vibrationKey = 'notification_vibration';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = NotificationPreferences.defaults;

    return NotificationPreferences(
      enabled: prefs.getBool(_enabledKey) ?? defaults.enabled,
      reservation: prefs.getBool(_reservationKey) ?? defaults.reservation,
      wallet: prefs.getBool(_walletKey) ?? defaults.wallet,
      anpr: prefs.getBool(_anprKey) ?? defaults.anpr,
      support: prefs.getBool(_supportKey) ?? defaults.support,
      sound: prefs.getBool(_soundKey) ?? defaults.sound,
      vibration: prefs.getBool(_vibrationKey) ?? defaults.vibration,
    );
  }

  Future<void> save(NotificationPreferences value) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool(_enabledKey, value.enabled),
      prefs.setBool(_reservationKey, value.reservation),
      prefs.setBool(_walletKey, value.wallet),
      prefs.setBool(_anprKey, value.anpr),
      prefs.setBool(_supportKey, value.support),
      prefs.setBool(_soundKey, value.sound),
      prefs.setBool(_vibrationKey, value.vibration),
    ]);
  }
}
