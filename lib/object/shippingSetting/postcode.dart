import 'package:my/object/shippingSetting/advance_shipping.dart';

class Postcode {
  String postcodeOne, postcodeTwo, shippingFee;
  List<AdvanceShippingFee> advanceShippingFee = [];

  Postcode(
      {this.postcodeOne,
      this.postcodeTwo,
      this.shippingFee,
      this.advanceShippingFee});

  factory Postcode.fromJson(Map<String, dynamic> json) {
    return Postcode(
        postcodeOne: json['postcode_1'],
        postcodeTwo: json['postcode_2'],
        shippingFee: json['shipping_fee'],
        advanceShippingFee:
            getAdvanceShippingList(json['advanced_shipping_fee']));
  }

  static List<Postcode> fromJsonList(List list) {
    return list.map((item) => Postcode.fromJson(item)).toList();
  }

  Map toJson() => {
        'postcode_1': postcodeOne,
        'postcode_2': postcodeTwo,
        'shipping_fee': shippingFee,
        'advanced_shipping_fee': advanceShippingFee
      };

  static List<AdvanceShippingFee> getAdvanceShippingList(List data) {
    try {
      List<AdvanceShippingFee> list = [];
      list.addAll(data
          .map((jsonObject) => AdvanceShippingFee.fromJson(jsonObject))
          .toList());
      return list;
    } catch ($e) {
      return <AdvanceShippingFee>[];
    }
  }
}
