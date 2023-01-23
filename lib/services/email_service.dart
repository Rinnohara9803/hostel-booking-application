import 'dart:convert';
import 'dart:math';

import 'package:email_otp/email_otp.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<void> sendOtp(String email) async {
    EmailOTP myauth = EmailOTP();

    myauth.setConfig(
      appEmail: "hostelbookingapplication9803@gmail.com",
      appName: "Email OTP",
      userEmail: email,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    try {
      await myauth.sendOTP();
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  static Future<void> verifyOtp(String email, String otp) async {
    EmailOTP myauth = EmailOTP();

    myauth.setConfig(
      appEmail: "hostelbookingapplication9803@gmail.com",
      appName: "Email OTP",
      userEmail: email,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    try {
      if (await myauth.verifyOTP(otp: otp) == true) {
      } else {
        return Future.error('Otp validation failed!');
      }
    } catch (e) {
      return Future.error('Otp validation failed!');
    }
  }

  static Future<void> sendEmail({
    required String name,
    required String email,
  }) async {
    try {
      final random = Random();

      int next(int min, int max) => min + random.nextInt(max - min);
      int otp = next(100000, 999999);
      const serviceId = 'service_6yhkqag';
      const templateId = 'template_de9y3uy';
      const userId = '4fBfKASEVUpxuj995';
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      await http
          .post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'user_subject': 'Two-Factor Authentication',
              'to_user': name,
              'pin_code': otp,
              'to_email': email,
              'user_email': 'hostelbookingapplication9803@gmail.com'
            },
          },
        ),
      )
          .then((value) {
        SharedService.otp = otp.toString();
      });
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
