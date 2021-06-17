import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/setting/payment/edit_payment_gateway.dart';
import 'package:my/fragment/setting/payment/edit_qrcode.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:html2md/html2md.dart' as html2md;
import 'package:delta_markdown/delta_markdown.dart';

class EditPaymentMethod extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<EditPaymentMethod> {
  bool manualBankTransfer,
      cod,
      fpay,
      allowFpay,
      allowTNG,
      allowBoost,
      allowDuit,
      allowSarawak;
  StreamController refreshController;

  var taxPercent = TextEditingController();
  QuillController _controller = QuillController.basic();

  final key = new GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    refreshController = StreamController();
    return Scaffold(
      key: key,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              updatePayment(context);
            },
          ),
        ],
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('payment_setting')}',
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

                  print(responseJson);

                  Merchant merchant = responseJson
                      .map((jsonObject) => Merchant.fromJson(jsonObject))
                      .toList()[0];

                  loadBankDetail(merchant.bankDetail);
                  manualBankTransfer = merchant.bankTransfer != '1';
                  cod = merchant.cashOnDelivery != '1';
                  fpay = merchant.fpayTransfer != '1';
                  allowFpay = merchant.allowfPay != '1';
                  allowTNG = merchant.allowTNG != '1';
                  allowBoost = merchant.allowBoost != '1';
                  allowDuit = merchant.allowDuit != '1';
                  allowSarawak = merchant.allowSarawak != '1';
                  taxPercent.text = merchant.taxPercent;

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
                        padding: const EdgeInsets.fromLTRB(5, 15, 5, 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.payment_outlined,
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
                                '${AppLocalizations.of(context).translate('bank_transfer')}',
                                style: TextStyle(fontSize: 14),
                              ),
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
                                '${AppLocalizations.of(context).translate('cash_on_delivery')}',
                                style: TextStyle(fontSize: 14),
                              ),
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
                            Visibility(
                              visible: allowFpay,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                                child: Divider(
                                  color: Colors.teal.shade100,
                                  thickness: 1.0,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: allowFpay,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 12, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Image.asset(
                                        'drawable/fpay.png',
                                        height: 55,
                                      ),
                                    )),
                                    Expanded(
                                      flex: 2,
                                      child: RaisedButton(
                                        elevation: 5,
                                        onPressed: () =>
                                            showPaymentGatewayDialog(),
                                        child: Text(
                                          '${AppLocalizations.of(context).translate('setup')}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                      ),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('fpay_description')}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      'drawable/tng.png',
                                      height: 55,
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: RaisedButton(
                                      elevation: 5,
                                      onPressed: () =>
                                          showQrCodeDialog('Touch \'N Go'),
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('upload_qrcode')}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                  ),
                                  Checkbox(
                                    value: allowTNG,
                                    onChanged: (newValue) {
                                      refreshController.add('');
                                      allowTNG = newValue;
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('tng_description')}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      'drawable/boost.png',
                                      height: 55,
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: RaisedButton(
                                      elevation: 5,
                                      onPressed: () =>
                                          showQrCodeDialog('Boost'),
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('upload_qrcode')}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                  ),
                                  Checkbox(
                                    value: allowBoost,
                                    onChanged: (newValue) {
                                      refreshController.add('');
                                      allowBoost = newValue;
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('boost_description')}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      'drawable/duit_now.png',
                                      height: 55,
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: RaisedButton(
                                      elevation: 5,
                                      onPressed: () =>
                                          showQrCodeDialog('Duit Now'),
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('upload_qrcode')}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                  ),
                                  Checkbox(
                                    value: allowDuit,
                                    onChanged: (newValue) {
                                      refreshController.add('');
                                      allowDuit = newValue;
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('duit_now_description')}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      'drawable/sarawak_pay.png',
                                      height: 55,
                                    ),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: RaisedButton(
                                      elevation: 5,
                                      onPressed: () =>
                                          showQrCodeDialog('Sarawak Pay'),
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('upload_qrcode')}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                  ),
                                  Checkbox(
                                    value: allowSarawak,
                                    onChanged: (newValue) {
                                      refreshController.add('');
                                      allowSarawak = newValue;
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('sarawak_pay_description')}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
                                  '${AppLocalizations.of(context).translate('tax_rate')}'),
                              subtitle: Text(
                                '${AppLocalizations.of(context).translate('tax_description')}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: Container(
                                width: 70,
                                height: 50,
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: taxPercent,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  decoration: InputDecoration(
                                      hintText: '6',
                                      labelText: '%',
                                      counterText: '',
                                      labelStyle: TextStyle(
                                          color: Colors.blueGrey, fontSize: 15),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.orangeAccent,
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black45, width: 1.0),
                                      )),
                                ),
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
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              child: QuillEditor(
                                                controller: _controller,
                                                scrollController:
                                                    ScrollController(),
                                                scrollable: true,
                                                focusNode: _focusNode,
                                                autoFocus: false,
                                                readOnly: false,
                                                expands: false,
                                                padding: EdgeInsets.zero,
                                                customStyles: DefaultStyles(
                                                    color: Colors.green),
                                              ),
                                            )),
                                            QuillToolbar.basic(
                                              toolbarIconSize: 20,
                                              controller: _controller,
                                              showCodeBlock: false,
                                              showListCheck: false,
                                              showIndent: false,
                                              showBackgroundColorButton: false,
                                              showColorButton: false,
                                              showUnderLineButton: false,
                                              showHeaderStyle: false,
                                              showQuote: false,
                                              showStrikeThrough: false,
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
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

  loadBankDetail(bankDetails) {
    var htmlData;
    try {
      if (bankDetails == '<br/>' || bankDetails == '')
        bankDetails = 'Bank Detail';
      bankDetails = html2md.convert(bankDetails);
      htmlData = jsonDecode(markdownToDelta(bankDetails));
    } catch ($e) {
      if (bankDetails == '<br/>' || bankDetails == '')
        bankDetails = 'Bank Detail';
      htmlData = jsonDecode(markdownToDelta(bankDetails));
    }
    _controller = QuillController(
        document: Document.fromJson(htmlData),
        selection: TextSelection.collapsed(offset: 0));
  }

  String getBankDetail() {
    try {
      var markdown =
          deltaToMarkdown(jsonEncode(_controller.document.toDelta()));
      var html = md.markdownToHtml(markdown);
      return html.replaceAll("\n", "<br/>");
    } catch ($e) {
      return 'format_not_support';
    }
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

  Future<void> showQrCodeDialog(type) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WalletQrCodeDialog(
          type: type,
        );
      },
    );
  }

  updatePayment(context) async {
    Map qrCode = await Domain().checkQRCode();
    /**
     * if enable tng must upload qr code first
     */
    if (allowTNG) {
      if (!qrCode['touch_n_go']) {
        _showSnackBar('no_qr_code');
        return;
      }
    }
    /**
     * if enable boost must upload qr code first
     */
    if (allowBoost) {
      if (!qrCode['boost']) {
        _showSnackBar('no_boost_qr_code');
        return;
      }
    }
    /**
     * if enable duit now must upload qr code first
     */
    if (allowDuit) {
      if (!qrCode['duit_now']) {
        _showSnackBar('no_duit_now_qr_code');
        return;
      }
    }
    /**
     * if enable sarawak must upload qr code first
     */
    if (allowSarawak) {
      if (!qrCode['sarawak_pay']) {
        _showSnackBar('no_sarawak_pay_qr_code');
        return;
      }
    }
    /**
     * if enable manual bank transfer must key in bank details
     */
    var bankDetails = getBankDetail();
    if (manualBankTransfer && bankDetails.length <= 0) {
      _showSnackBar('bank_transfer_hint');
      return;
    }
    /**
     * invalid format
     */
    if (bankDetails == 'format_not_support') {
      _showSnackBar('invalid_character');
      return;
    }
    Map data = await Domain().updatePayment(
        bankDetails,
        manualBankTransfer ? '0' : '1',
        cod ? '0' : '1',
        fpay ? '0' : '1',
        allowTNG ? '0' : '1',
        allowBoost ? '0' : '1',
        allowDuit ? '0' : '1',
        allowSarawak ? '0' : '1',
        taxPercent.text.isEmpty ? '0' : taxPercent.text);

    if (data['status'] == '1') {
      _showSnackBar('update_success');
    } else
      _showSnackBar('something_went_wrong');
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate(message))));
  }
}
