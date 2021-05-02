class VariantGroup {
  String groupName;
  List<VariantChild> variantChild = [];
  int type;
  int option;

  VariantGroup({this.groupName, this.type, this.option, this.variantChild});

  factory VariantGroup.fromJson(Map<String, dynamic> json) {
    return VariantGroup(
        groupName: json['group_name'] as String,
        type: json['type'] as int,
        option: json['option'] as int,
        variantChild: getChildList(json['variation']));
  }

  Map toJson() => {
        'group_name': groupName,
        'type': type,
        'option': option,
        'variation': variantChild
      };

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
  int quantity = 0;

  VariantChild({this.name, this.price, this.quantity});

  factory VariantChild.fromJson(Map<String, dynamic> json) {
    if(json['quantity'] == null){
      json['quantity'] = 0;
    }
    return VariantChild(
        name: json['name'] as String,
        price: json['price'] as String,
        quantity: json['quantity'] as int);
  }

  Map toJson() => {'name': name, 'price': price, 'quantity': quantity};
}
