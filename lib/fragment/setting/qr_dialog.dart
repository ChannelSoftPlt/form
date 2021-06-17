import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class QrDialog extends StatefulWidget {
  @override
  _QrDialogState createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {
  GlobalKey _globalKey = new GlobalKey();

  StreamController refreshStream;
  String url;
  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getURL();
    refreshStream = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title:
        new Text('${AppLocalizations.of(context).translate('qr_code')}'),
        actions: <Widget>[
          RaisedButton(
            child: Text('${AppLocalizations.of(context).translate('close')}'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          RaisedButton(
            color: Colors.orangeAccent,
            child: Text(
              '${AppLocalizations.of(context).translate('share')}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var shareImageSource = await _captureQrCode();
              print(shareImageSource);
              if (shareImageSource != null)
                await WcFlutterShare.share(
                    sharePopupTitle: 'share',
                    fileName: 'share.png',
                    mimeType: 'image/png',
                    bytesOfFile: shareImageSource);
              else
                showToast('invalid_qr_code');
            },
          ),
        ],
        content: StreamBuilder(
            stream: refreshStream.stream,
            builder: (context, object) {
              if (object.hasData && object.data
                  .toString()
                  .length >= 1) {
                return mainContent();
              }
              return Container(
                  height: 500, width: 1000, child: CustomProgressBar());
            }));
  }

  Widget mainContent() {
    return Container(
        alignment: Alignment.center,
        height: 500,
        width: 1000,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: new TextEditingController(text: url),
                maxLines: 1,
                textAlign: TextAlign.start,
                maxLengthEnforced: true,
                enabled: false,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('url'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: new BorderSide(color: Colors.red)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.center,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: QrImage(
                    data: url,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    foregroundColor: pickerColor,
                    size: 220,
                    gapless: true,
                    embeddedImage: AssetImage('drawable/new_logo.jpg'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(30, 30),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
                showLabel: false,
                pickerAreaHeightPercent: 0.3,
              ),
            ],
          ),
        ));
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<Uint8List> _captureQrCode() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData.buffer.asUint8List();

      setState(() {});
      return pngBytes;
    } catch (e) {
      return null;
    }
  }

  base64Data(String data) {
    switch (data.length % 4) {
      case 1:
        break;
      case 2:
        data = data + "==";
        break;
      case 3:
        data = data + "=";
        break;
    }
    return data;
  }

  getURL() async {
    this.url = Merchant
        .fromJson(await SharePreferences().read("merchant"))
        .url;
    refreshStream.add('display');
  }

  showToast(message) {
    CustomToast(
      '${AppLocalizations.of(context).translate(message)}',
      context,
    ).show();
  }
}
