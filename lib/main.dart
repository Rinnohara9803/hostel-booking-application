import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hostel_booking_application/pages/add_your_hostel_page.dart';
import 'package:hostel_booking_application/pages/edit_profile_page.dart';
import 'package:hostel_booking_application/pages/forgot_password_page.dart';
import 'package:hostel_booking_application/pages/manage_your_hostel.dart';
import 'package:hostel_booking_application/pages/search_by_address_page.dart';
import 'package:hostel_booking_application/pages/search_page.dart';
import 'package:hostel_booking_application/pages/settings_page.dart';
import 'package:hostel_booking_application/pages/splash_page.dart';
import 'package:hostel_booking_application/pages/user_credential_page.dart';
import 'package:hostel_booking_application/pages/user_details_page.dart';
import 'package:hostel_booking_application/pages/verify_sign_in_otp_page.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/change_email_page.dart';
import 'pages/change_password_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/users_list_page.dart';
import 'pages/verify_email_page.dart';
import 'providers/profile_provider.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'high_importance_notification',
  description: 'this channel is used for important notifications',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(
          create: (ctx) => ProfileProvider(),
        ),
        ChangeNotifierProvider<UsersProvider>(
          create: (ctx) => UsersProvider(),
        ),
        ChangeNotifierProvider<HostelsProvider>(
          create: (ctx) => HostelsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        routes: {
          SignUpPage.routeName: (context) => const SignUpPage(),
          SignInPage.routeName: (context) => const SignInPage(),
          VerifyEmailPage.routeName: (context) => const VerifyEmailPage(),
          DashboardPage.routeName: (context) => const DashboardPage(),
          ForgotPasswordPage.routeName: (context) => const ForgotPasswordPage(),
          SettingsPage.routeName: (context) => const SettingsPage(),
          ChangePasswordPage.routeName: (context) => const ChangePasswordPage(),
          ChangeEmailPage.routeName: (context) => const ChangeEmailPage(),
          EditProfilePage.routeName: (context) => const EditProfilePage(),
          UserCredentialPage.routeName: (context) => const UserCredentialPage(),
          UsersListPage.routeName: (context) => const UsersListPage(),
          UserDetailsPage.routeName: (context) => const UserDetailsPage(),
          ManageYourHostelPage.routeName: (context) =>
              const ManageYourHostelPage(),
          AddYourHostel.routeName: (context) => const AddYourHostel(),
          VerifySignInOtpPage.routeName: (context) =>
              const VerifySignInOtpPage(),
          SearchPage.routeName: (context) => const SearchPage(),
          SearchPageByAddress.routeName: (context) =>
              const SearchPageByAddress(),
        },
      ),
    );
  }
}

int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token, String title, String body) {
  _messageCount++;
  return jsonEncode(
    {
      'to': token,
      'priority': 'high',
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': title,
        'body': body,
      },
    },
  );
}
