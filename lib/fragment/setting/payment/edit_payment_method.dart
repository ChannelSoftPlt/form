import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/setting/payment/edit_bank_detail.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/utils/domain.dart';

class EditPaymentMethod extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<EditPaymentMethod> {
  var bankDetails = TextEditingController();
  bool manualBankTransfer, cod;
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
          'Payment Setting|付款设定',
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

                  bankDetails.text = merchant.bankDetail;
                  manualBankTransfer = merchant.bankTransfer != '1';
                  cod = merchant.cashOnDelivery != '1';

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
        builder: (context, snapshot) {
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
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.payment,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Payment Setting|付款设定',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(89, 100, 109, 1),
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              title: Text("Manual Bank Transfer|银行转账"),
                              value: manualBankTransfer,
                              onChanged: (newValue) {
                                refreshController.add('');
                                manualBankTransfer = newValue;
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                            CheckboxListTile(
                              title: Text("Cash On Delivery|货到付款"),
                              value: cod,
                              onChanged: (newValue) {
                                refreshController.add('');
                                cod = newValue;
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: manualBankTransfer,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.home,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        'Bank Details|银行信息',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                                89, 100, 109, 1)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditBankDetail(
                                            bankDetails: bankDetails.text,
                                            callBack: (value) async {
                                              await Future.delayed(
                                                  Duration(milliseconds: 500));
                                              Navigator.pop(context);
                                              bankDetails.text = value;
                                              refreshController.add('');
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Html(
                                          data: bankDetails.text,
                                          //Optional parameters:
                                          style: {
                                            "html": Style(
                                              backgroundColor: Colors.white,
                                              color: Colors.black,
                                            ),
                                            "h1": Style(
                                              textAlign: TextAlign.center,
                                            ),
                                            "table": Style(
                                              backgroundColor: Color.fromARGB(
                                                  0x50, 0xee, 0xee, 0xee),
                                            ),
                                            "tr": Style(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey)),
                                            ),
                                            "th": Style(
                                              padding: EdgeInsets.all(6),
                                              backgroundColor: Colors.grey,
                                            ),
                                            "td": Style(
                                              padding: EdgeInsets.all(6),
                                            ),
                                            "var": Style(fontFamily: 'serif'),
                                          },
                                          customRender: {
                                            "flutter": (RenderContext context,
                                                Widget child, attributes, _) {
                                              return FlutterLogo(
                                                style:
                                                    (attributes['horizontal'] !=
                                                            null)
                                                        ? FlutterLogoStyle
                                                            .horizontal
                                                        : FlutterLogoStyle
                                                            .markOnly,
                                                textColor: context.style.color,
                                                size: context
                                                        .style.fontSize.size *
                                                    5,
                                              );
                                            },
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                  'Update Payment',
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
    if (manualBankTransfer && bankDetails.text.length <= 0) {
      return CustomSnackBar.show(
          context, 'Manual Bank Transfer require bank details!');
    }

    Map data = await Domain().updatePayment(
        bankDetails.text, (manualBankTransfer ? '0' : '1'), (cod ? '0' : '1'));

    if (data['status'] == '1') {
      CustomSnackBar.show(context, 'Update Successfully!');
    } else
      CustomSnackBar.show(context, 'Something Went Wrong!');
  }
}
