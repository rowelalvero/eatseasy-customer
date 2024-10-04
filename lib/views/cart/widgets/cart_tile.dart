import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/cart_controller.dart';
import 'package:eatseasy/models/user_cart.dart';
import 'package:get/get.dart';

class CartTile extends HookWidget {
  const CartTile({
    super.key,
    required this.item,
    
  });

  final UserCart item;


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 80,
          width: width,
          decoration: const BoxDecoration(
              color: kOffWhite,
              borderRadius: BorderRadius.all(Radius.circular(9))),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Stack(
                    children: [
                      SizedBox(
                          height: 75.h,
                          width: 75.h,
                          child: Image.network(
                            item.productId.imageUrl[0],
                            fit: BoxFit.cover,
                          )),

                      Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.only(left: 6, bottom: 2),
                            color: kGray.withOpacity(0.6),
                            height: 16,
                            width: width,
                            child: RatingBarIndicator(
                              rating: item.productId.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 15.0,
                              direction: Axis.horizontal,
                            ),
                          ))
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: width * 0.53,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      ReusableText(
                          text: item.productId.title,
                          style: appStyle(11, kDark, FontWeight.w400)),
                      ReusableText(
                          text:
                              "Delivery time: ${item.productId.restaurant.time}",
                          style: appStyle(9, kGray, FontWeight.w400)),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 18,
                        width: width * 0.67,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: item.additives.length,
                            itemBuilder: (context, i) {
                              final addittive = item.additives[i];
                              return Container(
                                margin: const EdgeInsets.only(right: 5),
                                decoration: const BoxDecoration(
                                    color: kSecondaryLight,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9))),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ReusableText(
                                        text: addittive,
                                        style:
                                            appStyle(8, kGray, FontWeight.w400)),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: 10.w,
          top: 6.h,
          child: Container(
            width: 60.h,
            height: 19.h,
            decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
            child: Center(
              child: ReusableText(
                text: "\$ ${item.totalPrice.toStringAsFixed(2)}",
                style: appStyle(12, kLightWhite, FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
            right: 75.h,
            top: 6.h,
            child: Container(
              width: 19.h,
              height: 19.h,
              decoration: const BoxDecoration(
                  color: kSecondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: GestureDetector(
                onTap: () {
                  controller.removeFormCart(item.id);
                  
                },
                child: const Center(
                  child: Icon(
                    MaterialCommunityIcons.delete,
                    size: 15,
                    color: kLightWhite,
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
