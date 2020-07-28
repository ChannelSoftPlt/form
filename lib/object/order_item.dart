class OrderItem {
  String name, description, quantity, price, productId, status, image, remark;

  int orderProductId;
  double totalPrice;

  OrderItem(
      {this.orderProductId,
      this.name,
      this.description,
      this.remark,
      this.quantity,
      this.price,
      this.productId,
      this.status,
      this.image,
      this.totalPrice});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        orderProductId: json['order_product_id'] as int,
        name: json['name'] as String,
        totalPrice: convertIntToDouble(json['total']),
        description: json['description'] as String,
        remark: json['remark'] as String,
        quantity: convertIntToString(json['quantity']),
        price: json['price'] as String,
        status: json['status'] as String);
  }

  static double convertIntToDouble(num value) {
    if (value != null)
      return value is double ? value : value.toDouble();
    else
      return 0.0;
  }

  static String convertIntToString(value) {
    return value is int ? value.toString() : value;
  }
}
