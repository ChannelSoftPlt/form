class Product {
  String price,
      image,
      gallery,
      description,
      name,
      categoryName,
      variation,
      stock,
      sequence;
  int productId, status, categoryId, formId;

  Product(
      {this.status,
      this.price,
      this.image,
      this.gallery,
      this.description,
      this.stock,
      this.name,
      this.categoryName,
      this.categoryId,
      this.variation,
      this.formId,
      this.productId,
      this.sequence});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      status: json['status'] as int,
      price: json['price'] as String,
      image: json['image'] as String,
      gallery: json['image_gallery'] as String,
      description: json['description'] as String,
      name: json['name'] as String,
      categoryName: json['category_name'] as String,
      categoryId: json['category_id'] as int,
      variation: json['variation'] as String,
      formId: json['form_id'] as int,
      productId: json['product_id'] as int,
      stock: json['stock'] as String,
      sequence: json['sequence'].toString(),
    );
  }

  static double checkDouble(num value) {
    return value is double ? value : value.toDouble();
  }

  Map toJson() => {
        'status': status,
        'price': price,
        'image': image,
        'image_gallery': gallery,
        'description': description,
        'name': name,
        'category_id': categoryId,
        'variation': variation,
        'stock': stock,
      };
}
