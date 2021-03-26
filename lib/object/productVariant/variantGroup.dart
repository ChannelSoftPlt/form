import 'dart:convert';

import 'package:my/fragment/product/variant/variant_child_list_view.dart';

class VariantGroup {
  String groupName;
  List<VariantChild> variantChild = [];
  int type;

  VariantGroup({this.groupName, this.type, this.variantChild});

  factory VariantGroup.fromJson(Map<String, dynamic> json) {
    return VariantGroup(
        groupName: json['group_name'] as String,
        type: json['type'] as int,
        variantChild: getChildList(json['variation']));
  }

  Map toJson() =>
      {'group_name': groupName, 'type': type, 'variation': variantChild};

  static List<VariantChild> getChildList(List data) {
    List<VariantChild> list = [];
    list.addAll(
        data.map((jsonObject) => VariantChild.fromJson(jsonObject)).toList());
    return list;
  }
}

class VariantChild {
  String name;
  String price;

  VariantChild({this.name, this.price});

  factory VariantChild.fromJson(Map<String, dynamic> json) {
    print('testing $json');
    return VariantChild(
        name: json['name'] as String, price: json['price'] as String);
  }

  Map toJson() => {'name': name, 'price': price};
}
