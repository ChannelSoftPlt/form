class VariantGroup {
  String groupName;
  List<VariantChild> variantChild = [];
  int type;

  VariantGroup({this.groupName, this.type, this.variantChild});

  factory VariantGroup.fromJson(Map<String, dynamic> json) {
    return VariantGroup(
        groupName: json['group_name'] as String,
        type: json['type'] as int,
        variantChild: json['email'] as List);
  }
}

class VariantChild {
  String name;
  String price;

  VariantChild({this.name, this.price});

  factory VariantChild.fromJson(Map<String, dynamic> json) {
    return VariantChild(
        name: json['name'] as String, price: json['price'] as String);
  }
}
