import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class GalleryImage {
  String imageName;

  GalleryImage({this.imageName});

  Map toJson() => {'image': imageName};
}
