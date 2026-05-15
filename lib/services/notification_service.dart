import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifikasi lokal harian (Android/iOS). Web/desktop tidak menjadwalkan ([supportsDailyReminder] false).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _prefsKey = 'uangky_daily_reminder_v1';
  static const _dailyId = 9001;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static bool get _supportsPeriodic =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// True jika pengingat harian benar-benar bisa dijadwalkan (Android/iOS).
  static bool get supportsDailyReminder => _supportsPeriodic;

  Future<void> init() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    if (_initialized) return;
    if (_supportsPeriodic) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
      );
    }
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefsKey) == true && _supportsPeriodic) {
      await _requestAndroidPostPermission();
      await _requestIosPermission();
      await _scheduleDaily();
    }
  }

  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Aktifkan / matikan pengingat harian (sekali sehari, interval tidak exact agar minim izin khusus).
  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
    if (!_supportsPeriodic) return;
    if (enabled) {
      await _requestAndroidPostPermission();
      await _requestIosPermission();
      await _scheduleDaily();
    } else {
      await _plugin.cancel(id: _dailyId);
    }
  }

  Future<void> _requestAndroidPostPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _requestIosPermission() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _scheduleDaily() async {
    await _plugin.cancel(id: _dailyId);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'uangky_reminder',
        'Pengingat UangKy',
        channelDescription: 'Mengingatkan untuk membuka app dan mengecek jadwal.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.periodicallyShow(
      id: _dailyId,
      title: 'UangKy',
      body: 'Buka app untuk cek jadwal dan catatan keuanganmu.',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
