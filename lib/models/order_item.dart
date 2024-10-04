import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    final String userId;
    final List<OrderItem> orderItems;
    final String orderTotal;
    final String restaurantAddress;
    final List<double> restaurantCoords;
    final List<double> recipientCoords;
    final String deliveryFee;
    final String grandTotal;
    final String deliveryAddress;
    final String paymentMethod;
    final String restaurantId;

    Order({
        required this.userId,
        required this.orderItems,
        required this.orderTotal,
        required this.restaurantAddress,
        required this.restaurantCoords,
        required this.recipientCoords,
        required this.deliveryFee,
        required this.grandTotal,
        required this.deliveryAddress,
        required this.paymentMethod,
        required this.restaurantId,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        userId: json["userId"],
        orderItems: List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x))),
        orderTotal: json["orderTotal"],
        restaurantAddress: json["restaurantAddress"],
        restaurantCoords: List<double>.from(json["restaurantCoords"].map((x) => x?.toDouble())),
        recipientCoords: List<double>.from(json["recipientCoords"].map((x) => x?.toDouble())),
        deliveryFee: json["deliveryFee"],
        grandTotal: json["grandTotal"],
        deliveryAddress: json["deliveryAddress"],
        paymentMethod: json["paymentMethod"],
        restaurantId: json["restaurantId"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "orderTotal": orderTotal,
        "restaurantAddress": restaurantAddress,
        "restaurantCoords": List<dynamic>.from(restaurantCoords.map((x) => x)),
        "recipientCoords": List<dynamic>.from(recipientCoords.map((x) => x)),
        "deliveryFee": deliveryFee,
        "grandTotal": grandTotal,
        "deliveryAddress": deliveryAddress,
        "paymentMethod": paymentMethod,
        "restaurantId": restaurantId,
    };
}

class OrderItem {
    final String foodId;
    final List<String> additives;
    final String quantity;
    final String price;
    final String instructions;

    OrderItem({
        required this.foodId,
        required this.additives,
        required this.quantity,
        required this.price,
        required this.instructions,
    });

    factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        foodId: json["foodId"],
        additives: List<String>.from(json["additives"].map((x) => x)),
        quantity: json["quantity"],
        price: json["price"],
        instructions: json["instructions"],
    );

    Map<String, dynamic> toJson() => {
        "foodId": foodId,
        "additives": List<dynamic>.from(additives.map((x) => x)),
        "quantity": quantity,
        "price": price,
        "instructions": instructions,
    };
}
