// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/shimmers/nearby_shimmer.dart';
import 'package:eatseasy/controllers/location_controller.dart';
import 'package:eatseasy/hooks/fetchNearbyRestaurants.dart';
import 'package:eatseasy/models/restaurants.dart';
import 'package:eatseasy/views/home/widgets/restaurant_widget.dart';
import 'package:eatseasy/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../constants/constants.dart';
import '../../../controllers/address_controller.dart';
import '../../../models/distance_time.dart';
import '../../../services/distance.dart';

class NearbyRestaurants extends HookWidget {
  const NearbyRestaurants({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Get.put(UserLocationController());
    final controller = Get.put(AddressController());

    final hookResult = useFetchRestaurants();
    final restaurants = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    if (isLoading) {
      return const NearbyShimmer();
    }

    if (error != null) {
      return Center(child: Text('Error: ${error.toString()}'));
    }

    if (restaurants == null || restaurants.isEmpty) {
      return const Center(child: Text('No nearby restaurants found'));
    }

    return Container(
      padding: const EdgeInsets.only(left: 12, top: 10),
      height: 194.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          Restaurants restaurant = restaurants[index];
          Distance distanceCalculator = Distance();
          DistanceTime distanceTime = distanceCalculator.calculateDistanceTimePrice(
            controller.defaultAddress!.latitude,
            controller.defaultAddress!.longitude,
            restaurant.coords.latitude,
            restaurant.coords.longitude,
            35,
            pricePkm,
          );

          if (distanceTime.distance > 10.0) {
            return SizedBox.shrink();
          }
          return RestaurantWidget(
            image: restaurant.imageUrl!,
            title: restaurant.title!,
            time: restaurant.time,
            logo: restaurant.logoUrl!,
            ratingBarCount: restaurant.rating,
            rating: "${restaurant.ratingCount} reviews and ratings",
            onTap: () {
              location.setLocation(LatLng(restaurant.coords.latitude, restaurant.coords.longitude));
              Get.to(() => RestaurantPage(restaurant: restaurant));
            },
          );
        },
      ),
    );
  }
}

