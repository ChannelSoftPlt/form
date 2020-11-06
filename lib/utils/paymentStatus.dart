import 'package:flutter/material.dart';
import 'package:my/translation/AppLocalizations.dart';

class PaymentStatus {

  String setStatusCode(status, context) {
    if (status == 'Payment Pending' || status == '等待付款')
      return '1';
    else if (status == 'Payment Failed' || status == '付款失败')
      return '3';
    else
      return '2';
  }

  List paymentStatusList(context) {
    return <String>[
      "${AppLocalizations.of(context).translate('payment_pending')}",
      "${AppLocalizations.of(context).translate('payment_success')}",
      "${AppLocalizations.of(context).translate('payment_failed')}",
    ];
  }

  String setStatus(status, context) {
    switch (status) {
      case '1':
        return '${AppLocalizations.of(context).translate('payment_pending')}';
      case '2':
        return '${AppLocalizations.of(context).translate('payment_success')}';
      default:
        return '${AppLocalizations.of(context).translate('payment_failed')}';
    }
  }



  Color setStatusColor(status) {
    print('status here: $status');
    switch (status) {
      case '1':
        return Colors.blue[300];
      case '2':
        return Colors.green[300];
    }
    return Colors.red[300];
  }
}
