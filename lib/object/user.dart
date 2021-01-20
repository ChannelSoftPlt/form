import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:my/shareWidget/snack_bar.dart';

class User {
  String name, email, phone, address, postcode, createAt;

  int orderTime;

  User(
      {this.name,
      this.email,
      this.phone,
      this.address,
      this.postcode,
      this.createAt,
      this.orderTime});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        orderTime: json['order_time'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        address: json['address'] as String,
        postcode: json['postcode'] as String,
        createAt: json['created_at'] as String,
        phone: json['phone'] as String);
  }

  openWhatsApp(phone, message, context) async {
    try {
      await FlutterOpenWhatsapp.sendSingleMessage(phone, message);
    } on Exception {
      CustomSnackBar.show(context, 'WhatsApp Not Found!');
    }
  }
}
