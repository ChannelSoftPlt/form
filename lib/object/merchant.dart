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
      this.bankTransfer});

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
        bankTransfer = json['bank_transfer'];

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'formId': formId,
        'name': name,
        'url': url,
        'email': email,
      };
}
