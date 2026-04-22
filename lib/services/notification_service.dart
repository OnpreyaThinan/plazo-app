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
  static const String _appDisplayName = 'Plazo';
  static const String _androidSmallIcon = 'ic_notification';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _boundUid;
  bool _boundEnabled = true;
  bool _permissionRequested = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool get _isWeb => kIsWeb;

  Future<void> initialize() async {
    if (_initialized) return;

    if (_isWeb) {
      _initialized = true;
      return;
    }

    try {
      tz_data.initializeTimeZones();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // ✅ FIX: ใช้ @mipmap/ic_launcher
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
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

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<bool> requestPermission() async {
    if (_isWeb) return true;

    await initialize();

    debugPrint('🔔 [NOTIF] requestPermission called');

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidAllowed = await androidPlugin?.requestNotificationsPermission();
    debugPrint('🔔 [NOTIF] Android permission result: $androidAllowed');

    // Request FCM permission as best-effort only.
    // Local scheduled reminders should still work independently.
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('🔔 [NOTIF] FCM permission requested successfully');
    } catch (e) {
      debugPrint('🔔 [NOTIF] FCM permission request error (ignored): $e');
      // Ignore FCM permission failures for local reminders.
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final result = androidAllowed ?? true;
      debugPrint('🔔 [NOTIF] requestPermission returning: $result (Android)');
      return result;
    }

    // iOS/macOS: rely on FCM authorization status when Android plugin is not used.
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final result = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('🔔 [NOTIF] requestPermission returning: $result (iOS, status=${settings.authorizationStatus})');
      return result;
    } catch (e) {
      debugPrint('🔔 [NOTIF] requestPermission iOS error (returning true): $e');
      return true;
    }
  }

  Future<void> bindUser(
    String uid, {
    required bool enabled,
  }) async {
    debugPrint('🔔 [NOTIF] bindUser called - uid=$uid, enabled=$enabled');
    
    if (_isWeb) {
      debugPrint('🔔 [NOTIF] bindUser: Web platform, returning');
      return;
    }
    if (uid.isEmpty) {
      debugPrint('🔔 [NOTIF] bindUser: Empty UID, returning');
      return;
    }

    await initialize();

    if (_boundUid == uid && _boundEnabled == enabled) {
      debugPrint('🔔 [NOTIF] bindUser: Already bound with same settings, returning');
      return;
    }

    _boundUid = uid;
    _boundEnabled = enabled;
    debugPrint('🔔 [NOTIF] bindUser: Updated _boundUid and _boundEnabled');

    if (enabled && !_permissionRequested) {
      debugPrint('🔔 [NOTIF] bindUser: Requesting permission');
      _permissionRequested = true;
      final allowed = await requestPermission();
      debugPrint('🔔 [NOTIF] bindUser: Permission result=$allowed');
      if (!allowed) {
        _boundEnabled = false;
        debugPrint('🔔 [NOTIF] bindUser: Permission denied, set _boundEnabled=false');
      }
    } else {
      debugPrint('🔔 [NOTIF] bindUser: Skip permission (enabled=$enabled, _permissionRequested=$_permissionRequested)');
    }

    await _syncCurrentToken(uid: uid, enabled: _boundEnabled);

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _upsertToken(
        uid: uid,
        token: token,
        enabled: _boundEnabled,
      );
    });
    debugPrint('🔔 [NOTIF] bindUser: Completed');
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
    if (_isWeb) return;
    if (uid.isEmpty) return;

    await _syncCurrentToken(uid: uid, enabled: enabled);
  }

  Future<void> syncScheduledReminders({
    required List<PlazoItem> items,
    required String leadTime,
    required bool enabled,
    required String language,
  }) async {
    if (_isWeb) return;

    debugPrint('🔔 [NOTIF] syncScheduledReminders called - enabled=$enabled, leadTime=$leadTime, itemCount=${items.length}');

    await initialize();
    await _localNotifications.cancelAll();
    debugPrint('🔔 [NOTIF] Cancelled all previous notifications');

    if (!enabled) {
      debugPrint('🔔 [NOTIF] Notifications disabled, returning early');
      return;
    }

    final hasPermission = await _hasLocalNotificationPermission();
    debugPrint('🔔 [NOTIF] Permission check: hasPermission=$hasPermission');

    if (!hasPermission) {
      debugPrint('🔔 [NOTIF] No permission, requesting...');
      final granted = await requestPermission();
      debugPrint('🔔 [NOTIF] Permission request result: granted=$granted');
      if (!granted) {
        debugPrint('🔔 [NOTIF] Permission denied, returning early');
        return;
      }
    }

    final leadDuration = _leadDuration(leadTime);
    final now = DateTime.now();
    final isThai = language == 'th';

    debugPrint('🔔 [NOTIF] Lead duration: $leadDuration, now: $now');

    int scheduledCount = 0;
    int skippedCompleted = 0;
    int skippedPastDate = 0;
    int skippedParseError = 0;

    for (final item in items) {
      if (item.isCompleted) {
        skippedCompleted++;
        continue;
      }

      final dueAt = _parseItemDateTime(item);
      if (dueAt == null) {
        debugPrint('🔔 [NOTIF] Failed to parse date for item "${item.title}" (${item.date} ${item.time})');
        skippedParseError++;
        continue;
      }

      final remindAt = dueAt.subtract(leadDuration);
      if (!remindAt.isAfter(now)) {
        debugPrint('🔔 [NOTIF] Skipped past date "${item.title}" - remindAt=$remindAt, now=$now');
        skippedPastDate++;
        continue;
      }

      final notificationTitle = _reminderTitle(
        item: item,
        isThai: isThai,
      );
      final notificationBody = _reminderBody(
        item: item,
        dueAt: dueAt,
        isThai: isThai,
      );

      final notificationId = _notificationIdFor(item.id);
      debugPrint('🔔 [NOTIF] Scheduling notification for "${item.title}"');
      debugPrint('  - Title: $notificationTitle');
      debugPrint('  - Body: $notificationBody');
      debugPrint('  - Schedule time (remindAt): $remindAt');
      debugPrint('  - Notification ID: $notificationId');

      try {
        await _localNotifications.zonedSchedule(
          notificationId,
          notificationTitle,
          notificationBody,
          tz.TZDateTime.from(remindAt.toUtc(), tz.UTC),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              icon: _androidSmallIcon,
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
        scheduledCount++;
        debugPrint('🔔 [NOTIF] ✅ Successfully scheduled notification');
      } catch (e) {
        debugPrint('🔔 [NOTIF] ❌ Error scheduling notification: $e');
      }
    }

    debugPrint('🔔 [NOTIF] ===== SUMMARY =====');
    debugPrint('🔔 [NOTIF] Total items: ${items.length}');
    debugPrint('🔔 [NOTIF] Scheduled: $scheduledCount');
    debugPrint('🔔 [NOTIF] Skipped (completed): $skippedCompleted');
    debugPrint('🔔 [NOTIF] Skipped (past date): $skippedPastDate');
    debugPrint('🔔 [NOTIF] Skipped (parse error): $skippedParseError');
  }

  String _reminderTitle({
    required PlazoItem item,
    required bool isThai,
  }) {
    final category = isThai
        ? (item.type == ItemType.exam ? 'เตือนสอบ' : 'เตือนงาน')
        : (item.type == ItemType.exam ? 'Exam Reminder' : 'Task Reminder');
    return '$_appDisplayName • $category';
  }

  String _reminderBody({
    required PlazoItem item,
    required DateTime dueAt,
    required bool isThai,
  }) {
    final scheduledTime = _formatReminderDateTime(dueAt, isThai: isThai);
    return isThai
        ? '${item.subject} • ${item.title}\nกำหนดส่ง/สอบเวลา $scheduledTime'
        : '${item.subject} • ${item.title}\nDue at $scheduledTime';
  }

  String _formatReminderDateTime(DateTime dateTime, {required bool isThai}) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (isThai) {
      return '$day/$month/$year $hour:$minute';
    }

    return '$day/$month/$year $hour:$minute';
  }

  Duration _leadDuration(String leadTime) {
    switch (leadTime) {
      case '1d':
        return const Duration(days: 1);
      case '1h':
        return const Duration(hours: 1);
      case '30m':
        return const Duration(minutes: 30);
      case '5m':
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 30);
    }
  }

  DateTime? _parseItemDateTime(PlazoItem item) {
    final dateParts = item.date.split('/');
    final timeParts = item.time.split(':');

    if (dateParts.length != 3 || timeParts.length != 2) return null;

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if ([day, month, year, hour, minute].contains(null)) return null;

    return DateTime(year!, month!, day!, hour!, minute!);
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
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          icon: _androidSmallIcon,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {}

  Future<bool> _hasLocalNotificationPermission() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      debugPrint('🔔 [NOTIF] _hasLocalNotificationPermission: No Android plugin, returning true');
      return true;
    }

    final enabled = await androidPlugin.areNotificationsEnabled();
    debugPrint('🔔 [NOTIF] _hasLocalNotificationPermission: Android result=$enabled');
    return enabled ?? true;
  }
}