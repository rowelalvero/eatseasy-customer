// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/phone_verification_controller.dart';

import 'package:eatseasy/services/verification.dart';

import 'package:get/get.dart';
import 'package:phone_otp_verification/phone_verification.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final AuthService _authService = AuthService();

  String _verificationId = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneVerificationController());
    return Obx(() => controller.isLoading == false ? PhoneVerification(
      isFirstPage: false,
      enableLogo: false,
      themeColor: kPrimary,
      initialPageText: "EatsEasy Phone Verification",
      initialPageTextStyle: appStyle(20, kPrimary, FontWeight.bold),
      textColor: kDark,
      onSend: (String value) {
        _verifyPhoneNumber(value);
      },
      onVerification: (String value) {
        if (_verificationId != '') {
          _submitVerificationCode(value);
        }
      },
    ): Container(
      width: width,
      height: hieght,
      color: kLightWhite,
      child: const Center(
        child: CircularProgressIndicator(
          color: kPrimary,
        ),
      ),
    ));
  }

  // Function to trigger phone verification
  void _verifyPhoneNumber(String phoneNumber) async {
    final controller = Get.put(PhoneVerificationController());
    controller.phoneNumber = phoneNumber;

    await _authService.verifyPhoneNumber(
      controller.phoneNumber,
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // Function to submit the verification code
  void _submitVerificationCode(String code) async {
    await _authService.verifySmsCode(_verificationId, code);
  }
}
