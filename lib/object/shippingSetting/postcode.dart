class Postcode {
  String postcodeOne, postcodeTwo, shippingFee;

  Postcode({this.postcodeOne, this.postcodeTwo, this.shippingFee});

  factory Postcode.fromJson(Map<String, dynamic> json) {
    return Postcode(
        postcodeOne: json['postcode_1'],
        postcodeTwo: json['postcode_2'],
        shippingFee: json['shipping_fee']);
  }

  static List<Postcode> fromJsonList(List list) {
    return list.map((item) => Postcode.fromJson(item)).toList();
  }

  Map toJson() => {
        'postcode_1': postcodeOne,
        'postcode_2': postcodeTwo,
        'shipping_fee': shippingFee
      };
}
