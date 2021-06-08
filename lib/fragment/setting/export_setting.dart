import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my/object/imageGallery/product_gallery.dart';
import 'package:my/object/order.dart';
import 'package:my/object/product.dart';
import 'package:my/object/user.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class ExportDialog extends StatefulWidget {
  ExportDialog();

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  List<User> userList = [];
  List<Product> productList = [];
  List<Order> salesList = [];

  var exportData = 'customer';
  var fromDate, toDate;
  var path, fileName;

  final displayDateFormat = DateFormat("dd MMM");
  final selectedDateFormat = DateFormat("yyy-MM-dd");
  final fileDateForm = DateFormat("dd-MMM");

  StreamController freshStream;

  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    freshStream = StreamController();
    freshStream.add('display');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      title: Text(
        AppLocalizations.of(context).translate('export'),
        style: GoogleFonts.cantoraOne(
          textStyle: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      content: StreamBuilder(
          stream: freshStream.stream,
          builder: (context, object) {
            if (object.hasData && object.data.toString().length >= 1) {
              if (object.data == 'display')
                return mainContent();
              else if (object.data == 'result')
                return resultPage();
              else
                mainContent();
            }
            return Container(height: 150, child: CustomProgressBar());
          }),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            '${AppLocalizations.of(context).translate('export')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            checkPermission();
//            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget mainContent() {
    return Container(
      height: 150,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('export_data')}',
                labelStyle: TextStyle(fontSize: 18, color: Colors.black54),
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down),
                    value: exportData,
                    items: getExportType(context).map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child:
                            Text(AppLocalizations.of(context).translate(item)),
                      );
                    }).toList(),
                    onChanged: (selectedItem) {
                      setState(
                        () => exportData = selectedItem,
                      );
                    }),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '${AppLocalizations.of(context).translate('date')}',
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Row(
            children: <Widget>[
              FlatButton.icon(
                  label: Text(
                    fromDate != null
                        ? displayDateFormat.format(fromDate).toString()
                        : '${AppLocalizations.of(context).translate('from_date')}',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  icon: Icon(Icons.date_range),
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (date) {
                      setState(() {
                        fromDate = date;
                      });
                    },
                        currentTime:
                            fromDate != null ? fromDate : DateTime.now(),
                        locale: LocaleType.zh);
                  }),
              FlatButton.icon(
                  label: Text(
                    toDate != null
                        ? displayDateFormat.format(toDate).toString()
                        : '${AppLocalizations.of(context).translate('to_date')}',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  icon: Icon(Icons.date_range),
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (date) {
                      setState(() {
                        toDate = date;
                      });
                    },
                        currentTime: toDate != null ? toDate : DateTime.now(),
                        locale: LocaleType.zh);
                  })
            ],
          ),
        ],
      ),
    );
  }

  Widget resultPage() {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: RaisedButton.icon(
                onPressed: openFile,
                color: Colors.green,
                icon: Icon(
                  Icons.launch,
                  color: Colors.white,
                ),
                label: Text(AppLocalizations.of(context).translate('open_file'),
                    style: TextStyle(fontSize: 12, color: Colors.white))),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: RaisedButton.icon(
                onPressed: shareFile,
                color: Colors.redAccent,
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                label: Text(
                  AppLocalizations.of(context).translate('share_file'),
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  shareFile() async {
    await Future.delayed(Duration(milliseconds: 600));
    Share.shareFiles([path], text: fileName);
    Navigator.of(context).pop();
  }

  openFile() async {
    await Future.delayed(Duration(milliseconds: 600));
    if (Platform.isIOS)
      await OpenFile.open(path, type: "com.microsoft.excel.xls");
    else
      await OpenFile.open(path, type: "application/vnd.ms-excel");
    Navigator.of(context).pop();
  }

  List getExportType(context) {
    return <String>['customer', 'products', 'sales'];
  }

  checkPermission() async {
    var readPermission = await Permission.storage.status;
    if (readPermission.isGranted) {
      generateCSV();
    } else {
      final status = await Permission.storage.request();
      //if granted then recall the method
      if (status == PermissionStatus.granted) checkPermission();
    }
  }

  getExportDataList() async {
    List<List<dynamic>> rows = List<List<dynamic>>();
    if (exportData == 'customer') {
      await fetchExportCustomer();
      for (int i = 0; i < userList.length; i++) {
        List<dynamic> row = [];
        //add header
        if (i == 0) {
          row.add('Name');
          row.add('Email');
          row.add('Phone');
          row.add('Address');
          row.add('Postcode');
          row.add('Create Date');
          rows.add(row);
          row = [];
        }
        row.add(userList[i].name);
        row.add(userList[i].email);
        row.add(userList[i].phone);
        row.add(userList[i].address);
        row.add(userList[i].postcode);
        row.add(userList[i].createAt);
        rows.add(row);
      }
    } else if (exportData == 'products') {
      //fetch and check data
      await fetchExportProduct();
      for (int i = 0; i < productList.length; i++) {
        List<dynamic> row = [];
        //add header
        if (i == 0) {
          row.add('Name');
          row.add('Description');
          row.add('Price');
          row.add('Product Picture');
          row.add('Product Gallery');
          row.add('Category');
          row.add('Stock');
          rows.add(row);
          row = [];
        }
        row.add(productList[i].name);
        row.add(productList[i].description);
        row.add(productList[i].price);
        row.add('${Domain.imagePath}${productList[i].image}');
        row.add(getProductGallery(productList[i].gallery));
        row.add(productList[i].categoryName);
        row.add(productList[i].stock);
        rows.add(row);
      }
    } else if (exportData == 'sales') {
      var subTotal = 0.0,
          tax = 0.0,
          deliveryFee = 0.0,
          discountAmount = 0.0,
          couponDiscount = 0.0,
          total = 0.0;
      List<dynamic> row = [];
      //fetch and check data
      await fetchExportSales();
      //fetch and check data
      for (int i = 0; i < salesList.length; i++) {
        row = [];
        //add header
        if (i == 0) {
          row.add('Date');
          row.add('Order No');
          row.add('Subtotal');
          row.add('Tax');
          row.add('Delivery Fee');
          row.add('Discount');
          row.add('Coupon Discount');
          row.add('Total Amount');
          rows.add(row);
          row = [];
        }
        row.add(salesList[i].date);
        row.add(Order().orderPrefix(salesList[i].orderID));
        row.add(salesList[i].total.toStringAsFixed(2));
        row.add(double.parse(salesList[i].tax).toStringAsFixed(2));
        row.add(double.parse(salesList[i].deliveryFee).toStringAsFixed(2));
        row.add(
            '-${double.parse(salesList[i].discountAmount).toStringAsFixed(2)}');
        row.add(
            '-${double.parse(salesList[i].couponDiscount).toStringAsFixed(2)}');
        row.add(Order().countTotal(salesList[i]).toStringAsFixed(2));
        rows.add(row);

        subTotal += salesList[i].total;
        tax += Order().convertToInt(salesList[i].tax);
        deliveryFee += Order().convertToInt(salesList[i].deliveryFee);
        discountAmount += Order().convertToInt(salesList[i].discountAmount);
        couponDiscount += Order().convertToInt(salesList[i].couponDiscount);
        total += Order().countTotal(salesList[i]);
      }
      /**
       * count total
       */
      row = [];
      row.add('Total');
      row.add('');
      row.add(subTotal.toStringAsFixed(2));
      row.add(tax.toStringAsFixed(2));
      row.add(deliveryFee.toStringAsFixed(2));
      row.add(discountAmount.toStringAsFixed(2));
      row.add(couponDiscount.toStringAsFixed(2));
      row.add(total.toStringAsFixed(2));
      rows.add(row);
    }
    return rows;
  }

  getProductGallery(gallery) {
    if (gallery != '') {
      List jsonList = jsonDecode(gallery);
      List<ProductGallery> galleryList = [];

      galleryList.addAll(jsonList
          .map((jsonObject) => ProductGallery.fromJson(jsonObject))
          .toList());

      List newList = [];
      for (ProductGallery gallery in galleryList) {
        newList.add('${Domain.imagePath}${gallery.imageName}');
      }
      return jsonEncode(newList);
    }
  }

  Future fetchExportCustomer() async {
    userList = [];
    Map data = await Domain().fetchExportCustomer(
        fromDate != null ? fromDate.toString() : '',
        toDate != null ? toDate.toString() : '');

    if (data['status'] == '1') {
      List responseJson = data['customer_data'];
      userList.addAll(
          responseJson.map((jsonObject) => User.fromJson(jsonObject)).toList());
    }
  }

  Future fetchExportProduct() async {
    productList = [];
    Map data = await Domain().fetchExportProduct(
        fromDate != null ? fromDate.toString() : '',
        toDate != null ? toDate.toString() : '');

    if (data['status'] == '1') {
      List responseJson = data['product_data'];
      productList.addAll(responseJson
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList());
    }
  }

  Future fetchExportSales() async {
    salesList = [];
    Map data = await Domain().fetchExportSales(
        fromDate != null ? fromDate.toString() : '',
        toDate != null ? toDate.toString() : '');

    if (data['status'] == '1') {
      List responseJson = data['export_sales'];
      salesList.addAll(responseJson
          .map((jsonObject) => Order.fromJson(jsonObject))
          .toList());
    }
  }

  generateCSV() async {
    freshStream.add('');
    List<List<dynamic>> rows = await getExportDataList();
    /*
    * data found
    * */
    if (rows.length > 0) {
      String csv = const ListToCsvConverter().convert(rows);
      String dir = (await getApplicationDocumentsDirectory()).path;
      fileName =
          '${AppLocalizations.of(context).translate(exportData)} (${fileDateForm.format(DateTime.now())}).csv';
      path = '$dir/$fileName';

      File file = new File(path);
      await file.writeAsString(csv);

      showToast('file_generated');
      freshStream.add('result');
    }
    /*
    * no data to print
    * */
    else {
      freshStream.add('display');
      showToast('no_date_found');
      return;
    }
  }

  showToast(message) {
    CustomToast('${AppLocalizations.of(context).translate(message)}', context)
        .show();
  }
}
