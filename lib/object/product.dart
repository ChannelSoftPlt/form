class Product {
  String price, image, description, name;
  int productId, status;

  Product(
      {this.status,
      this.price,
      this.image,
      this.description,
      this.name,
      this.productId});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        status: json['status'] as int,
        price: json['price'] as String,
        image: json['image'] as String,
        description: json['description'] as String,
        name: json['name'] as String,
        productId: json['productId'] as int);
  }
}
