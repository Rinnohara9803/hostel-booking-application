import 'package:flutter/material.dart';

class ProfileWidgets extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Function onTap;

  const ProfileWidgets({
    required this.text,
    required this.iconData,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        height: MediaQuery.of(context).size.height * 0.08,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10,
          ),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
