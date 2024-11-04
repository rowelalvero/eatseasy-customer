import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/constants/uidata.dart';

class RestaurantOptions extends StatelessWidget {
  const RestaurantOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4, top: 10),
      height: 40,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: choicesList.length,
          itemBuilder: (context, index) {
            var options = choicesList[index];
            return Padding(
              padding:  const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding:  const EdgeInsets.symmetric(horizontal: 8),
                width: width * 0.22,
                height: 25.h,
                decoration: BoxDecoration(
                color: kLightWhite,
                borderRadius: BorderRadius.all(Radius.circular(8.w))
                ),
                child: Expanded(
                  child: ReusableText(
                      text: options['name'].toString(),
                      style: appStyle(12, kGray, FontWeight.normal)),
                ),
              ),
            );
          }),
    );
  }
}
