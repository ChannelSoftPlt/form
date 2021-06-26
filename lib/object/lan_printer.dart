class LanPrinter {
  int printerId, port;
  String ip, name;

  LanPrinter({this.printerId, this.port, this.ip, this.name});

  factory LanPrinter.fromJson(Map<String, dynamic> json) {
    return LanPrinter(
      printerId: json['printer_id'] as int,
      port: json['port'] as int,
      name: json['name'] as String,
      ip: json['ip'] as String,
    );
  }

  static List<LanPrinter> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => LanPrinter.fromJson(item)).toList();
  }
}
