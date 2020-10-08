import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/fragment/product/category/category_dialog.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';

class ProductDetailDialog extends StatefulWidget {
  final Product product;
  final Function() refresh;
  final bool isUpdate;

  ProductDetailDialog({this.product, this.refresh, this.isUpdate});

  @override
  _ProductDetailDialogState createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  final key = new GlobalKey<ScaffoldState>();

  var name = TextEditingController();
  var description = TextEditingController();
  var price = TextEditingController();
  var category = TextEditingController();
  int categoryId = 0;
  bool available = true;
  Product object;

  File _image;
  ImageProvider provider;
  StreamController imageStateStream;

  String imageCode = '-1';
  String imageName = 'no-image-found.png';
  String extension = '';
  var compressedFileSource;

  final picker = ImagePicker();

  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageStateStream = StreamController();
    imageStateStream.add('display');

    if (widget.isUpdate == true) {
      name.text = widget.product.name;
      description.text = widget.product.description;
      price.text = widget.product.price;
      imageName = widget.product.image;
      category.text = widget.product.categoryName;
      available = widget.product.status == 0;
      getUrl();
    }
  }

  leaveConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('confirm_to_exit')}"),
          content:
              Text('${AppLocalizations.of(context).translate('exit_message')}'),
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
                name.clear();
                description.clear();
                price.clear();
                Navigator.of(context).pop();
                _onBackPressed();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onBackPressed() async {
    if (!widget.isUpdate &&
        (name.text.length > 0 ||
            description.text.length > 0 ||
            price.text.length > 0)) {
      leaveConfirmation();
      return null;
    }
    Navigator.of(context).pop();
    return null;
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    price.dispose();
    category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          widget.isUpdate == true
              ? '${AppLocalizations.of(context).translate('update_product')}'
              : '${AppLocalizations.of(context).translate('add_product')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible: widget.isUpdate,
            child: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: Colors.blueGrey,
              ),
              onPressed: () {
                launch(url);
              },
            ),
          ),
          Visibility(
            visible: widget.isUpdate,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red[200],
              ),
              onPressed: () {
                deleteProduct();
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.orangeAccent,
            ),
            onPressed: () {
              //checking
              if (name.text.length <= 0)
                return _showSnackBar('${AppLocalizations.of(context).translate('name_cant_be_blank')}');
              if (price.text.length <= 0)
                return _showSnackBar('${AppLocalizations.of(context).translate('price_cant_be_blank')}');
              //action
              if (widget.isUpdate != true)
                createProduct();
              else
                updateProduct();
            },
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  child: _imageViewWidget(),
                  onTap: () => _showSelectionDialog(context),
                ),
                SizedBox(
                  height: 10,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    controller: name,
                    textAlign: TextAlign.start,
                    minLines: 1,
                    maxLengthEnforced: true,
                    maxLength: 25,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: '${AppLocalizations.of(context).translate('name')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText: '${AppLocalizations.of(context).translate('product_name')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: description,
                    textAlign: TextAlign.start,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 100,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 14),
                      labelText: '${AppLocalizations.of(context).translate('description')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText: '${AppLocalizations.of(context).translate('product_description')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                    ],
                    keyboardType: TextInputType.number,
                    controller: price,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 14),
                      labelText: '${AppLocalizations.of(context).translate('price')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText: '${AppLocalizations.of(context).translate('price')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text('${AppLocalizations.of(context).translate('status')}'),
                    Switch(
                      value: available,
                      onChanged: (value) {
                        setState(() {
                          available = value;
                        });
                      },
                      activeTrackColor: Colors.orangeAccent,
                      activeColor: Colors.deepOrangeAccent,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () => showCategoryDialog(context),
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.orange,
                    ),
                    child: TextField(
                      enabled: false,
                      controller: category,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: 14),
                          labelText: '${AppLocalizations.of(context).translate('category')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          hintText: '${AppLocalizations.of(context).translate('product_category')}',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          suffixIcon: Icon(Icons.arrow_drop_down)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    print("compressFile");

    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    print('before: ${file.lengthSync()}');
    print('after: ${result.length}');
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

  createProduct() async {
    /*
    * create product
    * */
    Map data = await Domain().createProduct(
        new Product(
            name: name.text,
            status: available ? 0 : 1,
            description: description.text,
            image: imageName,
            price: price.text,
            categoryId: categoryId),
        extension,
        imageCode.toString());

    if (data['status'] == '1') {
      _showSnackBar('${AppLocalizations.of(context).translate('product_uploaded')}');
      widget.refresh();
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pop();
    } else if (data['status'] == '4') {
      _showSnackBar('${AppLocalizations.of(context).translate('exceed_limit')}');
    } else
      _showSnackBar('${AppLocalizations.of(context).translate('something_went_wrong')}');
  }

  updateProduct() async {
    /*
    * update product
    * */
    Map data = await Domain().updateProduct(
        new Product(
            productId: widget.product.productId,
            name: name.text,
            status: available ? 0 : 1,
            description: description.text,
            image: imageName,
            price: price.text,
            categoryId: categoryId),
        extension,
        imageCode.toString());

    if (data['status'] == '1') {
      _showSnackBar('${AppLocalizations.of(context).translate('update_success')}');
    } else
      _showSnackBar('${AppLocalizations.of(context).translate('something_went_wrong')}');
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }

  deleteProduct() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text("${AppLocalizations.of(context).translate('delete_message')} \n${widget.product.name}"),
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
              onPressed: () async {
                /*
              * delete product
              * */
                Map data = await Domain()
                    .deleteProduct(widget.product.productId.toString());
                if (data['status'] == '1') {
                  _showSnackBar('${AppLocalizations.of(context).translate('product_delete')}');
                  await Future.delayed(Duration(milliseconds: 300));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else
                  _showSnackBar('${AppLocalizations.of(context).translate('something_went_wrong')}');
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
              title: Text("${AppLocalizations.of(context).translate('take_photo_from_where')}"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text('${AppLocalizations.of(context).translate('gallery')}',
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

  Widget _imageViewWidget() {
    return StreamBuilder(
        stream: imageStateStream.stream,
        builder: (context, object) {
          if (object.data == 'display') {
            if (_image == null) {
              return Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FadeInImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(Domain.imagePath +
                          (widget.product != null
                              ? widget.product.image
                              : 'no-image-found.png')),
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

  showCategoryDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return CategoryDialog(
          onSelect: (categoryName, categoryId) {
            print('category: $categoryId');
            category.text = categoryName;
            //widget.product.categoryId = categoryId;
            this.categoryId = categoryId;
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  getUrl() async {
    this.url = Merchant.fromJson(await SharePreferences().read("merchant")).url;
  }
}
