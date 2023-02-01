import 'package:google_maps_flutter/google_maps_flutter.dart';

class SharedService {
  static bool isUserAdmin = false;
  static String userName = '';
  static String email = '';
  static String userImageUrl = '';
  static String dob = '';
  static String contact = '';
  static String address = '';
  static String userCredential = '';
  static bool isAdminVerified = false;
  static String role = '';
  static bool isTFAO = false;
  static String otp = '';
  static LatLng currentPosition = const LatLng(0, 0);
}
