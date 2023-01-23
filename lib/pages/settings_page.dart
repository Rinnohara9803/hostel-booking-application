import 'package:hostel_booking_application/pages/change_email_page.dart';
import 'package:hostel_booking_application/pages/change_password_page.dart';
import 'package:hostel_booking_application/pages/sign_in_page.dart';
import 'package:hostel_booking_application/providers/profile_provider.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';

import '../services/shared_service.dart';
import '../widgets/enable_tfa_widget.dart';

class SettingsPage extends StatelessWidget {
  static String routeName = '/settingsPage';
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeClass.primaryColor,
          title: const Text(
            'Settings',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ChangePasswordPage.routeName);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.lock,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Change Password',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ChangeEmailPage.routeName);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.email,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Change Email',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Are you Sure?'),
                          content: const Text(
                            'Do you want to delete your Account ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Provider.of<ProfileProvider>(context,
                                        listen: false)
                                    .deleteProfile()
                                    .then((value) {
                                  SharedService.isUserAdmin = false;
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      SignInPage.routeName, (route) => false);
                                  SnackBars.showErrorSnackBar(
                                      context, 'Account deleted successfully.');
                                }).catchError((e) {
                                  SnackBars.showErrorSnackBar(
                                      context, e.toString());
                                });
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        );
                      });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.person_off_sharp,
                          color: Colors.redAccent,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Delete Account',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const SwitchTwoFactorAuthenticationWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
