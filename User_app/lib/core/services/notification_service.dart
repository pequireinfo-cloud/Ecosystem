import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../injection_container.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (iOS specifically)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
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

    // Set up Android Channel for Custom Sound/High Importance
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pequire_user_channel', // id
      'Pequire User Notifications', // name
      description: 'Important updates about your bookings', // description
      importance: Importance.max,
      playSound: true,
      // To add a custom sound later, uncomment this line and ensure the sound is in android/app/src/main/res/raw/
      // sound: RawResourceAndroidNotificationSound('custom_sound'),
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
              // sound: RawResourceAndroidNotificationSound('custom_sound'),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              // sound: 'custom_sound.wav',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Listen to notification taps when app is in background but opened via tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
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
      
      final prefs = sl<SharedPreferences>();
      final userToken = prefs.getString('auth_token');
      if (userToken == null) return;

      final dio = sl<Dio>();
      await dio.put(
        '/users/update-fcm',
        data: {'fcmToken': token},
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );
      print('FCM Token synced with backend');
    } catch (e) {
      print('Failed to sync FCM Token: $e');
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
    // e.g., if (data['type'] == 'booking_arrived') Navigate to ActiveBooking
    print("Notification tapped with payload: $data");
  }
}
