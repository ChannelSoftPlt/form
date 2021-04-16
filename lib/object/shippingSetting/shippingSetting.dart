class Shipping {
  String shippingByPostcode, shippingByDistance, addressLongLat;
  int shippingStatus;

  Shipping(
      {this.shippingStatus,
      this.shippingByPostcode,
      this.shippingByDistance,
      this.addressLongLat});

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      shippingStatus: json['shipping_setting_status'],
      shippingByPostcode: json['shipping_by_postcode'],
      shippingByDistance: json['shipping_by_distance'],
      addressLongLat: json['address_long_lat'],
    );
  }

  static List<Shipping> fromJsonList(List list) {
    return list.map((item) => Shipping.fromJson(item)).toList();
  }
}
