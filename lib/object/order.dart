import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:intl/intl.dart';
import 'package:my/shareWidget/snack_bar.dart';

class Order {
  String orderID,
      date = '',
      name,
      email,
      phone,
      address,
      postcode,
      state,
      city,
      status,
      note,
      tax,
      extraNote,
      paymentMethod,
      userDeviceType,
      publicUrl,
      groupName,
      driverName,
      deliveryFee;

  int id, formId, orderGroupId, driverId;
  double total;
  final dateFormat = DateFormat("dd MMM");

  Order(
      {this.id,
      this.formId,
      this.orderID,
      this.date,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.postcode,
      this.city,
      this.state,
      this.note,
      this.status,
      this.total,
      this.tax,
      this.deliveryFee,
      this.extraNote,
      this.paymentMethod,
      this.userDeviceType,
      this.orderGroupId,
      this.driverId,
      this.driverName,
      this.groupName,
      this.publicUrl});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['order_id'] as int,
        formId: json['form_id'] as int,
        orderID: json['invoice_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        address: json['address'] as String,
        postcode: json['postcode'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        date: json['created_at'] as String,
        publicUrl: json['public_url'] as String,
        deliveryFee: json['delivery_fee'] as String,
        tax: json['tax'] == '' ? '0.00' : json['tax'] as String,
        orderGroupId: json['order_group_id'] as int,
        groupName: json['group_name'] as String,
        driverId: json['driver_id'] as int,
        driverName: json['driver_name'] as String,
        total: checkDouble(json['total_amount']),
        status: json['status'] as String);
  }

  static double checkDouble(num value) {
    return value is double ? value : value.toDouble();
  }

  String orderPrefix(orderID) {
    String prefix = '';
    for (int i = orderID.length; i < 5; i++) {
      prefix = prefix + "0";
    }
    return '#' + prefix + orderID;
  }

  String formatDate(date) {
    try {
      DateTime todayDate = DateTime.parse(date);
      return dateFormat.format(todayDate).toString();
    } on Exception catch (e) {
      return '';
    }
  }

  convertToInt(value) {
    return double.parse(value ?? 0);
  }

  double countTotal(Order order) {
    return convertToInt(order.deliveryFee) +
        order.total +
        convertToInt(order.tax);
  }

  openWhatsApp(phone, message, context) async {
    try {
//      await FlutterLaunch.launchWathsApp(phone: phone, message: message);
      await FlutterOpenWhatsapp.sendSingleMessage(phone, message);
    } on Exception catch (e) {
      CustomSnackBar.show(context, 'WhatsApp Not Found!');
    }
  }
}
