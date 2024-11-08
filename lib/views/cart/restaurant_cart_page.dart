import 'package:eatseasy/views/cart/widgets/restaurant_cart_tile.dart';
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
import 'package:get_storage/get_storage.dart';

import '../../hooks/fetchAllNearbyRestaurants.dart';
import '../../hooks/fetchDefaultAddress.dart';
import '../../models/restaurants.dart';

class RestaurantCartPage extends HookWidget {
  const RestaurantCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? accessToken = box.read("token");
    String? token = box.read('token');

    final hookResult = useFetchCart();
    final items = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;
    final refetch = hookResult.refetch;

    final restaurantHookResult = useFetchAllRestaurants("1400");
    final restaurants = restaurantHookResult.data ?? [];

    if (accessToken != null) {
      useFetchDefault(context, false);
    }
    useEffect(() {
      // Call refetch when the page is built
      refetch();
      return null; // No cleanup needed
    }, []);

    return token == null
        ? const LoginRedirection()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: kLightWhite,
        elevation: 0.3,
        title: Center(
          child: ReusableText(
            text: "Cart",
            style: appStyle(20, kDark, FontWeight.w400),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomContainer(
          containerContent: RefreshIndicator(
            color: kPrimary,
            onRefresh: () async {
              // Trigger refetch when the user pulls down to refresh
              refetch();
            },
            child: Column(
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
                      Restaurants restaurant = restaurants[i];

                      List<UserCart> matchingCarts = items.where((cart) => cart.restaurant == restaurant.id).toList();

                      if (matchingCarts.isNotEmpty) {
                        return RestaurantCartTile(restaurant: restaurant);
                      }

                      if (items.isEmpty) {
                        return Center(
                          child: Image.asset(
                            'assets/images/no_content.png',
                            height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                            width: MediaQuery.of(context).size.width * 0.5,   // 50% of screen width
                            fit: BoxFit.contain,
                          ),
                        );
                      }


                      return const SizedBox(); // Return empty widget if no match
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
