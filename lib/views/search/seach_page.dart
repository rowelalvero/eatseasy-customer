import 'package:eatseasy/views/search/resto_search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/custom_container.dart';
import 'package:eatseasy/common/custom_textfield.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/search_controller.dart';
import 'package:eatseasy/views/search/search_results.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(FoodSearchController());

    return Obx(() => Scaffold(
          appBar: AppBar(
            toolbarHeight: 74.h,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: kOffWhite,
            title: Padding(
              padding:  EdgeInsets.only(top: 12.h),

              child: Container(
                  height: 50, // Adjust the height as necessary
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Light grey background for text field
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: (text) {
                      searchController.searchFoods(text);
                      //searchController.searchRestaurants(text);
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter a location",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  )

              )
            ),
          ),
          body: CustomContainer(
              containerContent: Column(
            children: [
              /*searchController.isLoading
                  ? const FoodsListShimmer()
                  :  searchController.restaurantSearchResults == null
                  ? const LoadingWidget()
                  : const RestoSearchResults(),*/

              searchController.isLoading
                  ? const FoodsListShimmer()
                  :  searchController.foodSearchResults == null
                  ? const LoadingWidget()
                  : const SearchResults(),
            ],
          )),
        ));
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))
      ),
      child: Padding(
        padding:  EdgeInsets.only(bottom: 180.0.h),
        child: LottieBuilder.asset("assets/anime/delivery.json", width: width, height: height/2,),
      ),
    );
  }
}
