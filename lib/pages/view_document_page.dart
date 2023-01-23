import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/the_user_provider.dart';
import 'package:provider/provider.dart';

import '../utilities/themes.dart';

class ViewDocumentPage extends StatefulWidget {
  static String routeName = '/viewDocumentPage';
  const ViewDocumentPage({Key? key}) : super(key: key);

  @override
  State<ViewDocumentPage> createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                height: 145,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.lightBlueAccent,
                      ThemeClass.primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(
                      50,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.navigate_before,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (user.role != 'Admin')
                      Text(
                        user.role == 'User'
                            ? 'User Credential'
                            : 'Hostel Owner Credential',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    if (user.role == 'Admin')
                      const Text(
                        'Admin Credential',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    left: 15,
                    right: 15,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(
                              5,
                            ),
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: user.userCredential.isEmpty
                              ? const Center(
                                  child: Text(
                                      'User hasn\'t uploaded any document.'),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ),
                                  child: Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(user.userCredential)),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
