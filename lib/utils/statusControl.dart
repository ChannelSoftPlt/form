import 'package:flutter/material.dart';

class StatusControl {
  List statusList = <String>[
    "New Order|新订单",
    "Payment Pending|等待付款",
    "Processing|处理中",
    "Shipped|已发货",
    "Cancelled|已取消",
    "Completed|已完成",
  ];

  String setStatusCode(status) {
    switch (status) {
      case 'New Order|新订单':
        return '1';
      case 'Payment Pending|等待付款':
        return '2';
      case 'Processing|处理中':
        return '3';
      case 'Shipped|已发货':
        return '4';
      case 'Cancelled|已取消':
        return '5';
      default:
        return '6';
    }
  }

  String setStatus(status) {
    switch (status) {
      case '1':
        return 'New Order|新订单';
      case '2':
        return 'Payment Pending|等待付款';
      case '3':
        return 'Processing|处理中';
      case '4':
        return 'Shipped|已发货';
      case '5':
        return 'Cancelled|已取消';
      default:
        return 'Completed|已完成';
    }
  }

  Color setStatusColor(status) {
    switch (status) {
      case '1':
        return Colors.red[300];
      case '2':
        return Colors.red[300];
      case '3':
        return Colors.green[300];
      case '5':
        return Colors.red[300];
    }
    return Colors.grey;
  }
}
