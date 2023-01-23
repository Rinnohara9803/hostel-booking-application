import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../services/shared_service.dart';

class ProfileProvider with ChangeNotifier {
  String _userName = '';
  String _imageUrl = '';
  String _email = '';
  String _dob = '';
  String _contact = '';
  String _address = '';
  String _userCredential = '';
  bool _isAdminVerified = false;
  bool _tfa = false;

  bool get tfa {
    return _tfa;
  }

  String get userName {
    return _userName;
  }

  String get email {
    return _email;
  }

  String get imageUrl {
    return _imageUrl;
  }

  String get dob {
    return _dob;
  }

  String get userCredential {
    return _userCredential;
  }

  bool get isAdminVerified {
    return _isAdminVerified;
  }

  String get contact {
    return _contact;
  }

  String get address {
    return _address;
  }

  Future<void> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then(
        (data) {
          SharedService.email = data['email'];
          SharedService.userName = data['userName'];
          SharedService.userImageUrl = data['imageUrl'];
          SharedService.dob = data['dob'];
          SharedService.userCredential = data['userCredential'];
          SharedService.isAdminVerified = data['isAdminVerified'];
          SharedService.contact = data['contact'];
          SharedService.address = data['address'];
          SharedService.isTFAO = data['tfa'];

          _userName = SharedService.userName;
          notifyListeners();
          _imageUrl = SharedService.userImageUrl;
          notifyListeners();
          _email = SharedService.email;
          notifyListeners();
          _dob = SharedService.dob;
          notifyListeners();
          _userCredential = SharedService.userCredential;
          notifyListeners();
          _isAdminVerified = SharedService.isAdminVerified;
          notifyListeners();
          _contact = SharedService.contact;
          notifyListeners();
          _address = SharedService.address;
          notifyListeners();
          _tfa = SharedService.isTFAO;
          notifyListeners();

          var role = data['role'];
          SharedService.role = role;
          if (role == 'Admin') {
            SharedService.isUserAdmin = true;
          } else {
            SharedService.isUserAdmin = false;
          }
        },
      );
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> switchTfa() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'tfa': !SharedService.isTFAO,
      });

      _tfa = !SharedService.isTFAO;
      notifyListeners();
      SharedService.isTFAO = !SharedService.isTFAO;
      notifyListeners();
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> updateProfile(String newUserName, String newUserImageUrl,
      String dob, String contact, String address) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userName': newUserName,
        'imageUrl': newUserImageUrl,
        'dob': dob,
        'contact': contact,
        'address': address,
      }).then((value) {
        SharedService.userName = newUserName;
        SharedService.userImageUrl = newUserImageUrl;
        SharedService.dob = dob;
        SharedService.contact = contact;
        SharedService.address = address;
        _userName = newUserName;
        notifyListeners();
        _imageUrl = newUserImageUrl;
        notifyListeners();
        _contact = contact;
        notifyListeners();
        _address = address;
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> updateUserCredential(String userCredential) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'userCredential': userCredential}).then((value) {
        _userCredential = userCredential;
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> deleteProfile() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }
}
