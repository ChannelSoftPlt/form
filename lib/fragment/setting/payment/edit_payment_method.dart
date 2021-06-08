import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
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
  bool manualBankTransfer, cod, fpay, allowFpay, allowTNG;
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
                                      onPressed: () => showTngQrCodeDialog(),
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
                                                  // true for view only mode
                                                ),
                                              ),
                                            ),
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

  Future<void> showTngQrCodeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return TngQrCodeDialog();
      },
    );
  }

  Future<bool> qrCodeIsUploaded(context) async {
    Map data = await Domain().readTngQrCode();
    if (data['status'] == '1') {
      if (data['qr_code'][0]['tng_payment_qrcode'] != '') {
        return true;
      }
    }
    return false;
  }

  updatePayment(context) async {
    /**
     * if enable tng must upload qr code first
     */
    if (allowTNG) {
      bool isQrCodeUpload = await qrCodeIsUploaded(context);
      if (!isQrCodeUpload)
        return CustomSnackBar.show(
            context, '${AppLocalizations.of(context).translate('no_qr_code')}');
    }
    /**
     * if enable manual bank transfer must key in bank details
     */
    var bankDetails = getBankDetail();
    if (manualBankTransfer && bankDetails.length <= 0) {
      return CustomSnackBar.show(context,
          '${AppLocalizations.of(context).translate('bank_transfer_hint')}');
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
        taxPercent.text.isEmpty ? '0' : taxPercent.text);

    if (data['status'] == '1') {
      _showSnackBar('update_success');
    } else
      _showSnackBar('something_went_wrong');
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(AppLocalizations.of(context).translate(message)),
    ));
  }
}
