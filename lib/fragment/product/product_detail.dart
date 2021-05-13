import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:my/fragment/product/category/category_dialog.dart';
import 'package:my/fragment/product/variant/variant_layout.dart';
import 'package:my/object/imageGallery/image.dart';
import 'package:my/object/imageGallery/product_gallery.dart';
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
  final Function(String) refresh;
  final bool isUpdate;

  ProductDetailDialog({this.product, this.refresh, this.isUpdate});

  @override
  _ProductDetailDialogState createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  final key = new GlobalKey<ScaffoldState>();
  Product initialProduct;

  var name = TextEditingController();
  var description = TextEditingController();
  var price = TextEditingController();
  var category = TextEditingController();
  var stock = TextEditingController();
  int categoryId = 0;
  bool available = true;
  String variation = '';
  Product object;

  //image purpose
  final picker = ImagePicker();
  File _image;
  ImageProvider provider;
  StreamController imageStateStream;
  String imageCode = '-1';
  String imageName = 'no-image-found.png';
  String extension = '';
  var compressedFileSource;

  //image gallery purpose
  List<ProductGallery> galleryList = [];
  List<Asset> selectedImages = [];
  String error = 'No Error Detected';
  int galleryLimit = 0;

  //on back press purpose
  bool confirmExit = false;
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageStateStream = StreamController();
    imageStateStream.add('display');

    if (widget.isUpdate == true) {
      print(widget.product.name);
      name.text = widget.product.name;
      description.text = widget.product.description;
      price.text = widget.product.price;
      imageName = widget.product.image;
      category.text = widget.product.categoryName;
      categoryId = widget.product.categoryId;
      available = widget.product.status == 0;
      variation = widget.product.variation;
      stock.text = widget.product.stock;

      getUrl();
      getProductGallery();
      //for On Back Press checking purpose
      setInitialObject();
    }
    getGalleryLimit();
    setGalleryButton(true);
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
                if (widget.isUpdate) {
                  confirmExit = true;
                  reverseObject();
                } else {
                  name.clear();
                  description.clear();
                  price.clear();
                }
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

    if (widget.isUpdate && !confirmExit) {
      updateObject();
      if (jsonEncode(initialProduct).toString() !=
          jsonEncode(widget.product).toString()) {
        leaveConfirmation();
        return null;
      }
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
                fontSize: 16),
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
                return _showSnackBar(
                    '${AppLocalizations.of(context).translate('name_cant_be_blank')}');
              if (price.text.length <= 0)
                return _showSnackBar(
                    '${AppLocalizations.of(context).translate('price_cant_be_blank')}');
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
        child: Theme(
          data: new ThemeData(
            primaryColor: Colors.orange,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  imagePart(),
                  SizedBox(
                    height: 10,
                  ),
                  bottomPart(),
                  SizedBox(
                    height: 10,
                  ),
                  VariantLayout(
                    variant: variation,
                    onChange: (variation) {
                      print('on change variation: $variation');
                      setState(() {
                        this.variation = variation;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imagePart() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                '${AppLocalizations.of(context).translate('product_image')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.black26,
              child: InkWell(
                child: _imageViewWidget(),
                onTap: () {
                  if (imageName == 'no-image-found.png' ||
                      imageName == 'test.png')
                    _showSelectionDialog(context);
                  else
                    deleteProductImage();
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10.0,
              child: new Center(
                child: new Container(
                  margin:
                      new EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                  height: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                '${AppLocalizations.of(context).translate('product_gallery')}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Container(
              height: 90,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                children: galleryList
                    .asMap()
                    .map((index, imageGallery) =>
                        MapEntry(index, imageGalleryList(imageGallery, index)))
                    .values
                    .toList(),
                onReorder: _onReorder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomPart() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${AppLocalizations.of(context).translate('product_detail')}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
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
              height: 10,
            ),
            TextField(
              controller: name,
              textAlign: TextAlign.start,
              minLines: 1,
              maxLengthEnforced: true,
              maxLength: 75,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).translate('name')}',
                labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                hintText:
                    '${AppLocalizations.of(context).translate('product_name')}',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              controller: description,
              textAlign: TextAlign.start,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                labelText:
                    '${AppLocalizations.of(context).translate('description')}',
                labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                hintText:
                    '${AppLocalizations.of(context).translate('product_description')}',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: price,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                labelText: '${AppLocalizations.of(context).translate('price')}',
                labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                hintText: '${AppLocalizations.of(context).translate('price')}',
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal)),
              ),
            ),
            SizedBox(
              height: 15,
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
                      labelText:
                          '${AppLocalizations.of(context).translate('category')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText:
                          '${AppLocalizations.of(context).translate('product_category')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: Icon(Icons.arrow_drop_down)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              elevation: 2,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                title: Text(
                  '${AppLocalizations.of(context).translate('stock')}',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${AppLocalizations.of(context).translate('stock_description')}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  width: 70,
                  child: TextField(
                    controller: stock,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.black12)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

/*
*
*
* ------------------------------------------product gallery purpose--------------------------------------------------
*
*
* */
  getProductGallery() {
    if (widget.product.gallery != '') {
      List responseJson = jsonDecode(widget.product.gallery);
      galleryList.addAll(responseJson
          .map((jsonObject) => ProductGallery.fromJson(jsonObject))
          .toList());
    }
  }

  setGalleryButton(bool add) {
    setState(() {
      if (add)
        galleryList
            .add(ProductGallery(imageName: 'add-gallery-icon.png', status: 0));
      else
        galleryList.removeLast();
    });
  }

  _onReorder(int oldIndex, int newIndex) {
    if (oldIndex != galleryList.length - 1 && newIndex != galleryList.length) {
      setState(() {
        if (newIndex > galleryList.length) newIndex = galleryList.length;
        if (oldIndex < newIndex) newIndex--;

        ProductGallery gallery = galleryList[oldIndex];
        galleryList.removeAt(oldIndex);
        galleryList.insert(newIndex, gallery);
      });
    }
  }

  Widget imageGalleryList(ProductGallery imageGallery, int position) {
    return Stack(
      key: Key(imageGallery.imageName),
      children: <Widget>[
        Container(
          color: Colors.grey[200],
          margin: const EdgeInsets.all(5.0),
          child: InkWell(
              onTap: () {
                if (position == galleryList.length - 1) {
                  if (galleryLimit - countGalleryLimit() > 0)
                    pickMultipleImages();
                  else
                    _showSnackBar(
                        '${AppLocalizations.of(context).translate('reach_gallery_limit')} $galleryLimit!');
                }
              },
              child: getImageView(imageGallery, position)),
        ),
        if (position != galleryList.length - 1)
          Positioned.fill(
              child: InkWell(
            onTap: () {
              print('selected status: ${imageGallery.status}');
              if (imageGallery.status == 1)
                deleteFromList(position);
              else
                deleteImageGallery(imageGallery.imageName, position);
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 20,
                  )),
            ),
          )),
      ],
    );
  }

  Widget getImageView(ProductGallery imageGallery, position) {
    if (imageGallery.status == null || imageGallery.status == 0) {
      if (position != galleryList.length - 1) {
        return FadeInImage(
            fit: BoxFit.contain,
            width: 120,
            image: NetworkImage(
                Domain.imagePath.toString() + '${imageGallery.imageName}'),
            placeholder: NetworkImage('${Domain.imagePath}no-image-found.png'));
      } else
        return Container(
          padding: const EdgeInsets.all(20.0),
          width: 120,
          child: Image.asset('drawable/add-gallery-icon.png',
              width: 120, fit: BoxFit.contain),
        );
    } else
      return Image(
        fit: BoxFit.contain,
        width: 120,
        image: imageGallery.imageProvider,
      );
  }

  Future<void> pickMultipleImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: galleryLimit - countGalleryLimit(),
        enableCamera: true,
        selectedAssets: selectedImages,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#2F4F4F",
          actionBarTitleColor: '#FF9800',
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#FF9800",
        ),
      );
    } on Exception {}

    if (!mounted) return;
    if (resultList.length <= 0) return;
    setState(() async {
      error = error;
      selectedImages = resultList;
      deleteTempImageGallery();

      for (Asset asset in resultList) {
        //image provider for local display purpose
        ImageProvider provider = await compressGalleryImage(asset);
        String imageCode = base64.encode(compressedFileSource);

        galleryList.add(ProductGallery(
            imageProvider: provider,
            imageCode: imageCode,
            imageAsset: asset,
            status: 1,
            imageName: ProductGallery.getImageName()));
      }
      setGalleryButton(true);
    });
  }

  int countGalleryLimit() {
    int availableSlot = 0;
    for (int i = 0; i < galleryList.length - 1; i++) {
      if (galleryList[i].status == null || galleryList[i].status == 0)
        availableSlot++;
    }
    return availableSlot;
  }

  getImageGalleryName() {
    List<GalleryImage> imageGallery = [];
    for (int i = 0; i < galleryList.length - 1; i++) {
      imageGallery.add(GalleryImage(imageName: galleryList[i].imageName));
    }
    return jsonEncode(imageGallery);
  }

  getImageGalleryFile() {
    List<ProductGallery> tempList = [];
    for (int i = 0; i < galleryList.length - 1; i++) {
      if (galleryList[i].status == 1)
        tempList.add(ProductGallery(
            imageName: galleryList[i].imageName,
            imageCode: galleryList[i].imageCode));
    }
    return jsonEncode(tempList);
  }

  //delete the image that haven't upload when user want to add more image
  deleteTempImageGallery() {
    setGalleryButton(false);
    galleryList.removeWhere((imageGallery) => imageGallery.status == 1);
  }

  updateGalleryStatusAfterUpload() {
    for (int i = 0; i < galleryList.length; i++) {
      galleryList[i].status = 0;
    }
  }

  Future<ImageProvider> compressGalleryImage(Asset image) async {
    ByteData data = await image.getByteData();

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    compressedFileSource = await compressFile(file);
    ImageProvider provider = MemoryImage(compressedFileSource);
    return provider;
  }

  //delete gallery from cloud
  deleteImageGallery(deletedImageName, position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('delete_image_gallery')}"),
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
              * delete item from local list first
              * */
                galleryList.removeAt(position);
                /*
              * proceed item delete from cloud
              * */
                Map data = await Domain().deleteImageGallery(
                    getImageGalleryName(),
                    deletedImageName,
                    widget.product.productId.toString());

                //delete success
                if (data['status'] == '1') {
                  widget.product.gallery = getImageGalleryName();
                  /*
                 * for control on back press purpose
                 * */
                  setInitialObject();
                  widget.refresh('edit');
                  _showSnackBar(
                      '${AppLocalizations.of(context).translate('image_delete_success')}');
                  await Future.delayed(Duration(milliseconds: 250));
                  Navigator.of(context).pop();

                  setState(() {});
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

  deleteFromList(position) {
    setState(() {
      for (int j = 0; j < selectedImages.length; j++) {
        if (galleryList[position].imageAsset == selectedImages[j])
          selectedImages.removeAt(j);
      }
      galleryList.removeAt(position);
    });
  }

/*
*
*
* -----------------------------------product image purpose-----------------------------------------
*
*
* */

  Future getImage(isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _image = File(pickedFile.path);
    _cropImage(_image);
  }

  Future<Null> _cropImage(File file) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context).translate('crop_image'),
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.orangeAccent,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: AppLocalizations.of(context).translate('crop_image'),
        ));
    if (croppedFile != null) {
      /*
      * image file
      * */
      _image = croppedFile;
      compressFileMethod();
    }
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
          variation: variation,
          categoryId: categoryId,
          stock: stock.text),
      extension,
      imageCode.toString(),
      getImageGalleryName(),
      getImageGalleryFile(),
    );

    if (data['status'] == '1') {
      _showSnackBar(
          '${AppLocalizations.of(context).translate('product_uploaded')}');
      widget.refresh('create');
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pop();
    } else if (data['status'] == '4') {
      _showSnackBar(
          '${AppLocalizations.of(context).translate('exceed_limit')}');
    } else
      _showSnackBar(
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }

  updateProduct() async {
    updateObject();
    /*
    * update product
    * */
    print(getImageGalleryName());
    Map data = await Domain().updateProduct(widget.product, extension,
        imageCode.toString(), getImageGalleryName(), getImageGalleryFile());

    if (data['status'] == '1') {
      //for easy delete image purpose
      imageName = data['image_name'];
      widget.product.image = imageName;
      //avoid double upload same image
      imageCode = '-1';
      //set all gallery status into 0 (mean uploaded)
      updateGalleryStatusAfterUpload();
      /*
       * for control on back press purpose
       * */
      setInitialObject();
      //update parent ui
      widget.refresh('update');
      _showSnackBar(
          '${AppLocalizations.of(context).translate('update_success')}');
    } else
      _showSnackBar(
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
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
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('delete_message')} \n${widget.product.name}"),
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
              * delete product
              * */
                Map data = await Domain()
                    .deleteProduct(widget.product.productId.toString());
                if (data['status'] == '1') {
                  _showSnackBar(
                      '${AppLocalizations.of(context).translate('product_delete')}');
                  await Future.delayed(Duration(milliseconds: 300));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  /*
                  * for control on back press purpose
                  * */
                  setInitialObject();
                  widget.refresh('delete');
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

  //delete gallery from cloud
  deleteProductImage() async {
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
                Map data = await Domain().deleteProductImage(
                    imageName, widget.product.productId.toString());

                //delete success
                if (data['status'] == '1') {
                  _showSnackBar(
                      '${AppLocalizations.of(context).translate('image_delete_success')}');
                  await Future.delayed(Duration(milliseconds: 250));
                  Navigator.of(context).pop();
                  /*
                  * for control on back press purpose
                  * */
                  setInitialObject();
                  /*
                  * after delete image open back the image selection dialog
                  * */
                  setState(() {
                    widget.product.image = imageName = 'no-image-found.png';
                    widget.refresh('edit');
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
                      image: NetworkImage(Domain.imagePath.toString() +
                          (widget.product != null
                              ? imageName
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

  getGalleryLimit() async {
    Map data = await Domain().readGalleryLimit();
    if (data['status'] == '1') {
      galleryLimit = data['gallery_limit'][0]['gallery_limit'];
    }
  }

  updateObject() {
    widget.product.name = name.text;
    widget.product.status = available ? 0 : 1;
    widget.product.description = description.text;
    widget.product.image = imageName;
    widget.product.gallery = getImageGalleryName();
    widget.product.categoryId = categoryId;
    widget.product.price = price.text;
    widget.product.variation = variation;
    widget.product.stock = stock.text;
  }

  reverseObject() {
    widget.product.name = initialProduct.name;
    widget.product.status = initialProduct.status;
    widget.product.description = initialProduct.description;
    widget.product.image = initialProduct.image;
    widget.product.gallery = initialProduct.gallery;
    widget.product.categoryId = initialProduct.categoryId;
    widget.product.price = initialProduct.price;
    widget.product.variation = initialProduct.variation;
    widget.product.stock = initialProduct.stock;
  }

  setInitialObject() {
    initialProduct = new Product(
        name: widget.product.name,
        status: widget.product.status,
        description: widget.product.description,
        image: widget.product.image,
        gallery: widget.product.gallery,
        price: widget.product.price,
        variation: widget.product.variation,
        categoryId: widget.product.categoryId,
        stock: widget.product.stock);
  }
}
