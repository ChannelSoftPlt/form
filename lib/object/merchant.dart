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
  String selfCollectOption;
  String emailOption;
  String dateOption;
  String timeOption;
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
      this.emailOption,
      this.selfCollectOption,
      this.dateOption,
      this.timeOption});

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
        emailOption = json['email_option'].toString(),
        selfCollectOption = json['self_collect'].toString(),
        dateOption = json['delivery_date_option'].toString(),
        timeOption = json['delivery_time_option'].toString();

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'formId': formId,
        'name': name,
        'url': url,
        'email': email,
      };
}
