import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hostel_booking_application/providers/the_user_provider.dart';

class UsersProvider with ChangeNotifier {
  List<TheUser> _users = [];

  List<TheUser> get users {
    return [..._users];
  }

  Future<void> fetchAllUsers() async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('users');
      List<TheUser> loadedUsers = [];

      await collectionRef.get().then((snapshot) {
        for (var user in snapshot.docs) {
          loadedUsers.add(
            TheUser(
              userId: user.data()['userId'],
              userName: user.data()['userName'],
              email: user.data()['email'],
              contact: user.data()['contact'],
              address: user.data()['address'],
              isAdminVerified: user.data()['isAdminVerified'],
              imageUrl: user.data()['imageUrl'],
              role: user.data()['role'],
              dob: user.data()['dob'],
              userCredential: user.data()['userCredential'],
            ),
          );
        }
      });
      _users = loadedUsers;
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
