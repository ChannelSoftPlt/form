class AdvanceShippingFee {
  String totalFee_1, totalFee_2, shippingFee;

  AdvanceShippingFee({this.totalFee_1, this.totalFee_2, this.shippingFee});

  factory AdvanceShippingFee.fromJson(Map<String, dynamic> json) {
    return AdvanceShippingFee(
        totalFee_1: json['total_fee_1'] as String,
        totalFee_2: json['total_fee_2'] as String,
        shippingFee: json['shipping_fee'] as String);
  }

  Map toJson() => {
        'total_fee_1': totalFee_1,
        'total_fee_2': totalFee_2,
        'shipping_fee': shippingFee
      };
}
