import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:toast/toast.dart';

class EditDiscountDialog extends StatefulWidget {
  final Order order;
  final Function(Order) onClick;

  EditDiscountDialog({this.order, this.onClick});

  @override
  _EditDiscountDialogState createState() => _EditDiscountDialogState();
}

class _EditDiscountDialogState extends State<EditDiscountDialog> {
  var discountAmount = TextEditingController();
  Order object;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    discountAmount.text = widget.order.discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          '${AppLocalizations.of(context).translate('edit_discount')}'),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            '${AppLocalizations.of(context).translate('confirm')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            try {
              double.parse(discountAmount.text);
              object.discountAmount = discountAmount.text;
              widget.onClick(object);
            } on FormatException {
              CustomToast(
                      '${AppLocalizations.of(context).translate('invalid_input')}',
                      context,
                      gravity: Toast.BOTTOM)
                  .show();
            }
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
              ],
              controller: discountAmount,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('discount_amount')}',
                labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey),
                hintText: '0.00',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              )),
        ],
      ),
    );
  }
}
