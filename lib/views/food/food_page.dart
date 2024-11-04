import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
import 'package:eatseasy/models/response_model.dart';
import 'package:eatseasy/views/auth/login_page.dart';
import 'package:eatseasy/views/auth/phone_verification.dart';
import 'package:eatseasy/views/home/widgets/custom_btn.dart';
import 'package:eatseasy/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../hooks/fetchCart.dart';
import '../../models/obs_custom_additives.dart';

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
  final foodController = Get.put(FoodController());
  final TextEditingController _preferences = TextEditingController();
  final CounterController counterController = Get.put(CounterController());
  final PageController _pageController = PageController();
  final ContactController _controller = Get.put(ContactController());
  Map<String, dynamic> foodControlleruserResponses = {};
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
    final cartController = Get.put(CartController());
    //foodController.loadAdditives(widget.food.additives);
    foodController.loadCustomAdditives(widget.food.customAdditives);
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
    return load
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
                          Obx(() => ReusableText(
                              text: "\$ ${((widget.food.price + foodController.additiveTotalCustom) * counterController.count.toDouble()).toStringAsFixed(2)}",
                              style: appStyle(18, kPrimary, FontWeight.w600)),),

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
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: widget.food.rating!,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: kPrimary,
                            ),
                            itemCount: 5,
                            itemSize: 15.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ReusableText(
                              text: "${widget.food.ratingCount} reviews and ratings",
                              style: appStyle(9, kGray, FontWeight.w500)),
                        ],
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

                      // Adding a SizedBox with reduced height
                      ReusableText(
                        text: "Additives and Toppings",
                        style: appStyle(18, kDark, FontWeight.w600),
                      ),

                      Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: foodController.customAdditivesList.length,
                            itemBuilder: (context, index) {
                              final question = foodController.customAdditivesList[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.grey, // Set the color of the border
                                    width: 0.4, // Set the width of the border
                                  ),
                                ),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ReusableText(
                                        text: question.text,
                                        style: appStyle(16, kDark, FontWeight.w600),
                                      ),
                                      if (question.selectionType == "Select at least" ||
                                          question.selectionType == "Select at most" ||
                                          question.selectionType == "Select exactly") ...[
                                        Text(
                                          '${question.selectionType} ${question.selectionNumber} options.',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                      if (question.required) ...[
                                        const Text(
                                          "Required",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 16,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: _buildQuestionInput(question),
                                ),
                              );
                            },
                          ),
                        ],
                      ),


                      /*Column(
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
                                controlAffinity: ListTileControlAffinity.leading,
                                tristate: false,
                              ));
                        }),
                      ),*/
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
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min, // Ensures the container takes only the space it needs
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
                      child: Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: kSecondary,
                          size: 35,
                        ),
                      ),
                    )
                        : Expanded(
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
                                  foodController.additiveTotalCustom) *
                                  counterController.count.toDouble();

                              ToCart item = ToCart(
                                productId: widget.food.id,
                                instructions: _preferences.text,
                                //additives: foodController.getList(),
                                quantity: counterController.count.toInt(),
                                totalPrice: totalPrice,
                                prepTime: widget.food.time!,
                                restaurant: widget.food.restaurant!,
                                customAdditives: foodController.userResponses,
                              );

                              String cart = toCartToJson(item);

                              await cartController.addToCart(cart);
                              print(cart);
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
                          child: isThisProductInCart.value
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text("Cart", style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const Text("       •       ", style: TextStyle(color: kWhite)),
                                  Text("${foodQuantityList.first.toString()} ${foodQuantityList.first == 1 ? "item" : "items"} ", style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("\$ ${foodPriceList.first.toStringAsFixed(2)}", style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          )
                              : const Text("Add to cart", style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
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
  Widget _buildQuestionInput(ObsCustomAdditive question) {
    switch (question.type) {
      case 'Multiple Choice':
        return Column(
          children: question.options!.map((option) {
            // Access the 'optionName' and 'price' fields within the Map
            final optionText = option['optionName'] as String;
            final optionPrice = option['price'] != null ? '(\$${option['price']})' : '';

            return RadioListTile<String>(
              activeColor: kPrimary,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: Text('$optionText $optionPrice'),
              value: optionText,
              groupValue: foodController.userResponses[question.text],
              onChanged: (value) {
                setState(() {
                  foodController.userResponses[question.text] = value;
                  question.toggleChecked();
                  print("jkcacnlkadclka"+foodController.userResponses.toString());
                  foodController.getTotalPriceCustomAdditives();

                });
              },
            );
          }).toList(),
        );
      case 'Checkbox':
        return Column(
          children: question.options!.map((option) {
            final optionText = option['optionName'] as String;
            final optionPrice = option['price'] != null ? '(\$${option['price']})' : '';

            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: kPrimary,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              tristate: false,
              visualDensity: VisualDensity.compact,
              title: Text('$optionText $optionPrice'), // Display option with price
              value: foodController.userResponses[question.text]?.contains(optionText) ?? false,
              onChanged: (value) {
                setState(() {
                  final currentSelections = foodController.userResponses[question.text] ?? [];
                  print("jkcacnlkadclka"+foodController.userResponses.toString());
                  if (value == true) {
                    if (question.selectionType == 'Select at least' &&
                        currentSelections.length >= question.selectionNumber!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least ${question.selectionNumber} options.')),
                      );
                    } else if (question.selectionType == 'Select at most' &&
                        currentSelections.length >= question.selectionNumber!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You can select a maximum of ${question.selectionNumber} options.')),
                      );
                    } else if (question.selectionType == 'Select exactly' &&
                        currentSelections.length == question.selectionNumber!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You can select exactly ${question.selectionNumber} options.')),
                      );
                    } else {
                      foodController.userResponses[question.text] = [...currentSelections, optionText];
                    }
                  } else {
                    foodController.userResponses[question.text]?.remove(optionText);
                  }
                  question.toggleChecked();
                  foodController.getTotalPriceCustomAdditives(); // Ensure you call this after updating selections
                });
              },

            );
          }).toList(),
        );
      case 'Short Answer':
        return TextField(
          onChanged: (value) {
            foodController.userResponses[question.text] = value;
          },
        );
      case 'Paragraph':
        return TextField(
          maxLines: 3,
          onChanged: (value) {
            foodController.userResponses[question.text] = value;
          },
        );
      case 'Linear Scale':
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                question.maxScale!.toInt() - question.minScale!.toInt() + 1,
                    (index) => Text(
                  '${question.minScale!.toInt() + index}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Slider(
              value: foodController.userResponses[question.text] ?? question.minScale ?? 1.0,
              min: question.minScale ?? 1.0,
              max: question.maxScale ?? 10.0,
              divisions: (question.maxScale! - question.minScale!).toInt(),
              label: (foodController.userResponses[question.text]?.toInt()).toString(),
              onChanged: (value) {
                setState(() {
                  foodController.userResponses[question.text] = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(question.minScaleLabel ?? ''),
                Text(question.maxScaleLabel ?? ''),
              ],
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

}
