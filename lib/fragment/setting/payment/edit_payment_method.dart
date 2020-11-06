import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/setting/payment/edit_bank_detail.dart';
import 'package:my/fragment/setting/payment/edit_payment_gateway.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class EditPaymentMethod extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<EditPaymentMethod> {
  var bankDetails = TextEditingController();
  bool manualBankTransfer, cod, fpay;
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
          '${AppLocalizations.of(context).translate('payment_setting')}',
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

                  print(responseJson);

                  Merchant merchant = responseJson
                      .map((jsonObject) => Merchant.fromJson(jsonObject))
                      .toList()[0];

                  bankDetails.text = merchant.bankDetail;
                  manualBankTransfer = merchant.bankTransfer != '1';
                  cod = merchant.cashOnDelivery != '1';
                  fpay = merchant.fpayTransfer != '1';

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
                                            '${AppLocalizations.of(context).translate('payment_setting')}',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    89, 100, 109, 1),
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: '\n'),
                                        TextSpan(
                                          text:
                                          '${AppLocalizations.of(context).translate('payment_setting_description')}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CheckboxListTile(
                              title: Text(
                                  '${AppLocalizations.of(context).translate('bank_transfer')}'),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('bank_transfer_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              value: manualBankTransfer,
                              onChanged: (newValue) {
                                refreshController.add('');
                                manualBankTransfer = newValue;
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
                                  '${AppLocalizations.of(context).translate('cash_on_delivery')}'),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('cash_on_delivery_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              value: cod,
                              onChanged: (newValue) {
                                refreshController.add('');
                                cod = newValue;
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
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Fpay Payment Gateway',
                                    style: TextStyle(fontSize: 16),
                                  )),
                                  RaisedButton(
                                    elevation: 5,
                                    onPressed: () => showPaymentGatewayDialog(),
                                    child: Text(
                                      '${AppLocalizations.of(context).translate('setup')}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  Checkbox(
                                    value: fpay,
                                    onChanged: (newValue) {
                                      refreshController.add('');
                                      fpay = newValue;
                                    },
                                  )
                                ],
                              ),
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
                                        '${AppLocalizations.of(context).translate('bank_detail')}',
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
                                  '${AppLocalizations.of(context).translate('update_payment')}',
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

  Future<void> showPaymentGatewayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return PaymentGatewayDialog();
      },
    );
  }

  updatePayment(context) async {
    if (manualBankTransfer && bankDetails.text.length <= 0) {
      return CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('bank_transfer_hint')}');
    }

    Map data = await Domain().updatePayment(
        bankDetails.text,
        (manualBankTransfer ? '0' : '1'),
        (cod ? '0' : '1'),
        (fpay ? '0' : '1'));

    if (data['status'] == '1') {
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('update_success')}');
    } else
      CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }
}
