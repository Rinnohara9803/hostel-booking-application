import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../main.dart';

class Notifications {
  static void saveToken(String token, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('userTokens').doc(userId).set(
        {
          'token': token,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteToken(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('userTokens').doc(userId).set(
        {
          'token': '',
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> notifyHostelOwner(
      String title, String body, String ownerId) async {
    String token = '';

    try {
      await FirebaseFirestore.instance
          .collection('userTokens')
          .doc(ownerId)
          .get()
          .then((snapshot) {
        token = snapshot.data()!['token'];
        print('here is owner token');
        print(token);
        print(title);
        print(body);
      }).then((value) async {
        var response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAfcQK7wM:APA91bGedzsu0hK0e0K7daYpEoqaBMQyGY30svHFAhisTq3U58dF9j2fdGbmuPJK2DMPPlzQ7r_kXDbWW5yTorcO77pyLTLYmmix3CbP58-xUNeyTyA4sW_8e_knvwxWrOuNcqTJIqwh',
          },
          body: constructFCMPayload(
            token,
            title,
            body,
          ),
        );
        print(response.statusCode);
        var jsonData = jsonDecode(response.body);
        print(jsonData);
      });
    } catch (e) {
      print('ee');
      print(e.toString());
      return Future.error(e.toString());
    }
  }
}
