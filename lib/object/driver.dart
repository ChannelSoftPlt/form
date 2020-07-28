class Driver {
  String driverName;
  int driverId;

  Driver({this.driverName, this.driverId});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        driverId: json['driver_id'] as int,
        driverName: json['driver_name'] as String);
  }

  static List<Driver> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Driver.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String displayText() {
    return '${this.driverName}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(Driver model) {
    return this?.driverId == model?.driverId;
  }

  @override
  String toString() => driverName;
}
