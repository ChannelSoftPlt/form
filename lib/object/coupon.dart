class Coupon {
  String couponCode,
      discountCondition,
      discountType,
      startDate,
      endDate,
      productRestriction;

  var usageLimit, usageLimitPerUser;
  int couponId, status, couponUsed, couponUsedByUser;

  Coupon(
      {this.couponCode,
      this.discountCondition,
      this.discountType,
      this.usageLimitPerUser,
      this.startDate,
      this.endDate,
      this.couponId,
      this.productRestriction,
      this.usageLimit,
      this.status,
      this.couponUsed,
      this.couponUsedByUser});

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
        couponCode: json['coupon_code'] as String,
        discountCondition: json['discount_condition'] as String,
        discountType: json['discount_type'] as String,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        productRestriction: json['product_restriction'] as String,
        couponId: json['id'] as int,
        usageLimitPerUser: json['usage_limit_per_user'],
        usageLimit: json['usage_limit'],
        couponUsed: json['coupon_used'] as int,
        couponUsedByUser: json['user_coupon_used'] as int,
        status: json['status'] as int);
  }

  static List<Coupon> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Coupon.fromJson(item)).toList();
  }
}
