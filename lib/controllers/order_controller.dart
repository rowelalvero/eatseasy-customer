// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eatseasy/constants/constants.dart';
import 'package:eatseasy/models/api_error.dart';
import 'package:eatseasy/models/environment.dart';
import 'package:eatseasy/models/order_item.dart';
import 'package:eatseasy/models/order_response.dart';
import 'package:eatseasy/models/payment_request.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../common/show_snack_bar.dart';
import '../models/order_details.dart';
import '../views/orders/payments/successful.dart';
import 'cart_controller.dart';

class OrderController extends GetxController {
  final box = GetStorage();
  final controller = Get.put(CartController());

  Order? order;
  GetOrder? getOrder;

  set setOrder(Order newValue) {
    order = newValue;
  }

  final RxString _paymentId = ''.obs;
  String get paymentId => _paymentId.value;
  set paymentId(String newValue) {
    _paymentId.value = newValue;
  }

  final RxString _paymentUrl = ''.obs;
  String get paymentUrl => _paymentUrl.value;
  set paymentUrl(String newValue) {
    _paymentUrl.value = newValue;
  }

  final RxString _orderId = ''.obs;
  String get orderId => _orderId.value;
  set orderId(String newValue) {
    _orderId.value = newValue;
  }

  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxBool _iconChanger = false.obs;
  bool get iconChanger => _iconChanger.value;
  set setIcon(bool newValue) {
    _iconChanger.value = newValue;
  }

  Rx<LatLng> _currentLocation = LatLng(0.0, 0.0).obs;
  LatLng get currentLocation => _currentLocation.value;
  void updateLocation(LatLng newLocation) {
    _currentLocation.value = newLocation;
  }

  RxString _orderStatus = ''.obs;
  String get orderStatus => _orderStatus.value;
  void updateOrderStatus(String newStatus) {
    _orderStatus.value = newStatus;
  }

  void createOrder(String order, Order item) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/orders');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: order,
      );

      if (response.statusCode == 201) {

        OrderResponse data = orderResponseFromJson(response.body);

        orderId = data.orderId;

        /*Get.snackbar("Order successfully created", data.message,
            icon: const Icon(Icons.money));

        Payment payment = Payment(userId: item.userId, cartItems: [
          CartItem(
              name: item.orderItems[0].foodId,
              id: orderId,
              price: item.grandTotal,
              quantity: 1,
              restaurantId: item.restaurantId)
        ]);*/

        if(item.paymentMethod == 'STRIPE') {
          await initiateUserPay(item.paymentMethod, orderId, double.tryParse(item.orderTotal)!, double.tryParse(item.grandTotal)!, item.restaurantId);
          /*String paymentData = paymentToJson(payment);
          paymentFunction(paymentData);*/
        } else {
          Get.to(const Successful());
        }

      } else {
        var data = apiErrorFromJson(response.body);

        Get.snackbar(
            data.message, "Failed to create an order, please try again",
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      setLoading = false;

      Get.snackbar(e.toString(), "Failed to create an order, please try again",
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  Future<void> initiateUserPay(String paymentMethod, String orderId, double orderTotal, double grandTotal, String restaurantId) async {
    setLoading = true;
    String? userId = box.read('userId');
    final sanitizedUserId = userId?.replaceAll('"', '').trim();
    String token = box.read('token');
    String accessToken = jsonDecode(token);
    var url = Uri.parse('${Environment.appBaseUrl}/api/orders/user-pay/$orderId/$sanitizedUserId');

    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "paymentMethod": paymentMethod,
          "orderTotal": orderTotal,
          "grandTotal": grandTotal,
          "restaurantId": restaurantId,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Order successfully created", "Please wait for your order to prepare",
            icon: const Icon(Icons.money));
        setLoading = false;
        Get.to(const Successful());
      } else {
        var data = apiErrorFromJson(response.body);
        showCustomSnackBar(data.message.toString(), title: "Failed to place the order");
        print(response.body.toString(),);
      }
    } catch (e) {
      setLoading = false;
      showCustomSnackBar(e.toString(), title: "Failed to accept the order");
      print(e.toString(),);
    } finally {
      setLoading = false;
    }

  }


  void paymentFunction(String payment) async {

    setLoading = true;
    var url = Uri.parse(
        '${Environment.paymentUrl}/stripe/create-checkout-session');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: payment,
      );

      if (response.statusCode == 200) {
        var urlData = jsonDecode(response.body);

        //paymentId = urlData['paymentId'];
        paymentUrl = urlData['url'];
      }
    } catch (e) {
      setLoading = false;
    } finally {
      setLoading = false;
    }
  }

  Future<void> getOrderDetails(String orderId) async {
    String accessToken =  box.read('token');
    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/orders/$orderId');
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        getOrder = getOrderFromJson(response.body);
        print("The order status! ${_orderStatus.value}");
      } else {
        var data = apiErrorFromJson(response.body);
        Get.snackbar(data.message, "Failed to login, please try again",
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      setLoading = false;
      debugPrint(e.toString());
    } finally {
      setLoading = false;
    }
  }
}
