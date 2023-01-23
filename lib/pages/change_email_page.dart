import 'dart:io';
import 'package:hostel_booking_application/pages/verify_email_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utilities/snackbars.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/general_textformfield.dart';

class ChangeEmailPage extends StatefulWidget {
  static String routeName = '/changeEmaiklPage';
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => ChangeEmailPageState();
}

class ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final newEmailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      await currentUser
          .updateEmail(
        newEmailController.text,
      )
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'email': newEmailController.text,
        }).then((value) async {
          await Provider.of<ProfileProvider>(context, listen: false)
              .fetchProfile()
              .then((value) {
            Navigator.pushNamedAndRemoveUntil(
                context, VerifyEmailPage.routeName, (route) => false);
          });
        });
      });
    } on SocketException {
      SnackBars.showNoInternetConnectionSnackBar(context);
    } catch (e) {
      SnackBars.showErrorSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Reset Email',
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GeneralTextFormField(
                            isDense: false,
                            hasPrefixIcon: false,
                            hasSuffixIcon: false,
                            controller: newEmailController,
                            label: 'Email',
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@') ||
                                  !value.endsWith('.com')) {
                                return 'Invalid email!';
                              }
                              return null;
                            },
                            textInputType: TextInputType.name,
                            iconData: Icons.email,
                            autoFocus: false,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await _saveForm();
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ThemeClass.primaryColor,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const ProgressIndicator1()
                                      : const Text(
                                          'Update Email',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
