import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchAllNearbyRestaurants.dart';
import 'package:eatseasy/models/restaurants.dart';
import 'package:eatseasy/views/home/widgets/restaurant_tile.dart';

class AllNearbyRestaurants extends HookWidget {
  const AllNearbyRestaurants({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchAllRestaurants("");
    final restaurants = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    return Scaffold(
      backgroundColor: kLightWhite,
      appBar: AppBar(
        elevation: .4,
        backgroundColor: kLightWhite,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view),
          ),
        ],
        title: ReusableText(
          text: "Nearby Restaurants",
          style: appStyle(20, kDark, FontWeight.w400),
        ),
      ),
      body: isLoading
          ? const FoodsListShimmer()
          : error != null
          ? Center(child: Text('Error: ${error.toString()}'))
          : (restaurants == null || restaurants.isEmpty)
          ? const Center(child: Text('No nearby restaurants found'))
          : RefreshIndicator(
        color: kPrimary,
        onRefresh: () async {
          // Trigger the refetch function to reload the restaurant list
          refetch();
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: 12.w, vertical: 10.h),
          itemCount: restaurants.length,
          itemBuilder: (context, i) {
            Restaurants restaurant = restaurants[i];
            return RestaurantTile(restaurant: restaurant);
          },
        ),
      ),
    );
  }
}
