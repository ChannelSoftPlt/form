class ProductGallery {
  String imageName;
  int status;

  ProductGallery({this.imageName, this.status});

  factory ProductGallery.fromJson(Map<String, dynamic> json) {
    return ProductGallery(
        status: json['status'] as int, imageName: json['imageName'] as String);
  }
}
