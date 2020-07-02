class Merchant {
  String merchantId;
  String name;
  String email;
  bool grouping = true;

  Merchant({this.merchantId, this.name, this.email, this.grouping});

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchantId'],
        name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'name': name,
        'email': email,
      };
}
