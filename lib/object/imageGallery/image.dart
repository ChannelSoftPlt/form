class GalleryImage {
  String imageName;

  GalleryImage({this.imageName});

  Map toJson() => {'image': imageName};
}
