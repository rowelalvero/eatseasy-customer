import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchRecommendations.dart';
import 'package:eatseasy/models/foods.dart';
import 'package:eatseasy/views/food/widgets/food_tile.dart';

class Recommendations extends HookWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchRecommendations("1400", true);
    final foods = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    return Scaffold(
      backgroundColor: kLightWhite,
      appBar: AppBar(
        elevation: .4,
        centerTitle: true,
        backgroundColor: kLightWhite,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view),
          ),
        ],
        title: ReusableText(
          text: "Recommendations",
          style: appStyle(20, kDark, FontWeight.w400),
        ),
      ),
      body: isLoading
          ? const FoodsListShimmer()
          : error != null
          ? Center(child: Text('Error: ${error.toString()}'))
          : (foods == null || foods.isEmpty)
          ? const Center(child: Text('No recommendations available'))
          : RefreshIndicator(
        color: kPrimary,
        onRefresh: () async {
          // Trigger the refetch function to reload the recommendations
          refetch();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: foods.length,
            itemBuilder: (context, i) {
              Food food = foods[i];
              return FoodTile(food: food);
            },
          ),
        ),
      ),
    );
  }
}
