import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';

class EditPhoneDialog extends StatefulWidget {
  final Order order;
  final Function(String) onClick;

  EditPhoneDialog({this.order, this.onClick});

  @override
  _EditPhoneDialogState createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  var phone = TextEditingController();
  Order object;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    phone.text = widget.order.phone;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          new Text('${AppLocalizations.of(context).translate('edit_phone')}'),
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
            if (phone.text.isNotEmpty)
              widget.onClick(phone.text);
            else
              CustomToast(
                      '${AppLocalizations.of(context).translate('invalid_input')}',
                      context)
                  .show();
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
              controller: phone,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('phone')}',
                labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                hintText: '60143157322',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              )),
        ],
      ),
    );
  }
}
