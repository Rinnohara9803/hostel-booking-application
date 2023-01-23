import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class TheUser with ChangeNotifier {
  final String userId;
  final String userName;
  final String email;
  final String contact;
  final String address;
  final String imageUrl;
  final String role;
  bool isAdminVerified;
  final String dob;
  final String userCredential;

  TheUser({
    required this.userId,
    required this.userName,
    required this.email,
    required this.contact,
    required this.address,
    required this.isAdminVerified,
    required this.imageUrl,
    required this.role,
    required this.dob,
    required this.userCredential,
  });

  Future<void> verifyUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isAdminVerified': true,
      });
      isAdminVerified = true;
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
