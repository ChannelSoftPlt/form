import 'package:my/object/shippingSetting/advance_shipping.dart';

class Distance {
  String distanceOne, distanceTwo, shippingFee;
  List<AdvanceShippingFee> advanceShippingFee = [];

  Distance(
      {this.distanceOne,
      this.distanceTwo,
      this.shippingFee,
      this.advanceShippingFee});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
        distanceOne: json['distance_1'],
        distanceTwo: json['distance_2'],
        shippingFee: json['shipping_fee'],
        advanceShippingFee:
            getAdvanceShippingList(json['advanced_shipping_fee']));
  }

  static List<Distance> fromJsonList(List list) {
    return list.map((item) => Distance.fromJson(item)).toList();
  }

  Map toJson() => {
        'distance_1': distanceOne,
        'distance_2': distanceTwo,
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