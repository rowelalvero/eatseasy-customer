import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:eatseasy/common/address_modal.dart';
import 'package:eatseasy/common/app_style.dart';
import 'package:eatseasy/common/custom_textfield.dart';
import 'package:eatseasy/common/not_found.dart';
import 'package:eatseasy/common/reusable_text.dart';
import 'package:eatseasy/common/show_snack_bar.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/controllers/cart_controller.dart';
import 'package:eatseasy/controllers/contact_controller.dart';
import 'package:eatseasy/controllers/counter_controller.dart';
import 'package:eatseasy/controllers/food_controller.dart';
import 'package:eatseasy/hooks/fetchRestaurant.dart';
import 'package:eatseasy/models/cart_request.dart';
import 'package:eatseasy/models/foods.dart';
import 'package:eatseasy/models/order_item.dart';
import 'package:eatseasy/models/response_model.dart';
import 'package:eatseasy/models/user_cart.dart';
import 'package:eatseasy/views/auth/login_page.dart';
import 'package:eatseasy/views/auth/phone_verification.dart';
import 'package:eatseasy/views/home/widgets/custom_btn.dart';
import 'package:eatseasy/views/message/chat/index.dart';
import 'package:eatseasy/views/message/index.dart';
import 'package:eatseasy/views/orders/orders_page.dart';
import 'package:eatseasy/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../hooks/fetchCart.dart';

class FoodPage extends StatefulHookWidget {
  const FoodPage({
    super.key,
    required this.food,
  });

  final Food food;

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final TextEditingController _preferences = TextEditingController();

  final CounterController counterController = Get.put(CounterController());
  final PageController _pageController = PageController();
  final ContactController _controller = Get.put(ContactController());

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<ResponseModel> loadData() async {
    //prepare the contact list for this user.
    //get the restaurant info from the firebase
    //get only one restaurant info
    return   _controller.asyncLoadSingleRestaurant();
  }

  void loadChatData ()async{
    ResponseModel response = await  loadData();
    if(response.isSuccess==false){
      showCustomSnackBar(response.message!);
    }
  }

  @override
  Widget build(BuildContext context)  {
    final box = GetStorage();
    var phone_verification = box.read('phone_verification');
    var address = box.read('default_address') ?? false;
    final foodController = Get.put(FoodController());
    final cartController = Get.put(CartController());
    foodController.loadAdditives(widget.food.additives);
    final hookResult = useFetchRestaurant(widget.food.restaurant);
    var restaurantData ;//= hookResult.data;
    final load = hookResult.isLoading;

    final cartHookResult = useFetchCart();
    final items = cartHookResult.data ?? [];
    final isLoading = cartHookResult.isLoading;

    List<double> foodPriceList = [];
    List<int> foodQuantityList = [];

    RxBool isThisProductInCart = false.obs;

    if (load == false) {
      restaurantData = hookResult.data;

      if (restaurantData != null) {
        // Encoding to JSON string
        String jsonString = jsonEncode(restaurantData);


        // Decoding the JSON string back to Map
        Map<String, dynamic> resData = jsonDecode(jsonString);

        // Assigning the restaurant ID to the controller state
        _controller.state.restaurantId.value = resData["owner"];

        // Load chat data
        loadChatData();
      } else {
        print("restaurantData is null");
      }
    }

    String? token = box.read('token');
    return load == true
        ? Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: LoadingAnimationWidget.threeArchedCircle(
                color: kSecondary,
                size: 35
              )
            ),
          )
        : Scaffold(
            backgroundColor: kLightWhite,
            body: ListView(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(25)),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 230.h,
                            child: PageView.builder(
                                itemCount: widget.food.imageUrl.length,
                                controller: _pageController,
                                onPageChanged: (i) {
                                  foodController.currentPage(i);
                                },
                                itemBuilder: (context, i) {
                                  return Container(
                                    height: 230.h,
                                    width: width,
                                    color: kLightWhite,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: widget.food.imageUrl[i],
                                    ),
                                  );
                                }),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.food.imageUrl.length,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        margin: EdgeInsets.all(4.h),
                                        width:
                                            foodController.currentPage == index
                                                ? 10
                                                : 8,
                                        // ignore: unrelated_type_equality_checks
                                        height:
                                            foodController.currentPage == index
                                                ? 10
                                                : 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: foodController.currentPage ==
                                                  index
                                              ? kSecondary
                                              : kGrayLight,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40.h,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(
                              Ionicons.chevron_back_circle,
                              color: kPrimary,
                              size: 38,
                            ),
                          ),
                          /*GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Entypo.share,
                              color: kPrimary,
                              size: 38,
                            ),
                          )*/
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 10,
                        right: 15,
                        child: CustomButton(
                            btnWidth: width / 7.5,
                            radius: 30,
                            color: kPrimary,
                            onTap: () async {
                              if(restaurantData==null){
                                Get.to(
                                        () =>  const NotFoundPage(
                                      text: "Can not open restaurant page",
                                    ),
                                    arguments: {});
                              }else{
                               ResponseModel status = await _controller.goChat(restaurantData);

                               if(status.isSuccess==false){
                                 showCustomSnackBar(status.message!, title: status.title!);
                               }
                              }

                            },
                            text: "Chat")
                    ),
                    Positioned(
                        bottom: 10,
                        right: 75,
                        child: CustomButton(
                            btnWidth: width / 2.9,
                            radius: 30,
                            color: kPrimary,
                            onTap: () {
                              if(token==null){
                                showCustomSnackBar("You are not logged in. Your distance measure is not correct", title: "Distance alert",);
                              }
                              Get.to(
                                  () => restaurantData == null
                                      ? const NotFoundPage(
                                          text: "Can not open restaurant page",
                                        )
                                      : RestaurantPage(
                                          restaurant: restaurantData));
                            },
                            text: "Open Restaurant"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(
                              text: widget.food.title,
                              style: appStyle(18, kDark, FontWeight.w600)),
                          ReusableText(
                              text:
                              "\$ ${widget.food.price.toStringAsFixed(2)}",
                              style: appStyle(18, kPrimary, FontWeight.w600)),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        widget.food.description,
                        maxLines: 8,
                        style: appStyle(10, kGray, FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(
                        height: 15.h,
                        child: ListView.builder(
                            itemCount: widget.food.foodTags.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              final tag = widget.food.foodTags[i];
                              return Container(
                                margin: EdgeInsets.only(right: 5.h),
                                decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.r))),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: ReusableText(
                                        text: tag,
                                        style: appStyle(
                                            8, kLightWhite, FontWeight.w400)),
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      ReusableText(
                          text: "Additives and Toppings",
                          style: appStyle(18, kDark, FontWeight.w600)),
                      Column(
                        children: List.generate(
                            foodController.additivesList.length, (i) {
                          final additive = foodController.additivesList[i];
                          return Obx(() => CheckboxListTile(
                                title: RowText(
                                    first: additive.title,
                                    second: "\$ ${additive.price}"),
                                contentPadding: EdgeInsets.zero,
                                value: additive.isChecked.value,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                onChanged: (bool? newValue) {
                                  additive.toggleChecked();
                                  foodController.getTotalPrice();
                                  foodController.getList();
                                },
                                activeColor: kPrimary,
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                tristate: false,
                              ));
                        }),
                      ),
                      ReusableText(
                          text: "Preferences",
                          style: appStyle(18, kDark, FontWeight.w600)),
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(
                        height: 64.h,
                        child: CustomTextField(
                            controller: _preferences,
                            hintText: "Add a note",
                            maxLines: 3,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a note";
                              }
                              return null;
                            }),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(
                              text: "Quantity",
                              style: appStyle(18, kDark, FontWeight.w600)),
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: counterController.increment,
                                  child: const Icon(
                                    AntDesign.plussquareo,
                                    color: kPrimary,
                                  )),
                              SizedBox(
                                width: 6.w,
                              ),
                              Obx(
                                () => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: ReusableText(
                                      text: "${counterController.count}",
                                      style:
                                          appStyle(16, kDark, FontWeight.w500)),
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              GestureDetector(
                                  onTap: counterController.decrement,
                                  child: const Icon(
                                    AntDesign.minussquareo,
                                    color: kPrimary,
                                  ))
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Obx(() =>Column(
            mainAxisSize: MainAxisSize.min,
            // Ensures the container takes only the space it needs
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50.h,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cartController.isLoading
                          ? Expanded(
                        flex: 3,
                        child: Center( // Center the loading animation
                          child: LoadingAnimationWidget.waveDots(
                            color: kSecondary,
                            size: 35
                          ),
                        ),
                      )
                          : Expanded(
                        //flex: 3,
                        child: Expanded(
                          child: Obx(() {
                            for (var cart in items) {
                              if (cart.productId.id == widget.food.id) {
                                isThisProductInCart.value = true;
                                foodPriceList.add(cart.totalPrice);
                                foodQuantityList.add(cart.quantity);
                              }
                            }

                            return ElevatedButton(
                              onPressed: () async {
                                cartController.setLoading = true; // Can be reactive, if needed
                                if (token == null) {
                                  Get.to(() => const Login());
                                } else {
                                  double totalPrice = (widget.food.price +
                                      foodController.additiveTotal) *
                                      counterController.count.toDouble();

                                  ToCart item = ToCart(
                                    productId: widget.food.id,
                                    instructions: _preferences.text,
                                    additives: foodController.getList(),
                                    quantity: counterController.count.toInt(),
                                    totalPrice: totalPrice,
                                    prepTime: widget.food.time,
                                    restaurant: widget.food.restaurant,
                                  );

                                  String cart = toCartToJson(item);

                                  await cartController.addToCart(cart);
                                  cartHookResult.refetch();
                                }

                                cartController.setLoading = false; // Can be reactive, if needed
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isThisProductInCart.value ? kPrimary : kGray,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 4,
                                shadowColor: Colors.grey.withOpacity(0.3),
                              ),
                              child: isThisProductInCart.value ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Text("Cart",style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600),),
                                      const Text("       •       ", style: TextStyle(color: kWhite)),
                                      Text("${foodQuantityList.first.toString()} ${foodQuantityList.first == 1 ? "item" : "items"} ", style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("\$ ${foodPriceList.first.toStringAsFixed(2)}",style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              )
                                  : const Text("Add to cart",style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                            );
                          }),
                        ),
                      ),
                      /*SizedBox(
                          width: 10.h,
                        ),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            onPressed: () {
                              LoadingAnimationWidget.waveDots(
                                color: kPrimary,
                                size: 35
                              );
                              if (token == null) {
                                Get.to(() => const Login());
                              } else {
                                // var user = controller.getUserData();
                                *//*if (phone_verification == false ||
                                  phone_verification == null) {
                                _showVerificationSheet(context);

                              } else*//*
                                if (address == false) {
                                  showAddressSheet(context);
                                } else {
                                  OrderItem orderItem = OrderItem(
                                    foodId: widget.food.id,
                                    additives: foodController.getList(),
                                    quantity: counterController.count.toString(),
                                    price: ((widget.food.price +
                                        foodController.additiveTotal) *
                                        counterController.count.toDouble())
                                        .toStringAsFixed(2),
                                    instructions: _preferences.text,

                                  );

                                  *//*Get.to(
                                          () => OrderPage(
                                        food: widget.food,
                                        restaurant: restaurantData,
                                        item: orderItem,
                                      ));*//*
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4,
                              shadowColor: Colors.grey.withOpacity(0.3),
                            ),
                            child: ReusableText(
                                text: "Place Order",
                                style:
                                appStyle(18, kLightWhite, FontWeight.w600)),
                          ),
                        ),*/
                    ],
                  ),
                ),
              ),
            ],
          ),)
        ),
        );
  }
  Future<dynamic> _showVerificationSheet(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        showDragHandle: true,
        barrierColor: kPrimary.withOpacity(0.2),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 500.h,
            width: width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/restaurant_bk.png",
                    ),
                    fit: BoxFit.fill),
                color: kOffWhite,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Padding(
              padding: EdgeInsets.all(8.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  ReusableText(
                      text: "Verify Your Phone Number",
                      style: appStyle(20, kPrimary, FontWeight.bold)),
                  SizedBox(
                      height: 250.h,
                      child: ListView.builder(
                          itemCount: verificationReasons.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                verificationReasons[index],
                                textAlign: TextAlign.justify,
                                style:
                                    appStyle(11, kGrayLight, FontWeight.normal),
                              ),
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: kPrimary,
                              ),
                            );
                          })),
                  SizedBox(
                    height: 20.h,
                  ),
                  CustomButton(
                      onTap: () {
                        Get.to(() => const PhoneVerificationPage());
                      },
                      btnHieght: 40.h,
                      text: "Verify Phone Number"),
                ],
              ),
            ),
          );
        });
  }
}
