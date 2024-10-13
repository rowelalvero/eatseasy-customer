import 'package:flutter/material.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/views/reviews/widgets/orders_to_rate.dart';

class RatingReview extends StatelessWidget {
  const RatingReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: kLightWhite,
          elevation: 0,
          title: ReusableText(
            text: "Reviews and Ratings",
            style: appStyle(20, kDark, FontWeight.w400),
          ),),
      body: const RateOrders(),
    );
  }
}