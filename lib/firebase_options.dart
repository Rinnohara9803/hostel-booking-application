// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0VD8FGuSM_wAC5pnVRCpjVJusSYcDrt0',
    appId: '1:540159962883:web:c2cbecc578794d4ac98336',
    messagingSenderId: '540159962883',
    projectId: 'hostel-booking-applicati-bc7f9',
    authDomain: 'hostel-booking-applicati-bc7f9.firebaseapp.com',
    storageBucket: 'hostel-booking-applicati-bc7f9.appspot.com',
    measurementId: 'G-EDJS0RQPSW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDY1sY-X-Nbs2T5CB3uS7pUcWk0VmLg8RI',
    appId: '1:540159962883:android:c138cebe35c90439c98336',
    messagingSenderId: '540159962883',
    projectId: 'hostel-booking-applicati-bc7f9',
    storageBucket: 'hostel-booking-applicati-bc7f9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAM-7Wh4uzwRm3KHZ6qDhsYO6n8wA7Kk8',
    appId: '1:540159962883:ios:0526cef65c586259c98336',
    messagingSenderId: '540159962883',
    projectId: 'hostel-booking-applicati-bc7f9',
    storageBucket: 'hostel-booking-applicati-bc7f9.appspot.com',
    iosClientId: '540159962883-shnqn84n0art8la2ohj0ebfvvp0amlg8.apps.googleusercontent.com',
    iosBundleId: 'com.example.hostelBookingApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAM-7Wh4uzwRm3KHZ6qDhsYO6n8wA7Kk8',
    appId: '1:540159962883:ios:0526cef65c586259c98336',
    messagingSenderId: '540159962883',
    projectId: 'hostel-booking-applicati-bc7f9',
    storageBucket: 'hostel-booking-applicati-bc7f9.appspot.com',
    iosClientId: '540159962883-shnqn84n0art8la2ohj0ebfvvp0amlg8.apps.googleusercontent.com',
    iosBundleId: 'com.example.hostelBookingApplication',
  );
}