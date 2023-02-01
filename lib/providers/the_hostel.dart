import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hostel_booking_application/models/review.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class TheHostel with ChangeNotifier {
  List<String> images;
  final String id;

  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  String name;
  String address;
  String city;
  int amount;
  String preference;
  String contact;
  String description;
  bool availabilityStatus;
  String petFriendly;
  String needToPaySecurityDeposit;
  String paymentOptions;
  String parkingForCar;
  String parkingForMotorcycle;
  String internetAvailability;
  double latitude;
  double longitude;
  List<Review> reviews;

  TheHostel({
    required this.images,
    required this.id,
    required this.ownerName,
    required this.ownerEmail,
    required this.name,
    required this.city,
    required this.address,
    required this.amount,
    required this.contact,
    required this.ownerId,
    required this.preference,
    required this.description,
    required this.availabilityStatus,
    required this.petFriendly,
    required this.needToPaySecurityDeposit,
    required this.paymentOptions,
    required this.parkingForCar,
    required this.parkingForMotorcycle,
    required this.internetAvailability,
    required this.latitude,
    required this.longitude,
    required this.reviews,
  });

  Future<void> postReview(Review review) async {
    try {
      await FirebaseFirestore.instance.collection('hostels').doc(id).update({
        'reviews': FieldValue.arrayUnion([
          {
            'id': review.id,
            'rating': review.rating,
            'review': review.review,
            'reviewer': review.reviewer,
            'image': review.image,
          }
        ])
      });
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeAvailabilityStatus(
      String id, bool newAvailabilityStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(id)
          .update({'availabilityStatus': newAvailabilityStatus});
      availabilityStatus = newAvailabilityStatus;
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHostelInfo(TheHostel theHostel) async {
    try {
      await FirebaseFirestore.instance.collection('hostels').doc(id).update({
        'id': theHostel.id,
        'ownerName': theHostel.ownerName,
        'ownerEmail': theHostel.ownerEmail,
        'name': theHostel.name,
        'city': theHostel.city,
        'address': theHostel.address,
        'amount': theHostel.amount,
        'contact': theHostel.contact,
        'ownerId': theHostel.ownerId,
        'preference': theHostel.preference,
        'description': theHostel.description,
        'availabilityStatus': theHostel.availabilityStatus,
        'petFriendly': theHostel.petFriendly,
        'needToPaySecurityDeposit': theHostel.needToPaySecurityDeposit,
        'paymentOptions': theHostel.paymentOptions,
        'parkingForCar': theHostel.parkingForCar,
        'parkingForMotorcycle': theHostel.parkingForMotorcycle,
        'internetAvailability': theHostel.internetAvailability,
        'latitude': theHostel.latitude,
        'longitude': theHostel.longitude,
        'reviews': theHostel.reviews
            .map((review) => {
                  'id': review.id,
                  'rating': review.rating,
                  'review': review.review,
                  'reviewer': review.reviewer,
                  'image': review.image,
                })
            .toList(),
      });
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHostelImages(List<String> newImages) async {
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(id)
          .update({'images': newImages}).then((value) {
        newImages = newImages;
        notifyListeners();
      });
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }
}
