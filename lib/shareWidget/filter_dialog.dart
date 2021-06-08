import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:my/object/driver.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class FilterDialog extends StatefulWidget {
  final fromDate, toDate;
  final Driver driver;
  final Function(DateTime, DateTime, Driver) onClick;
  final bool showDriver;

  FilterDialog(
      {this.fromDate, this.toDate, this.driver, this.onClick, this.showDriver});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  List<Driver> drivers = [];

  var fromDate, toDate;
  final displayDateFormat = DateFormat("dd MMM");
  final selectedDateFormat = DateFormat("yyy-MM-dd");

  var newDriver = TextEditingController();
  Driver driver;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    driver = widget.driver;
    fromDate = widget.fromDate;
    toDate = widget.toDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.all(0),
        title: new Text('${AppLocalizations.of(context).translate('sorting')}'),
        actions: <Widget>[
          FlatButton(
            child: Text('${AppLocalizations.of(context).translate('cancel')}'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              '${AppLocalizations.of(context).translate('apply')}',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              //create new group
              if ((fromDate == null && toDate == null) ||
                  (fromDate != null && toDate != null)) {
                widget.onClick(fromDate != null ? fromDate : null,
                    toDate != null ? toDate : null, driver ?? null);
                return;
              }
              CustomToast(
                      '${AppLocalizations.of(context).translate('invalid_date')}',
                      context,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Row(
          children: <Widget>[
            FlatButton.icon(
                label: Text(
                  fromDate != null
                      ? displayDateFormat.format(fromDate).toString()
                      : '${AppLocalizations.of(context).translate('from_date')}',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                icon: Icon(Icons.date_range),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      onChanged: (date) {}, onConfirm: (date) {
                    setState(() {
                      fromDate = date;
                    });
                  },
                      currentTime: fromDate != null ? fromDate : DateTime.now(),
                      locale: LocaleType.zh);
                }),
            FlatButton.icon(
                label: Text(
                  toDate != null
                      ? displayDateFormat.format(toDate).toString()
                      : '${AppLocalizations.of(context).translate('to_date')}',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                icon: Icon(Icons.date_range),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      onChanged: (date) {}, onConfirm: (date) {
                    setState(() {
                      toDate = date;
                    });
                  },
                      currentTime: toDate != null ? toDate : DateTime.now(),
                      locale: LocaleType.zh);
                })
          ],
        ),
        SizedBox(
          height: 10,
        ),
        chooseDriver(),
      ],
    );
  }

  Widget chooseDriver() {
    return Visibility(
        visible: widget.showDriver,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).translate('driver')}',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownSearch<Driver>(
                mode: Mode.BOTTOM_SHEET,
                label:
                    '${AppLocalizations.of(context).translate('driver_name')}',
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
                      "${AppLocalizations.of(context).translate('search_driver')}",
                ),
                showSearchBox: true,
                showClearButton: true,
                selectedItem: driver,
                onFind: (String filter) => getData(filter),
                itemAsString: (Driver u) => u.displayText(),
                onChanged: (Driver data) => driver = data),
          ],
        ));
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
