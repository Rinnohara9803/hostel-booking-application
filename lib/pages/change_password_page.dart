import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utilities/snackbars.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/general_textformfield.dart';

class ChangePasswordPage extends StatefulWidget {
  static String routeName = '/changePasswordPage';
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

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
          .updatePassword(
        newPasswordController.text,
      )
          .then((value) {
        SnackBars.showNormalSnackbar(
          context,
          'Reset password successful!!!',
        );
        Navigator.of(context).pop();
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
                      'Change Password',
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
                            hasPrefixIcon: true,
                            hasSuffixIcon: true,
                            controller: newPasswordController,
                            label: 'New Password',
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Please enter your password.';
                              } else if (value.trim().length < 6) {
                                return 'Please enter at least 6 characters.';
                              }
                              return null;
                            },
                            textInputType: TextInputType.name,
                            iconData: Icons.lock,
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
                                          'Reset Password',
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
