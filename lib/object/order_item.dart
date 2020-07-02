class OrderItem {
  String name, description, quantity, price, productId, status, image;

  int orderProductId;

  OrderItem(
      {this.orderProductId,
        this.name,
        this.description,
        this.quantity,
        this.price,
        this.productId,
        this.status,
        this.image});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        orderProductId: json['order_product_id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        quantity: json['quantity'] as String,
        price: json['price'] as String,
        status: json['status'] as String);
  }
}
