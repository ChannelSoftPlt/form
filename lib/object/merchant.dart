class Merchant {
  String merchantId;
  String name;
  String email;
  String companyName;
  String url;
  String address;
  String phone;
  String bankDetail;
  String cashOnDelivery;
  String bankTransfer;
  bool grouping = true;

  Merchant(
      {this.merchantId,
      this.name,
      this.email,
      this.grouping,
      this.companyName,
      this.url,
      this.address,
      this.phone,
      this.bankDetail,
      this.cashOnDelivery,
      this.bankTransfer});

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchantId'],
        name = json['name'],
        email = json['email'],
        companyName = json['company_name'],
        url = json['url'],
        address = json['address'],
        phone = json['phone'],
        bankDetail = json['bank_details'],
        cashOnDelivery = json['cash_on_delivery'],
        bankTransfer = json['bank_transfer'];

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'name': name,
        'url': url,
        'email': email,
      };
}
