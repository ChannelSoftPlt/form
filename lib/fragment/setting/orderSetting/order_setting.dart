import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class OrderSetting extends StatefulWidget {
  @override
  _OrderSettingState createState() => _OrderSettingState();
}

class _OrderSettingState extends State<OrderSetting> {
  final key = new GlobalKey<ScaffoldState>();

  var minOrderDays = TextEditingController();
  var minPurchase = TextEditingController();
  var startTime = new TextEditingController();
  var endTime = new TextEditingController();
  var orderReminder = new TextEditingController();

  bool email, selfCollect, deliveryDate, deliveryTime, allowEmailNotification;
  List<int> workingDays = [];
  WorkingTime workingTime;
  StreamController refreshController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshController = StreamController();
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('order_setting')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: Domain().fetchProfile(),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List responseJson = data['profile'];

                  Merchant merchant = responseJson
                      .map((jsonObject) => Merchant.fromJson(jsonObject))
                      .toList()[0];
                  email = merchant.emailOption != '1';
                  selfCollect = merchant.selfCollectOption != '1';
                  deliveryTime = merchant.timeOption != '1';
                  deliveryDate = merchant.dateOption != '1';

                  allowEmailNotification = merchant.allowEmail != '1';

                  minOrderDays.text = merchant.minOrderDay ?? 0;
                  minPurchase.text = merchant.minPurchase ?? '0';
                  print(merchant.orderReminder);
                  orderReminder.text = merchant.orderReminder;

                  var workingDay = jsonDecode(merchant.workingDay);
                  workingDays =
                      workingDay != null ? List.from(workingDay) : null;

                  workingTime = merchant.workingTime;

                  startTime.text = workingTime.startTime;
                  endTime.text = workingTime.endTime;

                  return mainContent(context);
                } else {
                  return CustomProgressBar();
                }
              }
            }
            return Center(child: CustomProgressBar());
          }),
    );
  }

  getWorkingTime(json) {
    try {
      var workingTime = jsonDecode(json);
      return List.from(workingTime);
    } catch ($e) {
      return null;
    }
  }

  Widget mainContent(context) {
    return StreamBuilder<Object>(
        stream: refreshController.stream,
        builder: (context, result) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.date_range,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '${AppLocalizations.of(context).translate('optional_fields')}',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    89, 100, 109, 1),
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                              '${AppLocalizations.of(context).translate('field_will_show_in_emenu')}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('email')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('email_required_hint')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              value: email,
                              onChanged: (newValue) {
                                email = newValue;
                                refreshController.add('');
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            Visibility(
                              visible: email,
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: Text(
                                      '${AppLocalizations.of(context).translate('email_notification')}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  '${AppLocalizations.of(context).translate('email_notification_hint')}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          TextSpan(text: '\n'),
                                          TextSpan(
                                            text:
                                                '${AppLocalizations.of(context).translate('email_notification_hint_2')}',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    value: allowEmailNotification,
                                    onChanged: (newValue) {
                                      allowEmailNotification = newValue;
                                      refreshController.add('');
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .trailing, //  <-- leading Checkbox
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(40, 0, 0, 0),
                                    child: Divider(
                                      color: Colors.teal.shade100,
                                      thickness: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('self_collect')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            '${AppLocalizations.of(context).translate('self_collect_enable_hint')}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    TextSpan(text: '\n'),
                                    TextSpan(
                                      text:
                                          '${AppLocalizations.of(context).translate('self_collect_enable_hint_2')}',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              value: selfCollect,
                              onChanged: (newValue) {
                                selfCollect = newValue;
                                refreshController.add('');
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('min_purchase')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('min_purchase_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: Container(
                                  width: 80,
                                  height: 50,
                                  child: TextField(
                                    controller: minPurchase,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d*\.?\d*")),
                                    ],
                                    decoration: InputDecoration(
                                        labelText: 'RM',
                                        counterText: '',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.orangeAccent,
                                              width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black45,
                                              width: 1.0),
                                        )),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.date_range,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '${AppLocalizations.of(context).translate('date_time_setting')}',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    89, 100, 109, 1),
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                              '${AppLocalizations.of(context).translate('date_time_setting_description')}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              title: Text(
                                  "${AppLocalizations.of(context).translate('delivery_date')}",
                                  style: TextStyle(fontSize: 15)),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('delivery_date_hint')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              value: deliveryDate,
                              onChanged: (newValue) {
                                deliveryDate = newValue;
                                refreshController.add('');
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            CheckboxListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('delivery_time')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('delivery_time_hint')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              value: deliveryTime,
                              onChanged: (newValue) {
                                deliveryTime = newValue;
                                refreshController.add('');
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing, //  <-- leading Checkbox
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('min_order_day')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('min_order_day_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: Container(
                                  width: 80,
                                  height: 50,
                                  child: TextField(
                                    controller: minOrderDays,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d*\.?\d*")),
                                    ],
                                    maxLength: 2,
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .translate('day'),
                                        counterText: '',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.orangeAccent,
                                              width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black45,
                                              width: 1.0),
                                        )),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('working_day')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('working_day_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Column(
                              children: [workingDayList()],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                              child: Divider(
                                color: Colors.teal.shade100,
                                thickness: 1.0,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${AppLocalizations.of(context).translate('working_time')}',
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${AppLocalizations.of(context).translate('working_time_description')}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    TextSpan(text: '\n'),
                                    TextSpan(
                                      text:
                                          '${AppLocalizations.of(context).translate('working_time_description_2')}',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      readOnly: true,
                                      controller: startTime,
                                      onTap: () =>
                                          selectTime(startTime.text, startTime),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        labelText:
                                            '${AppLocalizations.of(context).translate('start')}',
                                        labelStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('to'),
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
                                      onTap: () =>
                                          selectTime(endTime.text, endTime),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        labelText:
                                            '${AppLocalizations.of(context).translate('end')}',
                                        labelStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.notifications_active,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '${AppLocalizations.of(context).translate('order_reminder')}',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    89, 100, 109, 1),
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                              '${AppLocalizations.of(context).translate('order_reminder_hint')}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                              '${AppLocalizations.of(context).translate('order_reminder_hint_2')}',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                              controller: orderReminder,
                              minLines: 3,
                              maxLines: 5,
                              maxLength: 100,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)
                                      .translate('order_reminder_hint_3'),
                                  hintStyle: TextStyle(fontSize: 14)),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: RaisedButton(
                                elevation: 5,
                                onPressed: () => updateOrderSetting(context),
                                child: Text(
                                  '${AppLocalizations.of(context).translate('update_setting')}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                color: Colors.orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget workingDayList() {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: workingDays.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 3),
        itemBuilder: (BuildContext context, int i) {
          return Card(
            elevation: 2,
            child: ListTile(
              onTap: () {
                workingDays[i] = workingDays[i] == 0 ? 1 : 0;
                refreshController.add('');
              },
              tileColor: workingDays[i] == 0 ? Colors.green : Colors.white,
              title: Text(
                '${AppLocalizations.of(context).translate('day${i + 1}')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: workingDays[i] == 0 ? Colors.white : Colors.black54),
              ),
            ),
          );
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
      controller.text =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    });
  }

  checkingWorkingTime(context) {
    if (startTime.text.isNotEmpty && endTime.text.isNotEmpty) {
      var start = new DateFormat('HH:mm').parse(startTime.text);
      var end = new DateFormat('HH:mm').parse(endTime.text);
      if (end.isAfter(start)) {
        workingTime.startTime = startTime.text;
        workingTime.endTime = endTime.text;
        return true;
      }
    }
    CustomSnackBar.show(context,
        '${AppLocalizations.of(context).translate('invalid_working_time')}');
    return false;
  }

  checkingMinPurchase(context) {
    try {
      var minPurchaseAmount =
          double.parse(minPurchase.text.isEmpty ? '0' : minPurchase.text);
      minPurchase.text = minPurchaseAmount.toStringAsFixed(2);
      return true;
    } catch ($e) {
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('invalid_min_purchase')}');
      return false;
    }
  }

  updateOrderSetting(context) async {
    if (!checkingWorkingTime(context)) return;
    if (!checkingMinPurchase(context)) return;

    Map data = await Domain().updateOrderSetting(
      email ? '0' : '1',
      selfCollect ? '0' : '1',
      deliveryDate ? '0' : '1',
      deliveryTime ? '0' : '1',
      minOrderDays.text.isEmpty ? '0' : minOrderDays.text,
      workingDays.toString(),
      jsonEncode(workingTime),
      minPurchase.text.isEmpty ? '0.00' : minPurchase.text,
      allowEmailNotification ? '0' : '1',
      orderReminder.text,
    );

    if (data['status'] == '1') {
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('update_success')}');
    } else
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }
}
