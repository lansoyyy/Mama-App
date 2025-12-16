import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> syncUserMedicationReminders(String userId) async {
    if (!_initialized) {
      await init();
    }

    final meds = await FirebaseFirestore.instance
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in meds.docs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString();
      final dosage = (data['dosage'] ?? '').toString();
      final frequency = (data['frequency'] ?? 'Daily').toString();
      final time = (data['time'] ?? '8:00 AM').toString();

      int? weeklyWeekday;
      if (frequency == 'Weekly') {
        final createdAt = data['createdAt'];
        if (createdAt is Timestamp) {
          weeklyWeekday = createdAt.toDate().weekday;
        }
      }

      await scheduleMedicationReminders(
        userId: userId,
        medicationId: doc.id,
        medicationName: name,
        dosage: dosage,
        frequency: frequency,
        time: time,
        weeklyWeekday: weeklyWeekday,
      );
    }
  }

  Future<void> cancelMedicationReminders(
      String userId, String medicationId) async {
    if (!_initialized) {
      await init();
    }

    final base = _notificationBaseId(userId, medicationId);
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);
    await _plugin.cancel(base + 2);
  }

  Future<void> scheduleMedicationReminders({
    required String userId,
    required String medicationId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String time,
    int? weeklyWeekday,
  }) async {
    if (!_initialized) {
      await init();
    }

    await cancelMedicationReminders(userId, medicationId);

    final times = _timesForFrequency(frequency, time);

    for (int slot = 0; slot < times.length; slot++) {
      final t = times[slot];
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Reminders to take scheduled medications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      final now = tz.TZDateTime.now(tz.local);
      final bool isWeekly = frequency == 'Weekly';
      final int targetWeekday = weeklyWeekday ?? now.weekday;

      final tz.TZDateTime scheduled = isWeekly
          ? _nextInstanceOfWeekdayTime(
              targetWeekday,
              t.hour,
              t.minute,
            )
          : _nextInstanceOfTime(t.hour, t.minute);

      final DateTimeComponents match = isWeekly
          ? DateTimeComponents.dayOfWeekAndTime
          : DateTimeComponents.time;

      final notificationId = _notificationBaseId(userId, medicationId) + slot;

      await _plugin.zonedSchedule(
        notificationId,
        'Medication Reminder',
        'Time to take your $medicationName ($dosage)',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: match,
        payload: medicationId,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    int daysToAdd = (weekday - scheduled.weekday) % 7;
    scheduled = scheduled.add(Duration(days: daysToAdd));
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }

  List<TimeOfDayLike> _timesForFrequency(String frequency, String time) {
    final base = _parseTimeString(time);
    switch (frequency) {
      case 'Twice Daily':
        return [
          base,
          _addHours(base, 12),
        ];
      case 'Three Times Daily':
        return [
          base,
          _addHours(base, 8),
          _addHours(base, 16),
        ];
      case 'Weekly':
      case 'Daily':
      default:
        return [base];
    }
  }

  TimeOfDayLike _addHours(TimeOfDayLike base, int hoursToAdd) {
    final totalMinutes = (base.hour * 60) + base.minute + (hoursToAdd * 60);
    final normalized = totalMinutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return TimeOfDayLike(hour, minute);
  }

  TimeOfDayLike _parseTimeString(String time) {
    final parts = time.trim().split(':');
    if (parts.length < 2) {
      return const TimeOfDayLike(8, 0);
    }

    final hourPart = int.tryParse(parts[0].trim()) ?? 8;
    final minuteParts = parts[1].trim().split(' ');
    final minute = int.tryParse(minuteParts[0].trim()) ?? 0;
    final period =
        (minuteParts.length > 1 ? minuteParts[1] : 'AM').toUpperCase();

    int hour = hourPart;
    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDayLike(hour, minute);
  }

  int _notificationBaseId(String userId, String medicationId) {
    final key = '$userId:$medicationId';
    return _fnv1a32(key) & 0x7FFFFFFF;
  }

  int _fnv1a32(String input) {
    const int fnvPrime = 0x01000193;
    int hash = 0x811C9DC5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }
}

class TimeOfDayLike {
  final int hour;
  final int minute;

  const TimeOfDayLike(this.hour, this.minute);
}
