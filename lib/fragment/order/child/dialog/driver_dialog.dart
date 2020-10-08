import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/object/driver.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
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
  List type;
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
        title: new Text(
            '${AppLocalizations.of(context).translate('assign_driver')}'),
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
              CustomToast(
                      '${AppLocalizations.of(context).translate('all_field_required')}',
                      context,
                      gravity: Toast.BOTTOM)
                  .show();
            },
          ),
        ],
        content: mainContent(context));
  }

  void setUpType(context) {
    type = <String>[
      "${AppLocalizations.of(context).translate('add_new')}",
      "${AppLocalizations.of(context).translate('add_into_existing')}"
    ];
  }

  Widget mainContent(context) {
    setUpType(context);
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
                labelText:
                    '${AppLocalizations.of(context).translate('new_driver')}',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
                hintText:
                    '${AppLocalizations.of(context).translate('driver_name')}',
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
        label: '${AppLocalizations.of(context).translate('driver_name')}',
        popupTitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${AppLocalizations.of(context).translate('existing_driver')}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        searchBoxDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
          prefixIcon: Icon(Icons.search),
          labelText:
              '${AppLocalizations.of(context).translate('search_driver')}',
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
