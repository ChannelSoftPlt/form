import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my/translation/AppLocalizations.dart';

class ExportDialog extends StatefulWidget {
  ExportDialog();

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  var exportData = 'Order';
  var fromDate, toDate;

  final displayDateFormat = DateFormat("dd MMM");
  final selectedDateFormat = DateFormat("yyy-MM-dd");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).translate('export'),
        style: GoogleFonts.cantoraOne(
          textStyle: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
      ),
      content: SingleChildScrollView(
        child: mainContent(),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            '${AppLocalizations.of(context).translate('export')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget mainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context).translate('export_data')}',
              labelStyle: TextStyle(fontSize: 18, color: Colors.black54),
              border: const OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down),
                  value: exportData,
                  items: getExportType(context).map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (selectedItem) => setState(
                        () => exportData = selectedItem,
                      )),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          '${AppLocalizations.of(context).translate('date')}',
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Row(
          children: <Widget>[
            FlatButton.icon(
                label: Text(
                  fromDate != null
                      ? displayDateFormat.format(fromDate).toString()
                      : '${AppLocalizations.of(context).translate('from_date')}',
                  style: TextStyle(color: Colors.orangeAccent),
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
                  style: TextStyle(color: Colors.orangeAccent),
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
      ],
    );
  }

  List getExportType(context) {
    return <String>[
      AppLocalizations.of(context).translate('order'),
      AppLocalizations.of(context).translate('customer')
    ];
  }
}
