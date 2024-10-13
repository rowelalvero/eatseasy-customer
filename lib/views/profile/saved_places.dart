import 'package:eatseasy/views/profile/widgets/address_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchAddresses.dart';
import 'package:eatseasy/models/all_addresses.dart';
import 'package:eatseasy/views/profile/add_new_place.dart';
import 'package:eatseasy/views/profile/widgets/addresses_list.dart';
import 'package:get/get.dart';

import '../../common/custom_container.dart';

class SavedPlaces extends HookWidget {
  const SavedPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchAdresses();
    final List<AddressesList> addresses = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;
    final refetch = hookResult.refetch;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(CupertinoIcons.back),
        ),
        centerTitle: true,
        title: ReusableText(
          text: "Saved Places",
          style: appStyle(20, kDark, FontWeight.w400),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger refetch when the user pulls down to refresh
            refetch();
          },
          child: isLoading
              ? const FoodsListShimmer()
              : CustomContainer(
            containerContent: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              width: width,
              decoration: const BoxDecoration(
                color: kOffWhite,
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(), // Make the list scrollable
                padding: EdgeInsets.zero,
                itemCount: addresses.length,
                itemBuilder: (context, i) {
                  AddressesList address = addresses[i];
                  return AddressTile(
                    address: address,
                    refetch: refetch, // Pass the refetch function
                  );
                },
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                // Navigate to AddNewPlace and wait for the result
                final result = await Get.to(() => const AddNewPlace());

                // If the result indicates that changes were made, trigger refetch
                if (result == true) {
                  refetch();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: kDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  ReusableText(
                    text: "Choose from Map",
                    style: appStyle(15, kDark, FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}