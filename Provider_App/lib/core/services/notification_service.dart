import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Provider handling a background message: ${message.messageId}");
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api')); // Update with your actual API config if different

  Future<void> initialize() async {
    // Request permission (iOS specifically)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Provider granted permission');
    } else {
      print('Provider declined or has not accepted permission');
    }

    // Initialize Local Notifications for Foreground
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Set up Android Channel for Custom Sound/High Importance (Provider specifically needs loud alerts for new jobs)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pequire_provider_channel', // id
      'Pequire Provider Notifications', // name
      description: 'Loud alerts for incoming jobs', // description
      importance: Importance.max,
      playSound: true,
      // To add a custom loud ringtone later, uncomment this line and ensure the sound is in android/app/src/main/res/raw/
      // sound: RawResourceAndroidNotificationSound('loud_job_alert'),
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Listen to Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              // sound: RawResourceAndroidNotificationSound('loud_job_alert'),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              // sound: 'loud_job_alert.wav',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Listen to notification taps when app is in background but opened via tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Provider A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message.data);
    });
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final token = await getToken();
      if (token == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('auth_token');
      if (userToken == null) return;

      await _dio.put(
        '/providers/update-fcm',
        data: {'fcmToken': token},
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );
      print('Provider FCM Token synced with backend');
    } catch (e) {
      print('Failed to sync Provider FCM Token: $e');
    }
  }

  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationTap(data);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // TODO: Route to correct page based on data payload
    print("Provider Notification tapped with payload: $data");
  }
}
