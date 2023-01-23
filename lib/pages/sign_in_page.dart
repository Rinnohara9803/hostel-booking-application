import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hostel_booking_application/pages/dashboard_page.dart';
import 'package:hostel_booking_application/pages/forgot_password_page.dart';
import 'package:hostel_booking_application/pages/sign_up_page.dart';
import 'package:hostel_booking_application/pages/verify_email_page.dart';
import 'package:hostel_booking_application/pages/verify_sign_in_otp_page.dart';
import 'package:hostel_booking_application/services/apis/notifications_api.dart';
import 'package:hostel_booking_application/services/email_service.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/general_textformfield.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  static const String routeName = '/signInPage';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _token = '';

  void getToken(String userId) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      _token = token;
      print(_token);
      Notifications.saveToken(token!, userId);
    });
  }

  DateTime? selectedDate;
  String _dob = '';

  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate = pickedDate;
        _dob = selectedDate!.toIso8601String();
      });
    });
  }

  bool _isUserSelected = false;
  bool _isHostelOwnerSelected = false;
  String _role = '';
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  late bool isEmailVerified;

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((value) async {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        if (!isEmailVerified) {
          Navigator.pushReplacementNamed(context, VerifyEmailPage.routeName);
        } else {
          await Provider.of<ProfileProvider>(context, listen: false)
              .fetchProfile()
              .then((value) async {
            if (SharedService.role != 'User') {
              final userId = FirebaseAuth.instance.currentUser!.uid;
              getToken(userId);
            }
            if (SharedService.isTFAO) {
              await EmailService.sendEmail(
                name: SharedService.userName,
                email: SharedService.email,
              ).then((value) {
                Navigator.of(context).pushNamed(VerifySignInOtpPage.routeName,
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
        }
      });
    } on SocketException catch (_) {
      SnackBars.showNoInternetConnectionSnackBar(context);
    } on FirebaseAuthException catch (e) {
      SnackBars.showErrorSnackBar(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveFormForCompleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final id = user!.uid;
    if (_role.isEmpty || _dob.isEmpty) {
      return;
    } else if (!_formKey1.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey1.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance.collection('users').doc(id).set(
        {
          'userId': id,
          'userName': SharedService.userName,
          'email': SharedService.email,
          'contact': _contactController.text,
          'address': _addressController.text,
          'imageUrl': SharedService.userImageUrl,
          'role': _role,
          'isAdminVerified': SharedService.isAdminVerified,
          'dob': _dob,
          'tfa': SharedService.isTFAO,
          'userCredential': '',
        },
      ).then((_) async {
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchProfile()
            .then((value) {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
          Navigator.of(context).pop();
          if (!isEmailVerified) {
            Navigator.pushReplacementNamed(context, VerifyEmailPage.routeName);
          } else {
            Navigator.pushReplacementNamed(
              context,
              DashboardPage.routeName,
            );
          }
        });
      });
    } on SocketException catch (_) {
      SnackBars.showNoInternetConnectionSnackBar(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occured. Please try again later.';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      SnackBars.showErrorSnackBar(context, errorMessage);

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isVisible = true;

  void showCompleteProfileSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            const Color.fromARGB(255, 44, 76, 91),
                            ThemeClass.primaryColor,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      top: -42,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black12,
                          backgroundImage: NetworkImage(
                            SharedService.userImageUrl,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 0,
                      left: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Complete Your Profile: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            SharedService.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            GeneralTextFormField(
                              isDense: true,
                              hasPrefixIcon: true,
                              hasSuffixIcon: false,
                              controller: _contactController,
                              label: 'Contact Number',
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter contact number';
                                }

                                return null;
                              },
                              textInputType: TextInputType.number,
                              iconData: Icons.phone,
                              autoFocus: false,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GeneralTextFormField(
                              isDense: true,
                              hasPrefixIcon: true,
                              hasSuffixIcon: false,
                              controller: _addressController,
                              label: 'Address',
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your address';
                                }

                                return null;
                              },
                              textInputType: TextInputType.name,
                              iconData: Icons.location_city_rounded,
                              autoFocus: false,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? 'No Date Chosen!!!'
                                          : DateFormat.yMd().format(
                                              DateTime.parse(_dob),
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    TextButton(
                                      onPressed: _presentDatePicker,
                                      child: const Text(
                                        'Choose DOB',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isUserSelected,
                                  onChanged: (value) {
                                    if (_isUserSelected) {
                                      return;
                                    }
                                    setState(() {
                                      _isUserSelected = !_isUserSelected;
                                      _isHostelOwnerSelected = false;
                                      _role = 'User';
                                    });
                                  },
                                ),
                                const Text(
                                  'User',
                                ),
                                Checkbox(
                                  value: _isHostelOwnerSelected,
                                  onChanged: (value) {
                                    if (_isHostelOwnerSelected) {
                                      return;
                                    }
                                    setState(() {
                                      _isHostelOwnerSelected =
                                          !_isHostelOwnerSelected;
                                      _isUserSelected = false;

                                      _role = 'Hostel Owner';
                                    });
                                  },
                                ),
                                const Text(
                                  'Hostel Owner',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await _saveFormForCompleteProfile();
                                  },
                                  child: const Text(
                                    'Complete Your Profile',
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
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 30,
            ),
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Image.asset(
                    'images/hostel.png',
                    height: 140,
                    width: 140,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeClass.primaryColor,
                      fontSize: 35,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  GeneralTextFormField(
                    isDense: true,
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
                    height: 10,
                  ),
                  GeneralTextFormField(
                    isDense: true,
                    hasPrefixIcon: true,
                    hasSuffixIcon: true,
                    controller: _passwordController,
                    label: 'Password',
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ForgotPasswordPage.routeName);
                        },
                        child: Text(
                          'Forgot Password ?',
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
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Material(
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
                                        'Sign In',
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
                      ),
                    ],
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     'OR',
                  //     style: TextStyle(
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.bold,
                  //       color: ThemeClass.primaryColor,
                  //     ),
                  //   ),
                  // ),
                  // ElevatedButton.icon(
                  //   style: ElevatedButton.styleFrom(
                  //     elevation: 3,
                  //     primary: Colors.white,
                  //     onPrimary: Colors.black,
                  //     minimumSize: const Size(
                  //       double.infinity,
                  //       50,
                  //     ),
                  //   ),
                  //   onPressed: () async {
                  //     await Provider.of<GoogleSignInProvider>(context,
                  //             listen: false)
                  //         .googleLogin(context)
                  //         .then(
                  //       (value) {
                  //         if (SharedService.role.isEmpty ||
                  //             SharedService.address.isEmpty ||
                  //             SharedService.contact.isEmpty ||
                  //             SharedService.dob.isEmpty) {
                  //           showCompleteProfileSheet(context);
                  //         }
                  //       },
                  //     );
                  //   },
                  //   icon: FaIcon(
                  //     FontAwesomeIcons.google,
                  //     color: ThemeClass.primaryColor,
                  //   ),
                  //   label: const Text(
                  //     'Sign In with Google',
                  //   ),
                  // ),
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
    );
  }
}
