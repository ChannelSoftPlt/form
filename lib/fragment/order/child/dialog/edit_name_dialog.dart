import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';

class EditNameDialog extends StatefulWidget {
  final Order order;
  final Function(String) onClick;

  EditNameDialog({this.order, this.onClick});

  @override
  _EditNameDialogState createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  var name = TextEditingController();
  Order object;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    name.text = widget.order.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('${AppLocalizations.of(context).translate('edit_name')}'),
      actions: <Widget>[
        TextButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            '${AppLocalizations.of(context).translate('confirm')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            if (name.text.isNotEmpty)
              widget.onClick(name.text);
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
              keyboardType: TextInputType.text,
              controller: name,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).translate('name')}',
                labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                hintText: AppLocalizations.of(context).translate('name'),
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              )),
        ],
      ),
    );
  }
}
