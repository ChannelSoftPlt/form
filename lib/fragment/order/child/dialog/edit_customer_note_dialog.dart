import 'package:flutter/material.dart';
import 'package:my/object/order.dart';
import 'package:my/translation/AppLocalizations.dart';

class EditRemarkDialog extends StatefulWidget {
  final Order order;
  final Function(String) onClick;

  EditRemarkDialog({this.order, this.onClick});

  @override
  _EditRemarkDialogState createState() => _EditRemarkDialogState();
}

class _EditRemarkDialogState extends State<EditRemarkDialog> {
  var note = TextEditingController();
  Order object;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    note.text = widget.order.note;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('${AppLocalizations.of(context).translate('edit_note')}'),
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
            widget.onClick(note.text);
          },
        ),
      ],
      content: Container(
        width: 1000,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Theme(
              data: new ThemeData(
                primaryColor: Colors.orange,
              ),
              child: TextField(
                  minLines: 3,
                  maxLines: 10,
                  controller: note,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).translate('remark')}',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                    hintText:
                        '${AppLocalizations.of(context).translate('remark')}',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
