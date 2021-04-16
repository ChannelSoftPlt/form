import 'package:intl/intl.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
      paymentStatus,
      note,
      tax,
      merchantRemark,
      paymentMethod,
      fpayReceiveAmount,
      userDeviceType,
      publicUrl,
      groupName,
      driverName,
      deliveryFee,
      deliveryDate,
      deliveryTime,
      discountAmount,
      couponCode,
      couponDiscount,
      proofPhoto,
      proofPhotoDate;

  int id, formId, orderGroupId, driverId, selfCollect, couponUsageId;
  double total;
  final dateFormat = DateFormat("dd MMM hh:mm");

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
      this.paymentStatus,
      this.total,
      this.tax,
      this.deliveryFee,
      this.deliveryDate,
      this.deliveryTime,
      this.merchantRemark,
      this.paymentMethod,
      this.fpayReceiveAmount,
      this.userDeviceType,
      this.orderGroupId,
      this.driverId,
      this.driverName,
      this.groupName,
      this.publicUrl,
      this.selfCollect,
      this.discountAmount,
      this.couponCode,
      this.couponDiscount,
      this.couponUsageId,
      this.proofPhoto,
      this.proofPhotoDate});

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
      deliveryDate: json['delivery_date'] as String,
      deliveryTime: json['delivery_time'] as String,
      tax: json['tax'] == '' ? '0.00' : json['tax'] as String,
      orderGroupId: json['order_group_id'] as int,
      groupName: json['group_name'] as String,
      driverId: json['driver_id'] as int,
      driverName: json['driver_name'] as String,
      total: checkDouble(json['total_amount']),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      fpayReceiveAmount: json['received_amount'] as String,
      paymentStatus: json['payment_status'] as String,
      note: json['note'] as String,
      merchantRemark: json['remark'] as String,
      selfCollect: json['self_collect'] as int,
      discountAmount: returnDefaultValue(json['discount_amount']),
      couponCode: json['coupon_name'] as String,
      couponDiscount: returnDefaultValue(json['coupon_discount']),
      couponUsageId: json['coupon_usage_id'] as int,
      proofPhoto: json['proof_photo'] as String,
      proofPhotoDate: json['proof_photo_date'] as String,
    );
  }

  static String returnDefaultValue(value) {
    return value ?? "0.00";
  }

  static double checkDouble(value) {
    try {
      return value is double ? value : double.parse(value);
    } catch ($e) {
      return 0.00;
    }
  }

  String orderPrefix(orderID) {
    String prefix = '';
    for (int i = orderID.length; i < 5; i++) {
      prefix = prefix + "0";
    }
    return '\#' + prefix + orderID;
  }

  String whatsAppOrderPrefix(orderID) {
    String prefix = '';
    for (int i = orderID.length; i < 5; i++) {
      prefix = prefix + "0";
    }
    return prefix + orderID;
  }

  String formatDate(date) {
    try {
      DateTime todayDate = DateTime.parse(date);
      return dateFormat.format(todayDate).toString();
    } catch (e) {
      return '';
    }
  }

  convertToInt(value) {
    try {
      return double.parse(value ?? 0);
    } catch (e) {
      return 0;
    }
  }

  double countTotal(Order order) {
    if (order.id == 8525) {
      print('order total ${order.total}');
    }
    return convertToInt(order.deliveryFee) +
        order.total +
        convertToInt(order.tax) -
        convertToInt(order.couponDiscount) -
        convertToInt(order.discountAmount);
  }

  static getPhoneNumber(phone) {
    try {
      String firstTwoDigits = phone.substring(0, 2);
      if (firstTwoDigits == '60' || firstTwoDigits == '65') {
        return phone;
      }
      return '6$phone';
    } catch (e) {
      return '6$phone';
    }
  }

  openWhatsApp(phone, message, context) async {
    try {
      var url = "https://api.whatsapp.com/send?phone=$phone&text=$message";
      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Something Went Wrong!');
      }
    } catch (e) {
      CustomSnackBar.show(context, 'WhatsApp Not Found!');
    }
  }
}
