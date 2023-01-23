import 'package:flutter/material.dart';
import 'package:hostel_booking_application/pages/view_document_page.dart';
import 'package:hostel_booking_application/providers/the_user_provider.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../services/shared_service.dart';
import '../utilities/snackbars.dart';

class UserDetailsPage extends StatefulWidget {
  static String routeName = '/userDetailsPage';
  const UserDetailsPage({Key? key}) : super(key: key);

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  Widget profileDetailBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.lightBlue,
            fontSize: 15,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Divider(),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    final theHeight = MediaQuery.of(context).size.height;
    final theWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: ThemeClass.primaryColor,
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 60,
                      top: 50,
                      right: 40,
                      bottom: 10,
                    ),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileDetailBox(
                            'Your email',
                            SharedService.email,
                          ),
                          profileDetailBox('Contact', user.contact),
                          profileDetailBox('Address', user.address),
                          profileDetailBox('Role', user.role),
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            child: InkWell(
                              onTap: user.isAdminVerified
                                  ? null
                                  : () async {
                                      await user
                                          .verifyUser(user.userId)
                                          .then((value) {
                                        SnackBars.showNormalSnackbar(
                                            context, 'User Verified');
                                      }).catchError((e) {
                                        SnackBars.showErrorSnackBar(
                                            context, e.toString());
                                      });
                                    },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: user.isAdminVerified
                                      ? Colors.grey
                                      : ThemeClass.primaryColor,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Verify User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: theHeight * 0.11,
              left: theWidth * 0.09,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: theWidth * 0.14,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: theWidth * 0.135,
                      backgroundColor: Colors.black12,
                      backgroundImage: NetworkImage(
                        user.imageUrl,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 85, 106, 213),
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                user.isAdminVerified
                                    ? Icons.verified_outlined
                                    : Icons.no_accounts,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                user.isAdminVerified ? 'Verified' : '_ _ _ _ _',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: theHeight * 0.125,
              left: theWidth * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Date of Birth: ${DateFormat.yMd().format(
                      DateTime.parse(user.dob),
                    )}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNotifierProvider<TheUser>.value(
                          value: user,
                          child: const ViewDocumentPage(),
                        ),
                      ));
                },
                icon: const Icon(
                  Icons.document_scanner,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
