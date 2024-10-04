// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/views/home/widgets/food_widget.dart';
import 'package:eatseasy/common/shimmers/nearby_shimmer.dart';
import 'package:eatseasy/hooks/fetchFoods.dart';
import 'package:eatseasy/models/foods.dart';
import 'package:eatseasy/views/food/food_page.dart';
import 'package:get/get.dart';

import '../../../constants/uidata.dart';
import '../../../controllers/address_controller.dart';
import '../../../hooks/fetchNearbyRestaurants.dart';
import '../../../models/distance_time.dart';
import '../../../models/restaurants.dart';
import '../../../services/distance.dart';

class FoodList extends HookWidget {
  const FoodList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    // Fetching foods data
    final hookResult = useFetchFood();
    final foods = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    // Fetching restaurants data (even if not used currently)
    final hookRestaurantResult = useFetchRestaurants();
    final restaurants = hookRestaurantResult.data;

    if (isLoading) {
      return const NearbyShimmer();
    }

    if (error != null) {
      return Center(child: Text('Error: ${error.toString()}'));
    }

    if (foods == null || foods.isEmpty) {
      return Center(child: Text('No foods available'));
    }

    return Container(
      padding: const EdgeInsets.only(left: 12, top: 10),
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: foods.length,
        itemBuilder: (context, index) {
          Food food = foods[index];

          // You can uncomment and use the DistanceTime logic if needed
          /*
          Restaurants restaurant = restaurants[index];
          DistanceTime distanceTime = Distance().calculateDistanceTimePrice(
            controller.defaultAddress!.latitude,
            controller.defaultAddress!.longitude,
            restaurant.coords.latitude,
            restaurant.coords.longitude,
            10,
            2.00
          );

          if (distanceTime.distance > 10.0) {
            return Center(child: Text("No data"));
          }
          */

          return FoodWidget(
            onTap: () {
              Get.to(() => FoodPage(food: food));
            },
            image: food.imageUrl[0],  // Assumes there's always at least one image
            title: food.title,
            price: food.price.toStringAsFixed(2),
            time: food.time,
          );
        },
      ),
    );
  }
}

