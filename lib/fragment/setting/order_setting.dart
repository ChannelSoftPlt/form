import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/utils/domain.dart';

class OrderSetting extends StatefulWidget {
  @override
  _OrderSettingState createState() => _OrderSettingState();
}

class _OrderSettingState extends State<OrderSetting> {
  var bankDetails = TextEditingController();
  bool email, selfCollect, deliveryDate, deliveryTime;
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
          'Order Setting',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 25),
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
                                            text: 'Optional Fields',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    89, 100, 109, 1),
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                              'These fields will shows in your E-Menu',
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
                              title: Text("Email"),
                              subtitle: Text(
                                'Customer required to fill in their email in thier order.',
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
                              title: Text("Self Collect"),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            'Customer enable to select self-collect as delivery method.',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    TextSpan(text: '\n'),
                                    TextSpan(
                                      text:
                                          '* Delivery fee will be waived automatically',
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
                            CheckboxListTile(
                              title: Text("Delivery Date"),
                              subtitle: Text(
                                'Customer able to select the delivery date in their order.',
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
                              title: Text("Delivery Time"),
                              subtitle: Text(
                                'Customer able to select the delivery time in their order.',
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
                                  'Update Setting',
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

  updatePayment(context) async {
    Map data = await Domain().updateOrderSetting(
        email ? '0' : '1',
        selfCollect ? '0' : '1',
        deliveryDate ? '0' : '1',
        deliveryTime ? '0' : '1');

    if (data['status'] == '1') {
      CustomSnackBar.show(context, 'Update Successfully!');
    } else
      CustomSnackBar.show(context, 'Something Went Wrong!');
  }
}
