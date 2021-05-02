import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  var minOrderDays = TextEditingController();
  bool email, selfCollect, deliveryDate, deliveryTime;
  List<int> workingDays = [];
  StreamController refreshController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  minOrderDays.text = merchant.minOrderDay ?? 0;

                  var workingDay = jsonDecode(merchant.workingDay);
                  workingDays =
                      workingDay != null ? List.from(workingDay) : null;
                  print(workingDays.length);
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
                                  '${AppLocalizations.of(context).translate('email')}'),
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
                            CheckboxListTile(
                              title: Text(
                                  '${AppLocalizations.of(context).translate('self_collect')}'),
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
                                  "${AppLocalizations.of(context).translate('delivery_date')}"),
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
                                  '${AppLocalizations.of(context).translate('delivery_time')}'),
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
                                  '${AppLocalizations.of(context).translate('min_order_day')}'),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('min_order_day_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: Container(
                                  width: 50,
                                  height: 50,
                                  child: TextField(
                                    controller: minOrderDays,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d*\.?\d*")),
                                    ],
                                    maxLength: 2,
                                    decoration: InputDecoration(
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
                                  '${AppLocalizations.of(context).translate('working_day')}'),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('working_day_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Column(
                              children: [workingDayList()],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: RaisedButton(
                                elevation: 5,
                                onPressed: () => updatePayment(context),
                                child: Text(
                                  '${AppLocalizations.of(context).translate('update_setting')}',
                                  style: TextStyle(color: Colors.white),
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
              tileColor: workingDays[i] == 0 ? Colors.lightGreen : Colors.white,
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

  updatePayment(context) async {
    print(workingDays.toString());
    Map data = await Domain().updateOrderSetting(
        email ? '0' : '1',
        selfCollect ? '0' : '1',
        deliveryDate ? '0' : '1',
        deliveryTime ? '0' : '1',
        minOrderDays.text.isEmpty ? '0' : minOrderDays.text,
        workingDays.toString());

    if (data['status'] == '1') {
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('update_success')}');
    } else
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }
}
