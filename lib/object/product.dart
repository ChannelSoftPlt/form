class Product {
  String price, image, description, name, categoryName;
  int productId, status, categoryId;

  Product(
      {this.status,
      this.price,
      this.image,
      this.description,
      this.name,
      this.categoryName,
      this.categoryId,
      this.productId});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        status: json['status'] as int,
        price: json['price'] as String,
        image: json['image'] as String,
        description: json['description'] as String,
        name: json['name'] as String,
        categoryName: json['category_name'] as String,
        categoryId: json['category_id'] as int,
        productId: json['productId'] as int);
  }

  static double checkDouble(num value) {
    return value is double ? value : value.toDouble();
  }

}
