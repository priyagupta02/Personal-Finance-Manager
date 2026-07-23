import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../firebase_options.dart';
import 'local_notification_service.dart';

/// Handles background/terminated FCM messages. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  developer.log('Background message: ${message.messageId}', name: 'FCM');
}

/// Firebase Cloud Messaging: permission, device token, and foreground display
/// (foreground data notifications are surfaced via [LocalNotificationService];
/// background/terminated notifications are shown by the OS automatically).
class PushNotificationService {
  PushNotificationService(this._local);

  final LocalNotificationService _local;

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final token = await messaging.getToken();
    if (token != null) _local.logToken(token);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _local.show(
          notification.hashCode,
          notification.title ?? 'Personal Finance Manager',
          notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log('Opened from notification: ${message.messageId}',
          name: 'FCM');
    });
  }
}
