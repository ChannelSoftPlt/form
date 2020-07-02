import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class GroupingDialog extends StatefulWidget {
  final String status;
  final Function() onClick;

  GroupingDialog({this.status, this.onClick});

  @override
  _GroupingDialogState createState() => _GroupingDialogState();
}

class _GroupingDialogState extends State<GroupingDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Edit Address'),
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
          onPressed: () {},
        ),
      ],
      content: SingleChildScrollView(),
    );
  }
}
