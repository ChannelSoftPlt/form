class OrderGroup {
  String groupName, date, updateDate;
  int orderGroupId, totalOrder;

  OrderGroup(
      {this.groupName,
      this.date,
      this.updateDate,
      this.orderGroupId,
      this.totalOrder});

  factory OrderGroup.fromJson(Map<String, dynamic> json) {
    return OrderGroup(
        orderGroupId: json['order_group_id'] as int,
        totalOrder: json['total_order'] as int,
        groupName: json['group_name'] as String,
        updateDate: json['updated_at'] as String,
        date: json['created_at'] as String);
  }

  static List<OrderGroup> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => OrderGroup.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '${this.groupName}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(OrderGroup model) {
    return this?.orderGroupId == model?.orderGroupId;
  }

  @override
  String toString() => groupName;
}
