import 'package:flutter/material.dart';
import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:toast/toast.dart';

class EditGroupNameDialog extends StatefulWidget {
  final Function(OrderGroup) onClick;
  final OrderGroup orderGroup;

  EditGroupNameDialog({this.orderGroup, this.onClick});

  @override
  _EditGroupNameDialogState createState() => _EditGroupNameDialogState();
}

class _EditGroupNameDialogState extends State<EditGroupNameDialog> {
  var groupName = TextEditingController();
  OrderGroup object;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.orderGroup;
    groupName.text = getGroupName(object.groupName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Edit Group Name'),
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
            if (groupName.text.length > 0) {
              object.groupName = groupName.text;
              widget.onClick(object);
            } else{
              CustomToast('Invalid Input!', context, gravity: Toast.BOTTOM).show();
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
                controller: groupName,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                  hintText: 'Name...',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
          ),
        ],
      ),
    );
  }

  String getGroupName(groupName){
    try{
      return groupName.split('\-')[1];
    } catch (e) {
      return groupName;
    }
  }
}
