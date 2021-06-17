import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class WalletQrCodeDialog extends StatefulWidget {
  final String type;

  WalletQrCodeDialog({this.type});

  @override
  _WalletQrCodeDialogState createState() => _WalletQrCodeDialogState();
}

class _WalletQrCodeDialogState extends State<WalletQrCodeDialog> {
  ImageProvider provider;
  File _image;
  final picker = ImagePicker();
  var imagePath;
  var compressedFileSource;

  bool isLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readQrCode(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text(
            '${AppLocalizations.of(context).translate('setup')} ${widget.type}'),
        actions: <Widget>[
          FlatButton(
            child: Text('${AppLocalizations.of(context).translate('cancel')}'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              '${AppLocalizations.of(context).translate('confirm')}',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              updateQrCode(context);
            },
          ),
        ],
        content: mainContent(context));
  }

  Widget mainContent(context) {
    return Container(
        height: 250,
        child: isLoad
            ? Stack(
                fit: StackFit.passthrough,
                overflow: Overflow.visible,
                children: [
                    Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () => _showSelectionDialog(context),
                        child: compressedFileSource != null
                            ? Image.memory(
                                compressedFileSource,
                                height: 250,
                              )
                            : Image.asset(
                                'drawable/no-image-found.png',
                                height: 250,
                              ),
                      ),
                    ),
                    Visibility(
                      visible: compressedFileSource != null,
                      child: Container(
                          padding: EdgeInsets.all(5),
                          height: 250,
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: clearImage,
                          )),
                    ),
                  ])
            : CustomProgressBar());
  }

  getWalletType() {
    switch (widget.type) {
      case 'Touch \'N Go':
        return 'tng';
      case 'Boost':
        return 'boost';
      case 'Duit Now':
        return 'duit_now';
      default:
        return 'sarawak_pay';
    }
  }

  readQrCode(context) async {
    Map data = await Domain().readWalletQrCode(getWalletType());
    setState(() {
      if (data['status'] == '1') {
        if (data['qr_code'][0]['qr_code'] != '') {
          compressedFileSource = base64Decode(
              base64Data(data['qr_code'][0]['qr_code'].split(',').last));
        }
      } else
        CustomToast(
                '${AppLocalizations.of(context).translate('something_went_wrong')}',
                context)
            .show();
      isLoad = true;
    });
  }

  updateQrCode(context) async {
    var qrCode = compressedFileSource != null
        ? 'data:image/jpeg;base64,${base64Encode(compressedFileSource).toString()}'
        : '';

    Map data = await Domain().updateWalletQrCode(qrCode, getWalletType());

    if (data['status'] == '1') {
      CustomToast('${AppLocalizations.of(context).translate('update_success')}',
              context)
          .show();
      Navigator.of(context).pop();
    } else
      CustomToast(
              '${AppLocalizations.of(context).translate('something_went_wrong')}',
              context)
          .show();
  }

  clearImage() {
    setState(() {
      compressedFileSource = null;
    });
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('take_photo_from_where')}"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                          '${AppLocalizations.of(context).translate('gallery')}',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.orangeAccent,
                      icon: Icon(
                        Icons.perm_media,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                        '${AppLocalizations.of(context).translate('camera')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blueAccent,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ));
        });
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

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    imagePath = await picker.getImage(
        imageQuality: isCamera ? 20 : 40,
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // compressFileMethod();
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = (await ImageCropper.cropImage(
        sourcePath: imagePath.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.white38,
            toolbarWidgetColor: Colors.black54,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings:
            IOSUiSettings(title: 'Cropper', aspectRatioLockEnabled: false)));
    if (croppedFile != null) {
      _image = croppedFile;
      compressFileMethod();
    }
  }

  void compressFileMethod() async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    compressedFileSource = await compressFile(file);
    setState(() {});
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<Uint8List> compressFile(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    return result;
  }

  countQuality(int quality) {
    print('quality: $quality');
    if (quality <= 100)
      return 60;
    else if (quality > 100 && quality < 500)
      return 25;
    else
      return 20;
  }
}
