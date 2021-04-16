class EastWest {
  int id;
  String region, firstFee, pricePoint, secondFee, status;

  EastWest({
    this.id,
    this.region,
    this.status,
    this.firstFee,
    this.pricePoint,
    this.secondFee,
  });

  factory EastWest.fromJson(Map<String, dynamic> json) {
    return EastWest(
        id: json['id'] as int,
        status: json['status'],
        region: json['region'],
        firstFee: json['first_fee'],
        pricePoint: json['price_point'],
        secondFee: json['second_fee']);
  }

  static List<EastWest> fromJsonList(List list) {
    return list.map((item) => EastWest.fromJson(item)).toList();
  }
}
