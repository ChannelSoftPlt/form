class Distance {
  String distanceOne, distanceTwo, shippingFee;

  Distance({this.distanceOne, this.distanceTwo, this.shippingFee});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
        distanceOne: json['distance_1'],
        distanceTwo: json['distance_2'],
        shippingFee: json['shipping_fee']);
  }

  static List<Distance> fromJsonList(List list) {
    return list.map((item) => Distance.fromJson(item)).toList();
  }

  Map toJson() => {
        'distance_1': distanceOne,
        'distance_2': distanceTwo,
        'shipping_fee': shippingFee
      };
}
