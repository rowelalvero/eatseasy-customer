import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/custom_container.dart';
import 'package:eatseasy/common/customer_service.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/feedback_controller.dart';
import 'package:eatseasy/controllers/login_controller.dart';
import 'package:eatseasy/hooks/fetchServiceNumber.dart';
import 'package:eatseasy/models/login_response.dart';
import 'package:eatseasy/views/auth/widgets/login_redirect.dart';
import 'package:eatseasy/views/message/index.dart';
import 'package:eatseasy/views/orders/client_orders.dart';
import 'package:eatseasy/views/profile/saved_places.dart';
import 'package:eatseasy/views/profile/widgets/profile_appbar.dart';
import 'package:eatseasy/views/profile/widgets/tile_widget.dart';
import 'package:eatseasy/views/reviews/rating_review_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final upload = Get.put(UserFeedBackController());
    LoginResponse? user;
    final box = GetStorage();
    String? token = box.read('token');

    final controller = Get.put(LoginController());

    if (token != null) {
      user = controller.getUserData();
    }

    final serviceNumber = useFetchCustomerService();

    return token == null
        ? const LoginRedirection()
        : Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(50.h),
                child: const ProfileAppBar()),
            body: SafeArea(
              child: CustomContainer(
                  containerContent: Column(
                children: [
                  Container(
                    height: height * 0.06,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12.0, 0, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    width: 35,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      backgroundImage:
                                      NetworkImage(user!.profile),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: appStyle(
                                              12, kGray, FontWeight.w600),
                                        ),
                                        Text(
                                          user.email,
                                          style: appStyle(
                                              11, kGray, FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12.0.h),
                                    child: const Icon(Feather.edit, size: 18),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 100.h,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TilesWidget(
                          onTap: () {
                            Get.to(() => const ClientOrderPage());
                          },
                          title: "My Orders",
                          leading: Feather.shopping_cart,
                        ),
                        TilesWidget(
                          onTap: () {
                            Get.to(() => const RatingReview());
                          },
                          title: "Reviews and rating",
                          leading: Feather.message_circle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 150.h,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TilesWidget(
                          onTap: () {
                            Get.to(() => SavedPlaces());
                          },
                          title: "Shipping addresses",
                          leading: Feather.map_pin,
                        ),
                        TilesWidget(
                          onTap: () {
                            customerService(context, serviceNumber);
                          },
                          title: "Service Center",
                          leading: AntDesign.customerservice,
                        ),
                        TilesWidget(
                          title: "App Feedback",
                          leading: Feather.pen_tool,
                          onTap: () {
                            BetterFeedback.of(context)
                                .show((UserFeedback feedback) async {
                              var url = feedback.screenshot;
                              upload.feedbackFile.value = await upload
                                  .writeBytesToFile(url, "feedback");

                              String message = feedback.text;
                              upload.uploadImageToFirebase(message);
                            });
                          },
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 45.h,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TilesWidget(
                          onTap: () {
                            Get.to(() => const MessagePage());
                          },
                          title: "Chats",
                          leading: Feather.message_square,
                        ),


                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 45.h,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TilesWidget(
                          onTap: () {
                            controller.logout();
                          },
                          title: "Log out",
                          leading: Feather.log_out,
                        ),


                      ],
                    ),
                  ),
                ],
              )),
            ),
          );
  }
}
