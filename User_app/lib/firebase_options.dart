// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYy8zfts9TjBJGmlyCu3W_do9Kp8QjfM0',
    appId: '1:300732475377:web:7e10d4cc3035c808778650',
    messagingSenderId: '300732475377',
    projectId: 'pequire-a5303',
    authDomain: 'pequire-a5303.firebaseapp.com',
    storageBucket: 'pequire-a5303.firebasestorage.app',
    measurementId: 'G-83P217FQTK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCot5vXpmaKfWIrcpvq7rPRkkPlJ0jO9Gk',
    appId: '1:300732475377:android:da6a2254c66435fb778650',
    messagingSenderId: '300732475377',
    projectId: 'pequire-a5303',
    storageBucket: 'pequire-a5303.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCot5vXpmaKfWIrcpvq7rPRkkPlJ0jO9Gk',
    appId: '1:300732475377:ios:7e10d4cc3035c808778650', // Estimated, adjust if needed
    messagingSenderId: '300732475377',
    projectId: 'pequire-a5303',
    storageBucket: 'pequire-a5303.firebasestorage.app',
    iosBundleId: 'com.pequire.user',
  );
}
