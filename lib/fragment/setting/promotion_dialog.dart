import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/promotion_dialog.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/HexColor.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class EditPromotionDialog extends StatefulWidget {
  @override
  _EditPromotionDialogState createState() => _EditPromotionDialogState();
}

class _EditPromotionDialogState extends State<EditPromotionDialog> {
  PromotionDialog promotionDialog;

  final key = new GlobalKey<ScaffoldState>();

  var promoTitle = TextEditingController();
  var promoMainTitle = TextEditingController();
  var buttonTittle = TextEditingController();
  var smallTitle = TextEditingController();
  var smallSubtitle = TextEditingController();

  Color textColor = Colors.white;
  Color overLayColor = Colors.white;

  RangeValues values = RangeValues(1, 100);

  StreamController controller = StreamController();
  ImageProvider provider;
  File _image;
  final picker = ImagePicker();
  var imagePath;
  var compressedFileSource;

  //url
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPromotionDialogSetting();
    getUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        actions: [
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context).translate('preview'),
              style: TextStyle(color: Colors.blueGrey),
            ),
            icon: Icon(
              Icons.open_in_new,
              color: Colors.blueGrey,
            ),
            onPressed: () {
              print(url);
              launch(url);
            },
          ),
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context).translate('save'),
              style: TextStyle(color: Colors.blueGrey),
            ),
            icon: Icon(
              Icons.save,
              color: Colors.blueGrey,
            ),
            onPressed: () {
              updatePromotionDialogSetting();
            },
          ),
        ],
        title: Text(
          '${AppLocalizations.of(context).translate('promotion_dialog')}',
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
      body: mainContent(),
    );
  }

  Widget mainContent() {
    return promotionDialog != null
        ? SingleChildScrollView(
          child: Container(
              width: double.infinity,
              child: Column(children: [
                enableDialog(),
                contentLayout(),
                backgroundLayout()
              ])),
        )
        : CustomProgressBar();
  }

  Widget enableDialog() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.all(2.0),
          title: Text(
            AppLocalizations.of(context).translate('enable_promotion_dialog'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            AppLocalizations.of(context)
                .translate('enable_promotion_dialog_description'),
            style: TextStyle(fontSize: 13),
          ),
          value: promotionDialog.promoActive,
          onChanged: (newValue) {
            setState(() {
              promotionDialog.promoActive = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget contentLayout() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('text'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              AppLocalizations.of(context).translate('text_content'),
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: promoMainTitle,
                textAlign: TextAlign.start,
                maxLength: 13,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title),
                  labelText:
                      '${AppLocalizations.of(context).translate('title')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: promoTitle,
                minLines: 2,
                maxLines: 2,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.text_fields),
                  labelText:
                      '${AppLocalizations.of(context).translate('subtitle')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: smallTitle,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title),
                  labelText:
                      '${AppLocalizations.of(context).translate('footer_title')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: smallSubtitle,
                textAlign: TextAlign.start,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.text_fields),
                  labelText:
                      '${AppLocalizations.of(context).translate('sub_footer_title')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 10,
            ),
            TextField(
                keyboardType: TextInputType.text,
                controller: buttonTittle,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.touch_app),
                  labelText:
                      '${AppLocalizations.of(context).translate('button_text')}',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
            SizedBox(
              height: 15,
            ),
            Text(
              AppLocalizations.of(context).translate('text_color'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            ColorPicker(
              pickerColor: textColor,
              onColorChanged: (Color color) =>
                  setState(() => textColor = color),
              showLabel: false,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget backgroundLayout() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: Container(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              AppLocalizations.of(context).translate('background_setting'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              AppLocalizations.of(context)
                  .translate('background_setting_description'),
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context).translate('background_image'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
                stream: controller.stream,
                builder: (context, object) {
                  if (object.data == 'display') {
                    return imageWidget();
                  }
                  return CustomProgressBar();
                }),
            SizedBox(
              height: 30,
            ),
            Text(
              AppLocalizations.of(context).translate('background_color'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            ColorPicker(
              enableAlpha: false,
              pickerColor: overLayColor,
              onColorChanged: (Color color) {
                setState(() {
                  overLayColor = color;
                });
              },
              showLabel: false,
              pickerAreaHeightPercent: 0.5,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context).translate('background_opacity'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: promotionDialog.overlayOpacity,
              min: 0,
              activeColor: Colors.orangeAccent,
              max: 100,
              onChanged: (opacity) {
                setState(() {
                  promotionDialog.overlayOpacity = opacity;
                });
              },
            )
          ])),
    );
  }

  Widget imageWidget() {
    return Stack(
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
        ]);
  }

  clearImage() {
    compressedFileSource = null;
    controller.add('display');
  }

  fetchPromotionDialogSetting() async {
    Map data = await Domain().readPromotionDialogSetting();
    setState(() {
      try {
        if (data['status'] == '1') {
          List responseJson =
              jsonDecode(data['promotion_dialog'][0]['promo_dialog']);

          promotionDialog = responseJson
              .map((jsonObject) => PromotionDialog.fromJson(jsonObject))
              .toList()[0];
        }
      } catch ($e) {
        if (promotionDialog == null)
          promotionDialog = PromotionDialog.presetData();
      }
      promoTitle.text = promotionDialog.promoTitle;
      promoMainTitle.text = promotionDialog.promoMainTitle;
      buttonTittle.text = promotionDialog.buttonTittle;
      smallTitle.text = promotionDialog.smallTitle;
      smallSubtitle.text = promotionDialog.smallSubtitle;

      textColor = HexColor(promotionDialog.textColor);
      overLayColor = HexColor(promotionDialog.overlayColor);

      if (promotionDialog.promoImage.isNotEmpty)
        compressedFileSource = base64Decode(
            base64Data(promotionDialog.promoImage.split(',').last));
      controller.add('display');
    });
  }

  updatePromotionDialogSetting() async {
    promotionDialog.promoTitle = promoTitle.text;
    promotionDialog.promoMainTitle = promoMainTitle.text;
    promotionDialog.buttonTittle = buttonTittle.text;
    promotionDialog.smallTitle = smallTitle.text;
    promotionDialog.smallSubtitle = smallSubtitle.text;
    promotionDialog.textColor = textColor.toHex();
    promotionDialog.overlayColor = overLayColor.toHex();
    promotionDialog.promoImage = compressedFileSource != null
        ? 'data:image/jpeg;base64,${base64Encode(compressedFileSource).toString()}'
        : '';

    Map data = await Domain()
        .updatePromotionDialog('[${jsonEncode(promotionDialog)}]');

    print(jsonEncode(promotionDialog));

    setState(() {
      if (data['status'] == '1') {
        _showSnackBar('update_success');
      }
    });
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 700),
      content: new Text(AppLocalizations.of(context).translate(message)),
    ));
  }

  getUrl() async {
    this.url = await SharePreferences().read('url');
    setState(() {});
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
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )));
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
    controller.add('display');
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
