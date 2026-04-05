import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/local/preferences_service.dart';
import '../data/services/notification_service.dart';
import '../data/models/prayer_model.dart';

class NotificationProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  bool _permissionGranted = false;

  static const List<String> prayerNames = [
    'Imsak', 'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'
  ];

  NotificationProvider(this._prefs);

  bool get permissionGranted => _permissionGranted;

  bool isEnabled(String prayer) => _prefs.getNotifEnabled(prayer);

  Map<String, bool> get allToggles {
    return {for (final p in prayerNames) p: _prefs.getNotifEnabled(p)};
  }

  Future<void> initialize() async {
    if (kIsWeb) return;
    await NotificationService.initialize();
    _permissionGranted = await NotificationService.requestPermissions();
    notifyListeners();
  }

  Future<void> toggle(String prayer, bool enabled,
      {PrayerTimeModel? prayerTime}) async {
    if (kIsWeb) return;
    await _prefs.setNotifEnabled(prayer, enabled);
    if (prayerTime != null) {
      await NotificationService.scheduleFromPrayerTime(
        prayerTime: prayerTime,
        prefs: _prefs,
      );
    }
    notifyListeners();
  }

  Future<void> scheduleAll(PrayerTimeModel prayerTime) async {
    if (kIsWeb) return;
    await NotificationService.scheduleFromPrayerTime(
      prayerTime: prayerTime,
      prefs: _prefs,
    );
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await NotificationService.cancelAll();
  }
}
