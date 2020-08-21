import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class GroupingDialog extends StatefulWidget {
  final Function(String, String) onClick;

  GroupingDialog({this.onClick});

  @override
  _GroupingDialogState createState() => _GroupingDialogState();
}

class _GroupingDialogState extends State<GroupingDialog> {
  List<OrderGroup> groups = [];
  List type = <String>["Add New", "Add Into Existing"];
  bool showAddNew = true;

  var newGroup = TextEditingController();
  String orderGroupId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text('Assign Group / 统计'),
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
              //create new group
              if (showAddNew) {
                if (newGroup.text.length > 1) {
                  widget.onClick(newGroup.text, '');
                  return;
                }
              } else {
                if (orderGroupId != '') {
                  widget.onClick('', orderGroupId);
                  return;
                }
              }
              CustomToast('All field above are required!', context,
                      gravity: Toast.BOTTOM)
                  .show();
            },
          ),
        ],
        content: mainContent(context));
  }

  Widget mainContent(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            child: RadioButtonGroup(
          orientation: GroupedButtonsOrientation.VERTICAL,
          picked: showAddNew ? type[0] : type[1],
          onSelected: (String selected) {
            print(selected);
            setState(() {
              selected == type[0] ? showAddNew = true : showAddNew = false;
            });
          },
          labels: type,
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
        createNewGroup(),
        chooseExistingGroup(),
      ],
    );
  }

  Widget createNewGroup() {
    return Visibility(
        visible: showAddNew,
        child: Theme(
          data: new ThemeData(
            primaryColor: Colors.orange,
          ),
          child: TextField(
              keyboardType: TextInputType.text,
              controller: newGroup,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'New Group / 新统计',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                hintText: 'Group Name / 统计名',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              )),
        ));
  }

  Widget chooseExistingGroup() {
    return Visibility(
      visible: !showAddNew,
      child: DropdownSearch<OrderGroup>(
        mode: Mode.BOTTOM_SHEET,
        label: 'Group Name / 统计名称',
        popupTitle: Text(
          'Existing Group / 现有统计',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        searchBoxDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
          prefixIcon: Icon(Icons.search),
          labelText: "Search a group",
        ),
        showSearchBox: true,
        onFind: (String filter) => getData(filter),
        itemAsString: (OrderGroup u) => u.userAsString(),
        onChanged: (OrderGroup data) =>
            orderGroupId = data.orderGroupId.toString(),
      ),
    );
  }

  Future<List<OrderGroup>> getData(filter) async {
    Map data = await Domain().fetchGroup();
    var models;
    if (data['status'] == '1') {
      models = OrderGroup.fromJsonList(data['order_group']);
    }
    return models;
  }
}
