import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ProductGallery {
  String imageName;
  ImageProvider imageProvider;
  int status;

  ProductGallery({this.imageName, this.imageProvider, this.status});

  factory ProductGallery.fromJson(dynamic json) {
    return ProductGallery(imageName: json['image'] as String);
  }

  static String getImageName() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('ymdHms');
    return ('${formatter.format(now)}.png');
  }
}
