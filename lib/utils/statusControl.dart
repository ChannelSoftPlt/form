import 'package:flutter/material.dart';

class StatusControl {
  List statusList = <String>[
    "Processing|处理中",
    "Cancelled|已取消",
    "Completed|已完成",
  ];

  String setStatusCode(status) {
    switch (status) {
      case 'New Order|新订单':
        return '1';
      case 'Processing|处理中':
        return '2';
      case 'Cancelled|已取消':
        return '3';
      default:
        return '4';
    }
  }

  String setStatus(status) {
    switch (status) {
      case '1':
        return 'New Order|新订单';
      case '2':
        return 'Processing|处理中';
      case '3':
        return 'Cancelled|已取消';
      default:
        return 'Completed|已完成';
    }
  }

  Color setStatusColor(status) {
    switch (status) {
      case '1':
        return Color.fromRGBO(255, 213, 79, 100);
      case '2':
        return Colors.green[300];
      case '3':
        return Colors.red[300];
    }
    return Colors.grey;
  }
}
