import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eatseasy/models/api_error.dart';
import 'package:eatseasy/models/cart_response.dart';
import 'package:eatseasy/models/environment.dart';
import 'package:eatseasy/views/entrypoint.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class CartController extends GetxController {
  final box = GetStorage();

  final _address = false.obs;
  bool get address => _address.value;
  set setAddress(bool newValue) {
    _address.value = newValue;
  }

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  Future<void> addToCart(String item) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/cart');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: item,
      );

      if (response.statusCode == 201) {

        CartResponse data = cartResponseFromJson(response.body);

        box.write("cart", jsonEncode(data.count));

        Get.snackbar("Product added successfully to cart",
            "You can now order multiple items via the cart",
            colorText: kDark,
            backgroundColor: kOffWhite,
            icon: const Icon(Icons.add_alert));

      } else {
        var data = apiErrorFromJson(response.body);

        Get.snackbar(data.message, "Failed to add address, please try again",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed to add address, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  void removeFormCart(String itemId) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);
    print("Attempting to remove item: $itemId");
    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/cart/delete/$itemId');

    try {
      var response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          }
      );

      if (response.statusCode == 200) {
        setLoading = false;
        CartResponse data = cartResponseFromJson(response.body);

        box.write("cart", jsonEncode(data.count));

        //Get.offAll(() =>  const MainScreen());
      } else {
        var data = apiErrorFromJson(response.body);

        Get.snackbar(data.message, "Failed to add address, please try again",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed to add address, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }
}
