import 'package:hostel_booking_application/pages/sign_in_page.dart';
import 'package:hostel_booking_application/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utilities/snackbars.dart';
import '../utilities/themes.dart';
import '../widgets/general_textformfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  static String routeName = '/forgotPasswordPage';
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final appBar = AppBar(
    backgroundColor: ThemeClass.primaryColor,
    title: const Text('Reset Password'),
  );

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text)
          .then((value) {
        SnackBars.showNormalSnackbar(
            context, 'Password reset email has been sent.');
        Navigator.pushNamedAndRemoveUntil(
            context, SignInPage.routeName, (route) => false);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackBars.showErrorSnackBar(context, 'No user found for this email!!');
      }
    } catch (e) {
      SnackBars.showErrorSnackBar(
        context,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                appBar.preferredSize.height,
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/hostel.png',
                      height: 90,
                      width: 90,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeClass.primaryColor,
                        fontSize: 30,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GeneralTextFormField(
                      isDense: false,
                      hasPrefixIcon: true,
                      hasSuffixIcon: false,
                      controller: _emailController,
                      label: 'Email',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.endsWith('.com')) {
                          return 'Invalid email!';
                        }
                        return null;
                      },
                      textInputType: TextInputType.emailAddress,
                      iconData: Icons.mail_outline,
                      autoFocus: false,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      child: InkWell(
                        onTap: () async {
                          await resetPassword();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: ThemeClass.primaryColor,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Send Email',
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
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account ? ',
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
                                .pushReplacementNamed(SignUpPage.routeName);
                          },
                          child: Text(
                            'Sign Up',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
