class Category {
  String name;
  int categoryId;
  int sequence;

  Category({this.categoryId, this.name, this.sequence});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        categoryId: json['category_id'] as int, name: json['name'] as String);
  }

  static List<Category> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Category.fromJson(item)).toList();
  }


  ///this method will prevent the override of toString
  String categoryAsString() {
    return '${this.name}';
  }

  @override
  String toString() => name;

  Map toJson() => {'category_id': categoryId, 'sequence': sequence};
}
