import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

class EditBankDetail extends StatefulWidget {
  final String bankDetails;
  final Function(String) callBack;

  EditBankDetail({this.bankDetails, this.callBack});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<EditBankDetail> {
  ZefyrController _controller;
  FocusNode _focusNode;
  final converter = NotusHtmlCodec();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ZefyrController(loadFormDescription());
    _focusNode = FocusNode();
  }

  NotusDocument loadFormDescription() {
    String htmlText = widget.bankDetails;
    Delta delta;
    try {
      htmlText = htmlText.replaceAll('<p>', '');
      htmlText = htmlText.replaceAll('</p>', '');
      htmlText = htmlText.replaceAll('<b><b>', '<br>');
      htmlText = htmlText.replaceAll('<br />', '');
      delta = converter.decode(htmlText);
    } catch ($e) {
      delta = converter.decode('<p><\/p>');
    }
    return NotusDocument.fromDelta(delta);
  }

  convertToHtml() {
    var htmlText = converter.encode(_controller.document.toDelta());
    return htmlText.replaceAll('<br><br>', '<br>');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('bank_detail')}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                widget.callBack(convertToHtml());
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: mainContent(context));
  }

  Widget mainContent(context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
        child: ZefyrScaffold(
          child: ZefyrEditor(controller: _controller, focusNode: _focusNode),
        ),
      ),
    );
  }
}
