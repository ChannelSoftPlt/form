import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my/object/category.dart';
import 'package:my/object/product.dart';
import 'package:my/utils/domain.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ProductDetailDialog extends StatefulWidget {
  final Product product;
  final Function(Product) onClick;
  final bool isUpdate;

  ProductDetailDialog({this.product, this.onClick, this.isUpdate});

  @override
  _ProductDetailDialogState createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  var name = TextEditingController();
  var description = TextEditingController();
  var price = TextEditingController();
  bool available = true;
  Product object;

  File _image;
  ImageProvider provider;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      name.text = widget.product.name;
      description.text = widget.product.description;
      price.text = widget.product.price;
      available = widget.product.status == 0;
    }
  }

  Future getImage(isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _image = File(pickedFile.path);
    _testCompressFile();
  }

  void _testCompressFile() async {
    print("pre compress");

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();
    print('dir = $dir');

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    final result = await testCompressFile(file);
    ImageProvider provider = MemoryImage(result);
    this.provider = provider;
    setState(() {});
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<Uint8List> testCompressFile(File file) async {
    print("testCompressFile");
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 70,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          widget.isUpdate == true ? 'Update Product' : 'Add Product',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(widget.isUpdate == true ? Icons.edit : Icons.save),
            onPressed: () {},
          )
        ],
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      body: SingleChildScrollView(
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
                  style: TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    hintText: 'Product Name',
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
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    hintText: 'Product Description',
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
                  controller: price,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    labelText: 'Price',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    hintText: 'Price',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Text('Status'),
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
              chooseCategory()
            ],
          ),
        ),
      ),
    );
  }

  Widget chooseCategory() {
    return DropdownSearch<Category>(
        mode: Mode.BOTTOM_SHEET,
        label: 'Category Name',
        popupTitle: Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        searchBoxDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
          prefixIcon: Icon(Icons.search),
          labelText: "Search a category",
        ),
        showSearchBox: true,
        onFind: (String filter) => getData(filter),
        itemAsString: (Category u) => u.categoryAsString(),
        onChanged: (Category data) => null);
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("From where do you want to take the photo?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        getImage(false);
                        Navigator.pop(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () {
                        getImage(true);
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Widget _imageViewWidget() {
    if (_image == null) {
      return Image.network(
        Domain.imagePath +
            (widget.product != null
                ? widget.product.image
                : 'no-image-found.png'),
        height: 180,
      );
    } else
      return Container(
        constraints: BoxConstraints(
            minHeight: 200, minWidth: double.infinity, maxHeight: 300),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image(
            image: provider,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      );
  }

  Future<List<Category>> getData(filter) async {
    Map data = await Domain().fetchCategory();
    var models;
    if (data['status'] == '1') {
      models = Category.fromJsonList(data['category']);
    }
    return models;
  }
}
