import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:my/shareWidget/snack_bar.dart';

class User {
  String name, email, phone;

  int orderTime;

  User({this.name, this.email, this.phone, this.orderTime});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        orderTime: json['order_time'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String);
  }

  openWhatsApp(phone, message, context) async {
    try {
      await FlutterOpenWhatsapp.sendSingleMessage(phone, message);
    } on Exception catch (e) {
      CustomSnackBar.show(context, 'WhatsApp Not Found!');
    }
  }
}
