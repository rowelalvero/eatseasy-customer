import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchOrders.dart';
import 'package:eatseasy/models/client_orders.dart';
import 'package:eatseasy/views/orders/widgets/client_order_tile.dart';

import '../../../common/app_style.dart';
import '../../../common/reusable_text.dart';

class DeliveredOrders extends HookWidget {
  const DeliveredOrders({Key? key}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    final hookResult = useFetchClientOrders('orderStatus','Delivered');
    List<ClientOrders>? orders = hookResult.data;
    final isLoading = hookResult.isLoading;

    return isLoading
        ? const FoodsListShimmer()
        : orders!.isEmpty
        ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_content.png',
              height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
              width: MediaQuery.of(context).size.width * 0.5,   // 50% of screen width
              fit: BoxFit.contain,
            ),
            ReusableText(
              text:
              "Try to look for some awesome treats!",
              style: appStyle(14, kGray, FontWeight.normal),
            ),
          ],
        )
    )
        : Container(
      height: height / 1.3,
      width: width,
      color: kLightWhite,
      child: ListView.builder(
          padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            ClientOrders order = orders[i];
            return ClientOrderTile(order: order);
          }),
    );
  }
}
