import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/utils/statusControl.dart';

class StatusDialog extends StatelessWidget {
  final Function(String) onClick;
  final String status;

  StatusDialog({this.status, this.onClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Select Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              child:
              RadioButtonGroup(
                orientation: GroupedButtonsOrientation.VERTICAL,
                picked: status != '-1' ? StatusControl().setStatus(status) : null,
                onSelected: (String selected) =>onClick(StatusControl().setStatusCode(selected)),
                labels: StatusControl().statusList,
                itemBuilder: (Radio cb, Text txt, int i){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          cb,
                          txt
                        ],
                      )
                    ],
                  );
                },
              )
          ),
        ],
      ),
    );
  }
}

