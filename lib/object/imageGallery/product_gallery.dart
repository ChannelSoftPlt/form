import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ProductGallery {
  String imageName;
  String imageCode;
  ImageProvider imageProvider;
  Asset imageAsset;
  int status;

  ProductGallery(
      {this.imageName,
      this.imageCode,
      this.imageProvider,
      this.imageAsset,
      this.status});

  factory ProductGallery.fromJson(dynamic json) {
    print('json: $json');
    return ProductGallery(imageName: json['image'] as String);
  }

  static String getImageName() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('ymdHmsS');
    return ('${formatter.format(now)}.png');
  }

  Map toJson() => {'image': imageName, 'image_file': imageCode};
}
