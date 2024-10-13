import 'dart:convert';

ToCart toCartFromJson(String str) => ToCart.fromJson(json.decode(str));

String toCartToJson(ToCart data) => json.encode(data.toJson());

class ToCart {
    final String productId;
    final String instructions;
    final List<String> additives;
    final int quantity;
    final double totalPrice;
    final String prepTime;
    final String restaurant;

    ToCart({
        required this.productId,
        required this.instructions,
        required this.additives,
        required this.quantity,
        required this.totalPrice,
        required this.prepTime,
        required this.restaurant,
    });

    factory ToCart.fromJson(Map<String, dynamic> json) => ToCart(
        productId: json["productId"],
        instructions: json["instructions"],
        additives: List<String>.from(json["additives"].map((x) => x)),
        quantity: json["quantity"],
        totalPrice: json["totalPrice"]?.toDouble(),
        prepTime: json["prepTime"],
        restaurant: json["restaurant"],
    );

    Map<String, dynamic> toJson() => {
        "productId": productId,
        "instructions": instructions,
        "additives": List<dynamic>.from(additives.map((x) => x)),
        "quantity": quantity,
        "totalPrice": totalPrice,
        "prepTime": prepTime,
        "restaurant": restaurant
    };
}
