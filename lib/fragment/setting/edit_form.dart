import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/object/form.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/HexColor.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zefyr/zefyr.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class EditForm extends StatefulWidget {
  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  FormSetting form;
  final key = new GlobalKey<ScaffoldState>();
  var videoLink = TextEditingController();
  var formName = TextEditingController();

  //form image purpose
  File _image;
  ImageProvider provider;
  StreamController imageStateStream;
  String imageCode = '-1';
  String extension = '';
  final picker = ImagePicker();
  var compressedFileSource;

  //description purpose
  final converter = NotusHtmlCodec();
  ZefyrController _controller;
  FocusNode _focusNode;

  //background color
  Color backgroundColor = Colors.white;

  //url
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFormSetting();
    getUrl();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    imageStateStream = StreamController();
    imageStateStream.add('display');

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
              updateFormSetting();
            },
          ),
        ],
        title: Text(
          '${AppLocalizations.of(context).translate('form_setting')}',
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
    return form != null
        ? Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: SingleChildScrollView(
              child: Container(
                  color: backgroundColor,
                  width: double.infinity,
                  child: Column(children: [
                    widgetStatus(),
                    widgetBannerLayout(),
                    widgetDescription(),
                    widgetProductLayout(),
                    widgetBackgroundColor()
                  ])),
            ),
          )
        : CustomProgressBar();
  }

  widgetDescription() {
    return Container(
      height: 350,
      child: Card(
        margin: EdgeInsets.all(15),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).translate('form_description')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(
                  color: Colors.teal.shade100,
                  thickness: 1.0,
                ),
              ),
              Expanded(
                child: ZefyrScaffold(
                  child: ZefyrEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  widgetStatus() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).translate('form_name')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 15),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(
                  color: Colors.teal.shade100,
                  thickness: 1.0,
                ),
              ),
              TextField(
                  keyboardType: TextInputType.text,
                  controller: formName,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.link),
                    labelText:
                        '${AppLocalizations.of(context).translate('name')}',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    hintText:
                        '${AppLocalizations.of(context).translate('my_form')}',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${AppLocalizations.of(context).translate('form_status')}'),
                  Switch(
                    value: form.status == 0,
                    onChanged: (value) {
                      setState(() {
                        form.status = value ? 0 : 1;
                      });
                    },
                    activeTrackColor: Colors.orangeAccent,
                    activeColor: Colors.deepOrangeAccent,
                  ),
                ],
              ),
              Text(
                '${AppLocalizations.of(context).translate('form_status_description')}',
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ],
          )),
    );
  }

  widgetBannerLayout() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('form_banner')}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            form.bannerStatus == 0
                ? InkWell(
                    onTap: () {
                      if (form.formBanner == 'no-image-found.png' ||
                          form.formBanner == 'test.png')
                        _showSelectionDialog(context);
                      else
                        deleteBannerImage();
                    },
                    child: banner())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                          keyboardType: TextInputType.text,
                          controller: videoLink,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.link),
                            labelText:
                                '${AppLocalizations.of(context).translate('video_link')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText:
                                'https://www.youtube.com/embed/ejhfMu8z578',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('video_link_description'),
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.black12, width: 1.5)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          AppLocalizations.of(context).translate('banner_type'),
                          style: TextStyle(fontSize: 15),
                        )),
                    Expanded(
                      flex: 2,
                      child: DropdownButton(
                          isExpanded: true,
                          itemHeight: 50,
                          value: form.bannerStatus,
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                          items: [
                            DropdownMenuItem(
                              child: Text(AppLocalizations.of(context)
                                  .translate('photo')),
                              value: 0,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                AppLocalizations.of(context).translate('video'),
                                textAlign: TextAlign.center,
                              ),
                              value: 1,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              form.bannerStatus = value;
                            });
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  widgetProductLayout() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).translate('product_layout')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 15),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(
                  color: Colors.teal.shade100,
                  thickness: 1.0,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Image.asset(
                          form.productViewPhone == 0
                              ? 'drawable/active_list.png'
                              : 'drawable/inactive_list.png',
                          height: 70,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('list_layout'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: form.productViewPhone == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: form.productViewPhone == 0
                                  ? Colors.orangeAccent
                                  : Colors.blueGrey),
                        ),
                        Radio(
                          value: 0,
                          activeColor: Colors.orangeAccent,
                          groupValue: form.productViewPhone,
                          onChanged: (value) {
                            setState(() {
                              form.productViewPhone = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Image.asset(
                          form.productViewPhone == 1
                              ? 'drawable/active_grid.png'
                              : 'drawable/inactive_grid.png',
                          height: 70,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('grid_layout'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: form.productViewPhone == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: form.productViewPhone == 1
                                  ? Colors.orangeAccent
                                  : Colors.blueGrey),
                        ),
                        Radio(
                          value: 1,
                          activeColor: Colors.orangeAccent,
                          groupValue: form.productViewPhone,
                          onChanged: (value) {
                            setState(() {
                              form.productViewPhone = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '${AppLocalizations.of(context).translate('layout_description')}',
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ],
          )),
    );
  }

  widgetBackgroundColor() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).translate('background_color')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(
                  color: Colors.teal.shade100,
                  thickness: 1.0,
                ),
              ),
              ColorPicker(
                pickerColor: backgroundColor,
                onColorChanged: changeColor,
                showLabel: false,
                pickerAreaHeightPercent: 0.5,
              ),
            ],
          )),
    );
  }

  void changeColor(Color color) {
//    form.formColor
    setState(() => backgroundColor = color);
  }

  Widget banner() {
    return StreamBuilder(
        stream: imageStateStream.stream,
        builder: (context, object) {
          if (object.data == 'display') {
            if (_image == null) {
              return Container(
                  width: double.infinity,
                  child: FadeInImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          Domain.imagePath.toString() + form.formBanner),
                      placeholder: NetworkImage(
                          '${Domain.imagePath}no-image-found.png')));
            } else
              return Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: Image(
                  image: provider,
                  fit: BoxFit.fill,
                ),
              );
          }
          return Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: Center(
              child: CustomProgressBar(),
            ),
          );
        });
  }

  fetchFormSetting() async {
    Map data = await Domain().readFormSetting();
    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['form'];
        print(data);
        form = responseJson
            .map((jsonObject) => FormSetting().fromJson(jsonObject))
            .toList()[0];

        videoLink.text = form.bannerVideoLink;
        formName.text = form.name;
        _controller = ZefyrController(loadFormDescription());
        backgroundColor = HexColor(form.formColor);
      });
    }
  }

  NotusDocument loadFormDescription() {
    Delta delta = converter.decode(form.description);
    return NotusDocument.fromDelta(delta);
  }

  updateFormSetting() async {
    form.description = converter.encode(_controller.document.toDelta());
    form.formColor = backgroundColor.toHex();
    form.bannerVideoLink = videoLink.text.isEmpty ? '' : videoLink.text;
    form.name = formName.text;
    /*
    * update form
    * */
    Map data =
        await Domain().updateFormSetting(form, imageCode.toString(), extension);

    if (data['status'] == '1') {
      //for easy delete image purpose
      form.formBanner = data['form_banner'];
      //avoid double upload same image
      imageCode = '-1';

      _showSnackBar(
          '${AppLocalizations.of(context).translate('update_success')}');
    } else
      _showSnackBar(
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }

  //delete banner image from storage
  deleteBannerImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('delete_product_image')}"),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                /*
              * proceed item delete from cloud
              * */
                Map data = await Domain().deleteFormBanner(form.formBanner);
                //delete success
                if (data['status'] == '1') {
                  _showSnackBar(
                      '${AppLocalizations.of(context).translate('image_delete_success')}');
                  await Future.delayed(Duration(milliseconds: 250));
                  Navigator.of(context).pop();
                  /*
                  * after delete image open back the image selection dialog
                  * */
                  setState(() {
                    form.formBanner = 'no-image-found.png';
                    _image = null;
                    _showSelectionDialog(context);
                  });
                } else
                  _showSnackBar(
                      '${AppLocalizations.of(context).translate('something_went_wrong')}');
              },
            ),
          ],
        );
      },
    );
  }

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

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _image = File(pickedFile.path);

    compressFileMethod();
  }

  void compressFileMethod() async {
    imageStateStream.add('processing-image');
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    compressedFileSource = await compressFile(file);
    ImageProvider provider = MemoryImage(compressedFileSource);
    /*
    * image file
    * */
    this.provider = provider;
    this.imageCode = base64.encode(compressedFileSource);
    form.formBanner = file.path.split('/').last;
    this.extension = form.formBanner.split('.').last;
    setState(() {
      imageStateStream.add('display');
    });
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
    if (quality <= 100)
      return 60;
    else if (quality > 100 && quality < 500)
      return 25;
    else
      return 20;
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  getUrl() async {
    this.url = Merchant.fromJson(await SharePreferences().read("merchant")).url;
    setState(() {});
  }
}
