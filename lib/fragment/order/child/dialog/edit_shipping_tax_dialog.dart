import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:toast/toast.dart';

class EditShippingTaxDialog extends StatefulWidget {
  final Order order;
  final String type;
  final Function(Order) onClick;

  EditShippingTaxDialog({this.order, this.type, this.onClick});

  @override
  _EditShippingTaxDialogState createState() => _EditShippingTaxDialogState();
}

class _EditShippingTaxDialogState extends State<EditShippingTaxDialog> {
  var deliveryFree = TextEditingController();
  var tax = TextEditingController();
  Order object;
  bool available = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    deliveryFree.text = widget.order.deliveryFee;
    tax.text = widget.order.tax;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          widget.type == 'delivery_fee' ? 'Edit Delivery Fee' : 'Edit Tax'),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            try {
              double.parse(deliveryFree.text);
              double.parse(tax.text);

                object.tax = tax.text;
                object.deliveryFee = deliveryFree.text;
                widget.onClick(object);

            } on FormatException {
              CustomToast('Invalid input! 输入不正确!', context, gravity: Toast.BOTTOM)
                  .show();
            }
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                ],
                controller: widget.type == 'delivery_fee' ? deliveryFree : tax,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText:
                      widget.type == 'delivery_fee' ? 'Delivery Fee' : 'Tax',
                  labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                  hintText: '0.00',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
          ),
        ],
      ),
    );
  }
}
