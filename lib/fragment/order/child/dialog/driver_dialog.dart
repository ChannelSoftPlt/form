import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/object/driver.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class DriverDialog extends StatefulWidget {
  final String status;
  final Function(String, String) onClick;

  DriverDialog({this.status, this.onClick});

  @override
  _DriverDialogState createState() => _DriverDialogState();
}

class _DriverDialogState extends State<DriverDialog> {
  List<Driver> drivers = [];
  List type = <String>["Add New/新建立", "Add Into Existing/添加到现有"];
  bool showAddNew = true;

  var newDriver = TextEditingController();
  String driverId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text('Assign Driver / 司机'),
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
                if (newDriver.text.length > 1) {
                  widget.onClick(newDriver.text, '');
                  return;
                }
              } else {
                if (driverId != '') {
                  widget.onClick('', driverId);
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
              controller: newDriver,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'New Driver / 新司机',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                hintText: 'Driver Name / 司机名',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              )),
        ));
  }

  Widget chooseExistingGroup() {
    return Visibility(
      visible: !showAddNew,
      child: DropdownSearch<Driver>(
        mode: Mode.BOTTOM_SHEET,
        label: 'Driver Name / 司机名称',
        popupTitle: Text(
          'Existing Driver / 现有司机',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        searchBoxDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
          prefixIcon: Icon(Icons.search),
          labelText: "Search a Driver",
        ),
        showSearchBox: true,
        onFind: (String filter) => getData(filter),
        itemAsString: (Driver u) => u.displayText(),
        onChanged: (Driver data) => driverId = data.driverId.toString(),
      ),
    );
  }

  Future<List<Driver>> getData(filter) async {
    Map data = await Domain().fetchDriver();
    var models;
    if (data['status'] == '1') {
      models = Driver.fromJsonList(data['driver']);
    }
    return models;
  }
}
