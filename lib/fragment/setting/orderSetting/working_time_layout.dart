import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';

class WorkingTimeLayout extends StatefulWidget {
  final Function(List<WorkingTime>, String) callBack;
  final List<WorkingTime> workingTime;

  @override
  _WorkingTimeLayoutState createState() => _WorkingTimeLayoutState();

  WorkingTimeLayout({this.callBack, this.workingTime});
}

class _WorkingTimeLayoutState extends State<WorkingTimeLayout> {
  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  double countHeight() {
    switch (widget.workingTime.length) {
      case 0:
        return 50;
      default:
        return (40 + (widget.workingTime.length * 80)).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.workingTime != null
        ? Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: countHeight(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.workingTime.length,
                          itemBuilder: (context, position) {
                            return listViewItem(
                                widget.workingTime[position], position);
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              _showAddWorkingTimeDialog(context, false, null),
                          child: Text(
                            '${AppLocalizations.of(context).translate('add_working_time')}',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(),
                        ),
                      )
                    ],
                  )),
            ),
          )
        : Center(child: CustomProgressBar());
  }

  Widget listViewItem(WorkingTime workingTime, position) {
    return Container(
      child: Column(
        children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      workingTime.startTime,
                      textAlign: TextAlign.start,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      AppLocalizations.of(context).translate('to'),
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      workingTime.endTime,
                      textAlign: TextAlign.start,
                    )),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () =>
                      deleteWorkingTimeDialog(context, workingTime),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () =>
                      _showAddWorkingTimeDialog(context, true, workingTime),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  _showAddWorkingTimeDialog(
      BuildContext context, bool isUpdate, WorkingTime workingTime) {
    TextEditingController startTime = new TextEditingController();
    TextEditingController endTime = new TextEditingController();

    if (isUpdate) {
      startTime.text = workingTime.startTime;
      endTime.text = workingTime.endTime;
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate(isUpdate ? 'edit_working_time' : 'add_working_time')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      '${AppLocalizations.of(context).translate('cancel')}'),
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
                    if (startTime.text.isEmpty || endTime.text.isEmpty) {
                      widget.callBack(null, 'invalid_input');
                    } else {
//                      if (checkInput(startTime.text, endTime.text))
                      setState(() {
                        if (!isUpdate) {
                          widget.workingTime.add(new WorkingTime(
                              startTime: startTime.text,
                              endTime: endTime.text));
                        } else {
                          workingTime.startTime = startTime.text;
                          workingTime.endTime = endTime.text;
                        }
                        widget.callBack(widget.workingTime, '');
                        Navigator.of(context).pop();
                      });
                    }
                  },
                ),
              ],
              content: Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: Container(
                    width: 2000,
                    height: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                readOnly: true,
                                controller: startTime,
                                onTap: () => selectTime(
                                    workingTime != null
                                        ? workingTime.startTime
                                        : '',
                                    startTime),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context).translate('start')}',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  AppLocalizations.of(context).translate('to'),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                readOnly: true,
                                controller: endTime,
                                onTap: () => selectTime(
                                    workingTime != null
                                        ? workingTime.endTime
                                        : '',
                                    endTime),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context).translate('end')}',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ));
        });
  }

  selectTime(time, TextEditingController controller) {
    try {
      if (time != '')
        time = new DateFormat('HH:mm').parse(time);
      else
        time = DateTime.now();
    } catch (e) {
      time = DateTime.now();
    }

    DatePicker.showTimePicker(context,
        showTitleActions: true,
        showSecondsColumn: false,
        currentTime: time, onConfirm: (date) async {
      setState(() {
        controller.text = '${date.hour} : ${date.minute}';
      });
    });
  }

  deleteWorkingTimeDialog(mainContext, WorkingTime workingTime) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text(
              '${AppLocalizations.of(mainContext).translate('delete_workingTime')}'),
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
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  widget.callBack(null, 'delete_success');
                  widget.workingTime.remove(workingTime);
                });
              },
            ),
          ],
        );
      },
    );
  }

//  bool checkInput(fromWorkingTime, toWorkingTime) {
//    try {
//      int workingTime1 = int.parse(fromWorkingTime);
//      int workingTime2 = int.parse(toWorkingTime);
//      if (workingTime1 >= workingTime2) {
//        widget.callBack('invalid_workingTime');
//        return false;
//      }
//      for (int i = 0; i < workingTime.length; i++) {
//        if ((workingTime1 >= int.parse(workingTime[i].workingTimeOne) &&
//                workingTime1 <= int.parse(workingTime[i].workingTimeTwo)) ||
//            (workingTime2 >= int.parse(workingTime[i].workingTimeOne) &&
//                workingTime2 <= int.parse(workingTime[i].workingTimeTwo))) {
//          widget.callBack('overlay_workingTime');
//          return false;
//        }
//      }
//    } catch ($e) {
//      return false;
//    }
//    return true;
//  }
}
