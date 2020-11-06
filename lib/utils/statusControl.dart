import 'package:flutter/material.dart';
import 'package:my/translation/AppLocalizations.dart';

class StatusControl {
  List statusList = <String>[
    "processing",
    "cancelled",
    "completed",
  ];

  List getStatusList(context){
    return <String>[
      AppLocalizations.of(context).translate('processing'),
      AppLocalizations.of(context).translate('cancelled'),
      AppLocalizations.of(context).translate('completed')
    ];
  }

  String setStatusCode(status, context) {
    if (status == 'Processing' || status == '处理中')
      return '2';
    else if (status == 'Cancelled' || status == '已取消')
      return '3';
    else
      return '4';
  }

  String setStatus(status, context) {
    switch (status) {
      case '1':
        return '${AppLocalizations.of(context).translate('new_order')}';
      case '2':
        return '${AppLocalizations.of(context).translate('processing')}';
      case '3':
        return '${AppLocalizations.of(context).translate('cancelled')}';
      default:
        return '${AppLocalizations.of(context).translate('completed')}';
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
