import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eatseasy/common/shimmers/foodlist_shimmer.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/hooks/fetchOrders.dart';
import 'package:eatseasy/models/client_orders.dart';
import 'package:eatseasy/views/orders/widgets/client_order_tile.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controllers/updates_controllers/preparing_controller.dart';

class PreparingOrders extends HookWidget {
  const PreparingOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreparingController());
    final hookResult = useFetchClientOrders('orderStatus', 'Preparing');
    List<ClientOrders>? orders = hookResult.data;
    final isLoading = hookResult.isLoading;
    final refetch = hookResult.refetch;

    controller.setOnStatusChangeCallback(refetch);

    return Container(
      height: height / 1.3,
      width: width,
      color: kLightWhite,
      child: isLoading
          ? const FoodsListShimmer()
          : ListView.builder(
              padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
              itemCount: orders!.length,
              itemBuilder: (context, i) {
                ClientOrders order = orders[i];
                return ClientOrderTile(order: order);
              }),
    );
  }
}
