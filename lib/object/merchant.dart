import 'dart:convert';

class Merchant {
  String merchantId;
  String formId;
  String name;
  String email;
  String companyName;
  String url;
  String address;
  String phone;
  String whatsAppNumber;
  String bankDetail;
  String cashOnDelivery;
  String bankTransfer;
  String allowfPay;
  String fpayTransfer;
  String fpayUsername;
  String fpayApiKey;
  String fpaySecretKey;
  String minOrderDay;
  String workingDay;
  WorkingTime workingTime;
  String taxPercent;
  String selfCollectOption;
  String emailOption;
  String dateOption;
  String timeOption;
  String minPurchase;
  String allowTNG;
  bool grouping = true;

  Merchant(
      {this.merchantId,
      this.formId,
      this.name,
      this.email,
      this.grouping,
      this.companyName,
      this.url,
      this.address,
      this.phone,
      this.whatsAppNumber,
      this.bankDetail,
      this.cashOnDelivery,
      this.bankTransfer,
      this.allowfPay,
      this.fpayTransfer,
      this.fpayUsername,
      this.fpayApiKey,
      this.fpaySecretKey,
      this.emailOption,
      this.selfCollectOption,
      this.dateOption,
      this.timeOption,
      this.minOrderDay,
      this.workingDay,
      this.workingTime,
      this.taxPercent,
      this.minPurchase,
      this.allowTNG});

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchantId'],
        formId = json['formId'],
        name = json['name'],
        email = json['email'],
        companyName = json['company_name'],
        url = json['url'],
        address = json['address'],
        phone = json['phone'],
        whatsAppNumber = json['whatsapp_number'],
        bankDetail = json['bank_details'],
        cashOnDelivery = json['cash_on_delivery'],
        bankTransfer = json['bank_transfer'],
        allowfPay = json['allow_fpay_transfer'],
        fpayTransfer = json['fpay_transfer'],
        fpayUsername = json['fpay_username'],
        fpayApiKey = json['fpay_api_key'],
        fpaySecretKey = json['fpay_secret_key'],
        emailOption = json['email_option'].toString(),
        selfCollectOption = json['self_collect'].toString(),
        dateOption = json['delivery_date_option'].toString(),
        minOrderDay = json['order_min_day'].toString(),
        workingDay = json['working_day'].toString(),
        workingTime = getWorkingTime(json['working_time']),
        timeOption = json['delivery_time_option'].toString(),
        minPurchase = json['order_min_purchase'].toString(),
        taxPercent = json['tax_percent'].toString(),
        allowTNG = json['tng_manual_payment'].toString();

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'formId': formId,
        'name': name,
        'url': url,
        'email': email
      };

  static WorkingTime getWorkingTime(data) {
    try {
      return WorkingTime.fromJson(jsonDecode(data));
    } catch ($e) {
      return WorkingTime(startTime: '', endTime: '');
    }
  }
}

class WorkingTime {
  String startTime, endTime;

  WorkingTime({this.startTime, this.endTime});

  Map toJson() => {'start': startTime.toString(), 'end': endTime.toString()};

  factory WorkingTime.fromJson(Map<String, dynamic> json) {
    return WorkingTime(
        startTime: json['start'] as String, endTime: json['end'] as String);
  }
}
