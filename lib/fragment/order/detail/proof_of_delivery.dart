import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/object/order.dart';
import 'package:flutter/material.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:toast/toast.dart';

class ProofOfDelivery extends StatefulWidget {
  final Order orders;
  final Function(String message) refresh;

  ProofOfDelivery({Key key, this.orders, this.refresh}) : super(key: key);

  @override
  _ProofOfDeliveryState createState() => _ProofOfDeliveryState();
}

class _ProofOfDeliveryState extends State<ProofOfDelivery> {
  File _image;
  ImageProvider provider;
  StreamController imageStateStream;

  String imageCode = '-1';
  String imageName;
  String extension = '';
  final picker = ImagePicker();
  var compressedFileSource;

  var key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.orders.proofPhoto);
    imageStateStream = StreamController();
    imageStateStream.add('display');

    imageName = widget.orders.proofPhoto != null
        ? widget.orders.proofPhoto
        : 'no-image-found.png';
  }

  @override
  Widget build(BuildContext context) {
    print(imageName);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).translate('proof_of_delivery')}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.teal.shade100,
              thickness: 1.0,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${AppLocalizations.of(context).translate('take_photo')}',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              child: InkWell(
                child: _imageViewWidget(),
                onTap: () {
                  print('image name: $imageName');
                  if (imageName == 'no-image-found.png' || imageName == 'test.png' || imageName == '')
                    _showSelectionDialog(context);
                },
              ),
            ),
            Visibility(
              visible: imageCode != '-1',
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  elevation: 5,
                  onPressed: () => uploadImage(context),
                  child: Text(
                    '${AppLocalizations.of(context).translate('upload_photo')}',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.green,
                ),
              ),
            ),
            Visibility(
              visible: imageName != 'no-image-found.png' && imageName != 'test.png',
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  elevation: 5,
                  onPressed: () => deleteProofImage(context),
                  child: Text(
                    '${AppLocalizations.of(context).translate('remove_photo')}',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.red,
                ),
              ),
            ),
            Divider(
              color: Colors.teal.shade100,
              thickness: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageViewWidget() {
    return StreamBuilder(
        stream: imageStateStream.stream,
        builder: (context, object) {
          if (object.data == 'display') {
            if (_image == null) {
              return Container(
                  constraints: BoxConstraints(maxHeight: 150),
                  child: FadeInImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(Domain.proofImgPath +
                          (widget.orders.proofPhoto != null
                              ? imageName
                              : 'no-image-found.png')),
                      placeholder: NetworkImage(
                          '${Domain.proofImgPath}no-image-found.png')));
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

  //delete gallery from cloud
  uploadImage(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('upload_photo_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('upload_photo_description')}"),
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
              * proceed image upload
              * */
                Map data = await Domain()
                    .updateProofPhoto(widget.orders.id.toString(), imageCode);

                if (data['status'] == '1') {
                  widget.refresh('upload_success');
                  Navigator.of(context).pop();
                  /*
                  * after delete image open back the image selection dialog
                  * */
                } else
                  showToast('something_went_wrong');
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

  //delete gallery from cloud
  deleteProofImage(context) async {
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
                Map data = await Domain()
                    .deleteProofImage(imageName, widget.orders.id.toString());
                print(data);
                //delete success
                if (data['status'] == '1') {
                  widget.refresh('delete_success');
                  await Future.delayed(Duration(milliseconds: 250));
                  Navigator.of(context).pop();
                  /*
                  * after delete image open back the image selection dialog
                  * */
                  // setState(() {
                  //   imageName = 'no-image-found.png';
                  //   _image = null;
                  //   _showSelectionDialog(context);
                  // });
                } else
                  showToast('something_went_wrong');
              },
            ),
          ],
        );
      },
    );
  }

  showToast(message) {
    CustomToast('${AppLocalizations.of(context).translate(message)}', context,
            gravity: Toast.BOTTOM)
        .show();
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
    this.imageName = file.path.split('/').last;
    this.extension = imageName.split('.').last;
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
}
