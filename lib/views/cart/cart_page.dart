import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/custom_container.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchCart.dart';
import 'package:eatseasy/models/user_cart.dart';
import 'package:eatseasy/views/auth/widgets/login_redirect.dart';
import 'package:eatseasy/views/cart/widgets/cart_tile.dart';
import 'package:get_storage/get_storage.dart';

import '../../hooks/fetchAllNearbyRestaurants.dart';

class CartPage extends HookWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {

    final box = GetStorage();
    String? token = box.read('token');

    final hookResult = useFetchCart();
    final items = hookResult.data;
    final isLoading = hookResult.isLoading;

    final restoHookResult = useFetchAllRestaurants("41007428");
    final restaurants = restoHookResult.data;


    return token == null
        ? const LoginRedirection()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: kLightWhite,
        elevation: 0.3,
        title: Center(
          child: ReusableText(
              text: "Cart", style: appStyle(16, kDark, FontWeight.bold)),
        ),
      ),
      body: SafeArea(
        child: CustomContainer(
            containerContent: Column(
              children: [
                isLoading
                    ? const FoodsListShimmer()
                    : Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  width: width,
                  height: height,
                  color: kLightWhite,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: restaurants.length,
                      itemBuilder: (context, i) {
                        UserCart cart = items[i];
                        box.write("cart", items.length.toString());
                        return CartTile(item: cart, );
                      }),
                ),
              ],
            )),
      ),
    );
  }
}