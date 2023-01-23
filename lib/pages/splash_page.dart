import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hostel_booking_application/main.dart';
import 'package:hostel_booking_application/pages/sign_in_page.dart';
import 'package:hostel_booking_application/pages/verify_sign_in_otp_page.dart';
import 'package:provider/provider.dart';
import '../Utilities/snackbars.dart';
import '../providers/profile_provider.dart';
import '../services/apis/notifications_api.dart';
import '../services/email_service.dart';
import '../services/shared_service.dart';
import '../utilities/themes.dart';
import 'dashboard_page.dart';
import 'verify_email_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? _token;
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      fetchUser();
    });
    super.initState();
    requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('on message');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.white,
              playSound: true,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('on message opened app');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              priority: Priority.high,
              channelDescription: channel.description,
              color: Colors.white,
              playSound: true,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('notification permission');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission.');
    } else {
      print('User declined the permission.');
    }
  }

  void getToken(String userId) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      _token = token;
      print(_token);
      Notifications.saveToken(token!, userId);
    });
  }

  Future fetchUser() async {
    // ignore: unrelated_type_equality_checks
    if (FirebaseAuth.instance.authStateChanges().isEmpty == true) {
      Navigator.pushReplacementNamed(context, SignInPage.routeName);
    } else {
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified == false) {
        Navigator.pushReplacementNamed(context, VerifyEmailPage.routeName);
        return;
      } else {
        try {
          await Provider.of<ProfileProvider>(context, listen: false)
              .fetchProfile()
              .then((value) async {
            getToken(user!.uid);
            if (SharedService.isTFAO) {
              await EmailService.sendEmail(
                name: SharedService.userName,
                email: SharedService.email,
              ).then((value) {
                Navigator.of(context).pushReplacementNamed(
                    VerifySignInOtpPage.routeName,
                    arguments: SharedService.email);
              }).catchError((e) {
                SnackBars.showErrorSnackBar(context, e.toString());
              });
            } else {
              Navigator.pushReplacementNamed(
                context,
                DashboardPage.routeName,
              );
            }
          });
        } on SocketException catch (_) {
          Navigator.pushReplacementNamed(context, SignInPage.routeName);
        } catch (e) {
          Navigator.pushReplacementNamed(context, SignInPage.routeName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeClass.primaryColor.withOpacity(
          0.7,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/hostel.png',
                height: 130,
                width: 130,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'hosTel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  fontFamily: 'Lato',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
