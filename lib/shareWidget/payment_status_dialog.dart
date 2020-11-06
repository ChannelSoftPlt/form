import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/paymentStatus.dart';

class PaymentStatusDialog extends StatelessWidget {
  final Function(String) onClick;
  final String paymentStatus;

  PaymentStatusDialog({this.paymentStatus, this.onClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          '${AppLocalizations.of(context).translate('select_status')}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              child: RadioButtonGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            picked: paymentStatus != '-1'
                ? PaymentStatus().setStatus(paymentStatus, context)
                : null,
            onSelected: (String selected) {
              onClick(PaymentStatus().setStatusCode(selected, context));
            },
            labels: PaymentStatus().paymentStatusList(context),
            itemBuilder: (Radio cb, Text txt, int i) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[cb, txt],
                  )
                ],
              );
            },
          )),
        ],
      ),
    );
  }
}
