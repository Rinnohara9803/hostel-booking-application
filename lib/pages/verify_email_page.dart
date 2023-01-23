import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hostel_booking_application/pages/dashboard_page.dart';
import 'package:hostel_booking_application/pages/sign_in_page.dart';
import 'package:hostel_booking_application/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/apis/notifications_api.dart';
import '../utilities/themes.dart';

class VerifyEmailPage extends StatefulWidget {
  static String routeName = '/verifyEmailPage';
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  String? _token = '';

  void getToken(String userId) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(_token);
      Notifications.saveToken(token!, userId);
    });
  }

  bool isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchProfile()
            .then((value) {
          checkEmailVerified();
        });
      });
    } else {
      if (SharedService.role != 'User') {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        getToken(userId);
      }
      Navigator.of(context).pushReplacementNamed(DashboardPage.routeName);
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      _timer!.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification().then((value) {});
    } catch (e) {
      Navigator.of(context).pushNamed(SignUpPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const DashboardPage()
      : SafeArea(
          child: Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.26,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.lightBlueAccent,
                          ThemeClass.primaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'images/hostel.png',
                        height: 115,
                        width: 115,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text(
                      'Verification link has been sent to your email address.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account ? ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(SignInPage.routeName);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: ThemeClass.primaryColor,
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
}
