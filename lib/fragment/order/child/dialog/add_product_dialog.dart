import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class AddProductDialog extends StatefulWidget {
  final String formId, quantity;
  final Function(Product, String) addProduct;

  AddProductDialog({this.formId, this.addProduct, this.quantity});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  List<Product> products = [];
  StreamController selectItem;

  /*
  * add product purpose
  * */
  Product product;
  var price = TextEditingController();
  var quantity = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectItem = new StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Add New Product'),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            if (product != null) {
              product = null;
              selectItem.add('back_action');
            } else
              Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            if (product != null) {
              try {
                int inputQuantity = int.parse(quantity.text);
                double.parse(price.text);
                product.price = price.text;
                if (inputQuantity > 0) {
                  widget.addProduct(product, quantity.text.toString());
                } else {
                  CustomToast('Invalid input! 输入不正确!', context,
                          gravity: Toast.BOTTOM)
                      .show();
                }
              } on FormatException {
                CustomToast('Invalid input! 输入不正确!', context,
                        gravity: Toast.BOTTOM)
                    .show();
              }
            } else {
              CustomToast('Please select an item!', context,
                      gravity: Toast.BOTTOM)
                  .show();
            }
          },
        ),
      ],
      content: FutureBuilder(
          future: Domain().fetchProduct(widget.formId),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List jsonProduct = data['product'];

                  products.addAll(jsonProduct
                      .map((jsonObject) => Product.fromJson(jsonObject))
                      .toList());
                  return mainContent(context);
                }
              }
            }
            return CustomProgressBar();
          }),
    );
  }

  Widget mainContent(context) {
    return StreamBuilder<Object>(
        stream: selectItem.stream,
        builder: (context, product) {
          if (product.hasData) {
            print(product.data);
            if (product.data != 'back_action')
              return addProductContent(product.data);
          }
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (var product in products) productList(product),
              ],
            ),
          );
        });
  }

  Widget addProductContent(Product product) {
    this.product = product;
    price.text = product.price;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(
            product.image,
            height: 80,
          ),
          Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 7,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 100,
                height: 50,
                child: Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*")),
                      ],
                      controller: price,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold),
                        hintText: '0.00',
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                      )),
                ),
              ),
              Container(
                width: 100,
                height: 50,
                child: Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      controller: quantity,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold),
                        hintText: '0',
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                      )),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget productList(Product product) {
    return ListTile(
        onTap: () => selectItem.add(product),
        leading: Image.network(
          product.image,
          height: 50,
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          product.status == 0 ? 'Available' : 'Unavailable',
          style: TextStyle(fontSize: 12, color: product.status == 0 ? Colors.green : Colors.red),
        ),
        trailing: Text(
          'RM ${product.price}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ));
  }
}
