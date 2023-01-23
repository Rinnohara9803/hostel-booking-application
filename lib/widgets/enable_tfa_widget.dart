import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/profile_provider.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:provider/provider.dart';
import '../services/shared_service.dart';
import '../utilities/themes.dart';

class SwitchTwoFactorAuthenticationWidget extends StatefulWidget {
  const SwitchTwoFactorAuthenticationWidget({Key? key}) : super(key: key);

  @override
  State<SwitchTwoFactorAuthenticationWidget> createState() =>
      _SwitchTwoFactorAuthenticationWidgetState();
}

class _SwitchTwoFactorAuthenticationWidgetState
    extends State<SwitchTwoFactorAuthenticationWidget> {
  bool isTFAO = SharedService.isTFAO;

  void toggleSwitch(bool value) {
    if (isTFAO == false) {
      setState(() {
        isTFAO = true;
      });
    } else {
      setState(() {
        isTFAO = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RawMaterialButton(
              onPressed: () {},
              elevation: 2.0,
              fillColor: ThemeClass.primaryColor,
              padding: const EdgeInsets.all(
                11,
              ),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.security,
                size: 18.0,
                color: Colors.white,
              ),
            ),
            const Text(
              'Enable Two Factor Authentication',
            ),
          ],
        ),
        Row(
          children: [
            Switch(
              onChanged: (value) async {
                toggleSwitch(value);
                await Provider.of<ProfileProvider>(context, listen: false)
                    .switchTfa()
                    .catchError((e) {
                  toggleSwitch(!value);
                  SnackBars.showErrorSnackBar(context, e.toString());
                });
              },
              value: isTFAO,
              activeColor: ThemeClass.primaryColor,
              splashRadius: 4,
            ),
          ],
        ),
      ],
    );
  }
}
