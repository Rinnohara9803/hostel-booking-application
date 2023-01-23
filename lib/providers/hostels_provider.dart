import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hostel_booking_application/models/review.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';

class HostelsProvider with ChangeNotifier {
  List<TheHostel> _hostels = [];

  List<TheHostel> get hostels {
    return [..._hostels];
  }

  List<TheHostel> _myHostels = [];

  List<TheHostel> get myHostels {
    return [..._myHostels];
  }

  List<TheHostel> _hostelsByNameSearch = [];

  List<TheHostel> get hostelsByNameSearch {
    return [..._hostelsByNameSearch];
  }

  List<TheHostel> _hostelsByAddressSearch = [];

  List<TheHostel> get hostelsByAddressSearch {
    return [..._hostelsByAddressSearch];
  }

  TheHostel? _hostelById;

  TheHostel? get hostelById {
    return _hostelById;
  }

  Future<void> updateReview(Review newReview, String hostelId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .get()
          .then((data) {
        List<Review> theReviews = [];
        List<String> reviewIds = [];
        Review? myReview;
        for (var j in data['reviews']) {
          theReviews.add(
            Review(
              id: j['id'],
              rating: double.parse(j['rating'].toString()),
              review: j['review'],
              reviewer: j['reviewer'],
              image: j['image'],
            ),
          );
        }

        for (var j in theReviews) {
          reviewIds.add(j.id);
        }

        if (reviewIds.contains(userId)) {
          myReview = theReviews.firstWhere((review) => review.id == userId);
          FirebaseFirestore.instance
              .collection('hostels')
              .doc(hostelId)
              .update({
            'reviews': FieldValue.arrayRemove([
              {
                'id': myReview.id,
                'rating': myReview.rating,
                'review': myReview.review,
                'reviewer': myReview.reviewer,
                'image': myReview.image,
              }
            ])
          }).then((_) async {
            await FirebaseFirestore.instance
                .collection('hostels')
                .doc(hostelId)
                .update({
              'reviews': FieldValue.arrayUnion([
                {
                  'id': newReview.id,
                  'rating': newReview.rating,
                  'review': newReview.review,
                  'reviewer': newReview.reviewer,
                  'image': newReview.image,
                }
              ])
            });
          });
        } else {
          FirebaseFirestore.instance
              .collection('hostels')
              .doc(hostelId)
              .update({
            'reviews': FieldValue.arrayUnion([
              {
                'id': newReview.id,
                'rating': newReview.rating,
                'review': newReview.review,
                'reviewer': newReview.reviewer,
                'image': newReview.image,
              }
            ])
          });
        }
      });
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String hostelId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .get()
          .then((data) {
        List<Review> theReviews = [];
        List<String> reviewIds = [];
        Review? myReview;
        for (var j in data['reviews']) {
          theReviews.add(
            Review(
              id: j['id'],
              rating: double.parse(j['rating'].toString()),
              review: j['review'],
              reviewer: j['reviewer'],
              image: j['image'],
            ),
          );
        }

        for (var j in theReviews) {
          reviewIds.add(j.id);
        }

        myReview = theReviews.firstWhere((review) => review.id == userId);
        FirebaseFirestore.instance.collection('hostels').doc(hostelId).update({
          'reviews': FieldValue.arrayRemove([
            {
              'id': myReview.id,
              'rating': myReview.rating,
              'review': myReview.review,
              'reviewer': myReview.reviewer,
              'image': myReview.image,
            }
          ])
        });
      });
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addHostel(TheHostel theHostel) async {
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(theHostel.id)
          .set({
        'images': theHostel.images,
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
        'availabilityStatus': true,
        'petFriendly': theHostel.petFriendly,
        'needToPaySecurityDeposit': theHostel.needToPaySecurityDeposit,
        'paymentOptions': theHostel.paymentOptions,
        'parkingForCar': theHostel.parkingForCar,
        'parkingForMotorcycle': theHostel.parkingForMotorcycle,
        'internetAvailability': theHostel.internetAvailability,
        'reviews': [],
      });
      _myHostels.add(theHostel);
      notifyListeners();
      _hostels.add(theHostel);
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet Connection.');
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchAllHostels() async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('hostels');
      List<TheHostel> loadedHostels = [];

      await collectionRef.get().then((snapshot) {
        List<String> imageNames = [];
        List<Review> theReviews = [];

        for (var hostel in snapshot.docs) {
          for (var i in hostel.data()['images']) {
            imageNames.add(i);
          }
          for (var j in hostel.data()['reviews']) {
            theReviews.add(
              Review(
                id: j['id'],
                rating: double.parse(j['rating'].toString()),
                review: j['review'],
                reviewer: j['reviewer'],
                image: j['image'],
              ),
            );
          }
          loadedHostels.add(
            TheHostel(
              images: imageNames,
              id: hostel.data()['id'],
              name: hostel.data()['name'],
              ownerName: hostel.data()['ownerName'],
              ownerEmail: hostel.data()['ownerEmail'],
              city: hostel.data()['city'],
              address: hostel.data()['address'],
              amount: hostel.data()['amount'],
              contact: hostel.data()['contact'],
              ownerId: hostel.data()['ownerId'],
              preference: hostel.data()['preference'],
              description: hostel.data()['description'],
              availabilityStatus: hostel.data()['availabilityStatus'],
              petFriendly: hostel.data()['petFriendly'],
              needToPaySecurityDeposit:
                  hostel.data()['needToPaySecurityDeposit'],
              paymentOptions: hostel.data()['paymentOptions'],
              parkingForCar: hostel.data()['parkingForCar'],
              parkingForMotorcycle: hostel.data()['parkingForMotorcycle'],
              internetAvailability: hostel.data()['internetAvailability'],
              reviews: theReviews,
            ),
          );
          imageNames = [];
          theReviews = [];
        }
      });
      _hostels = loadedHostels;
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet Connection.');
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchHostelsByNameSearch(String hostelName) async {
    try {
      _hostelsByNameSearch = _hostels.where((hostel) {
        final hostelTitle = hostel.name.toLowerCase();
        final searchInput = hostelName.toLowerCase();
        return hostelTitle.contains(searchInput);
      }).toList();
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchHostelsByAddressSearch(String hostelAddress) async {
    try {
      _hostelsByAddressSearch = _hostels.where((hostel) {
        final hostelTitle = hostel.address.toLowerCase();
        final searchInput = hostelAddress.toLowerCase();
        return hostelTitle.contains(searchInput);
      }).toList();
      notifyListeners();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchMyHostels() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    try {
      var collectionRef = FirebaseFirestore.instance.collection('hostels');
      List<TheHostel> loadedHostels = [];

      await collectionRef.get().then((snapshot) {
        List<String> imageNames = [];
        List<Review> theReviews = [];

        for (var hostel in snapshot.docs) {
          for (var i in hostel.data()['images']) {
            imageNames.add(i);
          }
          for (var j in hostel.data()['reviews']) {
            theReviews.add(
              Review(
                id: j['id'],
                rating: double.parse(j['rating'].toString()),
                review: j['review'],
                reviewer: j['reviewer'],
                image: j['image'],
              ),
            );
          }
          loadedHostels.add(
            TheHostel(
              images: imageNames,
              id: hostel.data()['id'],
              name: hostel.data()['name'],
              ownerName: hostel.data()['ownerName'],
              ownerEmail: hostel.data()['ownerEmail'],
              city: hostel.data()['city'],
              address: hostel.data()['address'],
              amount: hostel.data()['amount'],
              contact: hostel.data()['contact'],
              ownerId: hostel.data()['ownerId'],
              preference: hostel.data()['preference'],
              description: hostel.data()['description'],
              availabilityStatus: hostel.data()['availabilityStatus'],
              petFriendly: hostel.data()['petFriendly'],
              needToPaySecurityDeposit:
                  hostel.data()['needToPaySecurityDeposit'],
              paymentOptions: hostel.data()['paymentOptions'],
              parkingForCar: hostel.data()['parkingForCar'],
              parkingForMotorcycle: hostel.data()['parkingForMotorcycle'],
              internetAvailability: hostel.data()['internetAvailability'],
              reviews: theReviews,
            ),
          );
          imageNames = [];
          theReviews = [];
        }
      });
      _hostels = loadedHostels;
      notifyListeners();
      _myHostels =
          _hostels.where((hostel) => hostel.ownerId == userId).toList();
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet Connection.');
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> fetchHostelDetailsById(String id) async {
    try {
      TheHostel? loadedHostel;

      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(id)
          .get()
          .then((data) {
        List<String> imageNames = [];
        List<Review> theReviews = [];

        for (var i in data['images']) {
          imageNames.add(i);
        }
        for (var j in data['reviews']) {
          theReviews.add(
            Review(
              id: j['id'],
              rating: double.parse(j['rating'].toString()),
              review: j['review'],
              reviewer: j['reviewer'],
              image: j['image'],
            ),
          );
        }

        loadedHostel = TheHostel(
          images: imageNames,
          id: data['id'],
          name: data['name'],
          ownerName: data['ownerName'],
          ownerEmail: data['ownerEmail'],
          city: data['city'],
          address: data['address'],
          amount: data['amount'],
          contact: data['contact'],
          ownerId: data['ownerId'],
          preference: data['preference'],
          description: data['description'],
          availabilityStatus: data['availabilityStatus'],
          petFriendly: data['petFriendly'],
          needToPaySecurityDeposit: data['needToPaySecurityDeposit'],
          paymentOptions: data['paymentOptions'],
          parkingForCar: data['parkingForCar'],
          parkingForMotorcycle: data['parkingForMotorcycle'],
          internetAvailability: data['internetAvailability'],
          reviews: theReviews,
        );
      });
      _hostelById = loadedHostel;
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet Connection.');
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> deleteHostelById(TheHostel hostel) async {
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostel.id)
          .delete();

      _hostels.remove(hostel);
      notifyListeners();
      _myHostels.remove(hostel);
      notifyListeners();
    } on SocketException {
      return Future.error('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }
}
