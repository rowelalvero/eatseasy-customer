import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
// String googleApiKey = 'AIzaSyBCOoQR2ovyrYRTPbqMAO5H0SHVeLfSjeY';
// AIzaSyB4lViZNqNgOWIYse9C3MKxzgSSshF7St8

//const kPrimary = Color(0xFF30b9b2);
const kPrimary = Color(0xffF2C641);
const kPrimaryLight = Color(0xFFffff99);
const kSecondary = Color(0xffffa44f);
const kSecondaryLight = Color(0xFFffe5db);
const kTertiary = Color(0xff0078a6);
const kGray = Color(0xff83829A);
const kGrayLight = Color(0xffC1C0C8);
const kLightWhite = Color(0xffFAFAFC);
const kWhite = Color(0xfffFFFFF);
const kDark = Color(0xff000000);
const kRed = Color(0xffe81e4d);
const kOffWhite = Color(0xffF3F4F8);

double height = 825.h;
double width = 375.w;

double baseDeliveryFee = 20;
double pricePkm = 10;

const double kFontSizeH1 = 32.0; // Headline 1
const double kFontSizeH2 = 28.0; // Headline 2
const double kFontSizeH3 = 24.0; // Headline 3
const double kFontSizeH4 = 20.0; // Headline 4
const double kFontSizeBodyLarge = 18.0; // Large Body Text
const double kFontSizeBodyRegular = 16.0; // Regular Body Text
const double kFontSizeBodySmall = 14.0; // Small Body Text
const double kFontSizeSubtext = 12.0; // Subtext
const double kFontSizeCaption = 10.0; // Captions
const double kFontSizeButton = 16.0; // Button Text
const double kFontSizeLabel = 14.0; // Label Text
const double kFontSizeInput = 18.0; // Input Text

// const String {Environment.appBaseUrl} = "https://foodlybackend-production-4026.up.railway.app";
// const String {Environment.appBaseUrl} = "http://localhost:6003";

final List<String> verificationReasons = [
  'Real-time Updates: Get instant notifications about your order status.',
  'Direct Communication: A verified number ensures seamless communication.',
  'Enhanced Security: Protect your account and confirm orders securely.',
  'Effortless Rescheduling: Easily address issues with a quick call.',
  'Exclusive Offers: Stay in the loop for special deals and promotions.'
];

List<String> reasonsToAddAddress = [
  "Ensures that food orders are delivered accurately to the customer’s location.",
  "Allows users to check if the delivery service is available in their area.",
  "Provides a personalized experience by showing nearby restaurants, estimated delivery times, and special offers.",
  "Streamlines the checkout process by saving addresses for quicker order placement.",
  "Enables management of multiple addresses (e.g., home, work) for easy switching.",
];



