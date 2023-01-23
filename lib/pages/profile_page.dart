import 'package:hostel_booking_application/pages/edit_profile_page.dart';
import 'package:hostel_booking_application/pages/manage_your_hostel.dart';
import 'package:hostel_booking_application/pages/settings_page.dart';
import 'package:hostel_booking_application/pages/sign_in_page.dart';
import 'package:hostel_booking_application/pages/users_list_page.dart';
import 'package:hostel_booking_application/services/apis/notifications_api.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_widget.dart';
import '../widgets/top_profile_screen_widget.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = '/profilePage';
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final sizeQuery = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(
            top: sizeQuery.height * 0.22,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (SharedService.isUserAdmin)
                  ProfileWidgets(
                    text: 'View Users',
                    iconData: Icons.supervised_user_circle_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, UsersListPage.routeName);
                    },
                  ),
                if (SharedService.role == 'Hostel Owner')
                  ProfileWidgets(
                    text: 'Manage Your Hostel',
                    iconData: Icons.house_outlined,
                    onTap: () {
                      Navigator.pushNamed(
                          context, ManageYourHostelPage.routeName);
                    },
                  ),
                ProfileWidgets(
                  text: 'Settings',
                  iconData: Icons.settings,
                  onTap: () {
                    Navigator.pushNamed(context, SettingsPage.routeName);
                  },
                ),
                ProfileWidgets(
                  text: 'Log Out',
                  iconData: Icons.logout,
                  onTap: () async {
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    Notifications.deleteToken(userId).then((value) {
                      FirebaseAuth.instance.signOut().then((value) {
                        SharedService.isUserAdmin = false;
                        Navigator.pushNamedAndRemoveUntil(
                            context, SignInPage.routeName, (route) => false);
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        TopProfileScreenWidget(sizeQuery: sizeQuery),
        Positioned(
          top: sizeQuery.height * 0.111,
          right: sizeQuery.width * 0.07,
          child: FloatingActionButton(
            backgroundColor: ThemeClass.primaryColor,
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditProfilePage.routeName,
              );
            },
            child: const Icon(
              Icons.edit,
            ),
          ),
        ),
      ],
    );
  }
}
