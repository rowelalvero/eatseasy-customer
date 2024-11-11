// To parse this JSON data, do
//
//     final registration = registrationFromJson(jsonString);

import 'dart:convert';

Registration registrationFromJson(String str) => Registration.fromJson(json.decode(str));

String registrationToJson(Registration data) => json.encode(data.toJson());

class Registration {
    final String username;
    final String validIdUrl;
    final String proofOfResidenceUrl;
    final String email;
    final String password;

    Registration({
        required this.username,
        required this.validIdUrl,
        required this.proofOfResidenceUrl,
        required this.email,
        required this.password,
    });

    factory Registration.fromJson(Map<String, dynamic> json) => Registration(
        username: json["username"],
        validIdUrl: json["validIdUrl"],
        proofOfResidenceUrl: json["proofOfResidenceUrl"],
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "validIdUrl": validIdUrl,
        "proofOfResidenceUrl": proofOfResidenceUrl,
        "email": email,
        "password": password,
    };
}
