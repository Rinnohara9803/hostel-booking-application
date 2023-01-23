import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/shared_service.dart';
import '../utilities/themes.dart';

class HostelOwnerWidget extends StatelessWidget {
  final String hostelOwnerName;
  final String hostelContact;
  final String hostelEmail;
  const HostelOwnerWidget(
      {Key? key,
      required this.hostelOwnerName,
      required this.hostelContact,
      required this.hostelEmail})
      : super(key: key);

  _launchPhoneURL(String phoneNumber) async {
    String url = 'tel: $phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchSMSURL(String phoneNumber) async {
    String url = 'sms: $phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchMailURL(String gmail) async {
    String url = 'mailto: $gmail';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hostelOwnerName,
                style: TextStyle(
                  color: ThemeClass.primaryColor,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Owner',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              FloatingActionButton.small(
                heroTag: 'Call',
                backgroundColor: Colors.white,
                onPressed: !SharedService.isAdminVerified ||
                        SharedService.role == 'Hostel Owner'
                    ? null
                    : () {
                        _launchPhoneURL(hostelContact);
                      },
                child: const Icon(
                  Icons.phone,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              FloatingActionButton.small(
                heroTag: 'Message',
                backgroundColor: Colors.white,
                onPressed: !SharedService.isAdminVerified ||
                        SharedService.role == 'Hostel Owner'
                    ? null
                    : () {
                        _launchSMSURL(hostelContact);
                      },
                child: const Icon(
                  Icons.message,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              FloatingActionButton.small(
                heroTag: 'Email',
                backgroundColor: Colors.white,
                onPressed: !SharedService.isAdminVerified ||
                        SharedService.role == 'Hostel Owner'
                    ? null
                    : () {
                        _launchMailURL(hostelEmail);
                      },
                child: Icon(
                  Icons.email,
                  color: ThemeClass.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
