class Shipping {
  String shippingByPostcode, shippingByDistance, addressLongLat;
  int shippingStatus, selfCollect;

  Shipping(
      {this.shippingStatus,
      this.selfCollect,
      this.shippingByPostcode,
      this.shippingByDistance,
      this.addressLongLat});

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      shippingStatus: json['shipping_setting_status'],
      selfCollect: json['self_collect'],
      shippingByPostcode: json['shipping_by_postcode'],
      shippingByDistance: json['shipping_by_distance'],
      addressLongLat: json['address_long_lat'],
    );
  }

  static List<Shipping> fromJsonList(List list) {
    return list.map((item) => Shipping.fromJson(item)).toList();
  }
}
