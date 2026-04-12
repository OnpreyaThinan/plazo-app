import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Keep handler to enable background message delivery on Android.
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'plazo_default_channel';
  static const String _channelName = 'Plazo Notifications';
  static const String _channelDescription = 'General notifications for Plazo app';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _boundUid;
  bool _boundEnabled = true;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> bindUser(
    String uid, {
    required bool enabled,
  }) async {
    if (uid.isEmpty) return;

    await initialize();

    if (_boundUid == uid && _boundEnabled == enabled) {
      return;
    }

    _boundUid = uid;
    _boundEnabled = enabled;

    await _syncCurrentToken(uid: uid, enabled: enabled);

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        _upsertToken(
          uid: uid,
          token: token,
          enabled: _boundEnabled,
        );
      },
    );
  }

  Future<void> unbindUser() async {
    _boundUid = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> setNotificationsEnabled({
    required String uid,
    required bool enabled,
  }) async {
    if (uid.isEmpty) return;
    await _syncCurrentToken(uid: uid, enabled: enabled);
  }

  Future<void> syncScheduledReminders({
    required List<PlazoItem> items,
    required String leadTime,
    required bool enabled,
    required String language,
  }) async {
    await initialize();
    await _localNotifications.cancelAll();

    if (!enabled) {
      return;
    }

    final leadDuration = _leadDuration(leadTime);
    final now = DateTime.now();
    final isThai = language == 'th';

    for (final item in items) {
      if (item.isCompleted) {
        continue;
      }

      final dueAt = _parseItemDateTime(item);
      if (dueAt == null) {
        continue;
      }

      final remindAt = dueAt.subtract(leadDuration);
      if (!remindAt.isAfter(now)) {
        continue;
      }

      await _localNotifications.zonedSchedule(
        _notificationIdFor(item.id),
        _reminderTitle(item: item, isThai: isThai),
        _reminderBody(item: item, isThai: isThai),
        tz.TZDateTime.from(remindAt.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: item.id,
      );
    }
  }

  String _reminderTitle({
    required PlazoItem item,
    required bool isThai,
  }) {
    if (isThai) {
      return item.type == ItemType.exam ? 'เตือนสอบ' : 'เตือนงาน';
    }
    return item.type == ItemType.exam ? 'Exam Reminder' : 'Task Reminder';
  }

  String _reminderBody({
    required PlazoItem item,
    required bool isThai,
  }) {
    if (isThai) {
      return '${item.title} (${item.subject}) เวลา ${item.time}';
    }
    return '${item.title} (${item.subject}) at ${item.time}';
  }

  Duration _leadDuration(String leadTime) {
    switch (leadTime) {
      case '1d':
        return const Duration(days: 1);
      case '1h':
        return const Duration(hours: 1);
      case '30m':
      default:
        return const Duration(minutes: 30);
    }
  }

  DateTime? _parseItemDateTime(PlazoItem item) {
    final dateParts = item.date.split('/');
    final timeParts = item.time.split(':');

    if (dateParts.length != 3 || timeParts.length != 2) {
      return null;
    }

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (day == null || month == null || year == null || hour == null || minute == null) {
      return null;
    }

    return DateTime(year, month, day, hour, minute);
  }

  int _notificationIdFor(String itemId) {
    return itemId.hashCode & 0x7fffffff;
  }

  Future<void> _syncCurrentToken({
    required String uid,
    required bool enabled,
  }) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await _upsertToken(
      uid: uid,
      token: token,
      enabled: enabled,
    );
  }

  Future<void> _upsertToken({
    required String uid,
    required String token,
    required bool enabled,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notification_tokens')
        .doc(token)
        .set({
      'token': token,
      'enabled': enabled,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Reserved for deep-link routing on notification tap.
  }
}
