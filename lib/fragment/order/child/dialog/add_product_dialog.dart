import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class AddProductDialog extends StatefulWidget {
  final String formId, quantity;
  final Function(Product, String, String) addProduct;

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
  var remark = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectItem = new StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          '${AppLocalizations.of(context).translate('add_new_product')}'),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
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
            '${AppLocalizations.of(context).translate('confirm')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            if (product != null) {
              try {
                int inputQuantity = int.parse(quantity.text);
                double.parse(price.text);
                product.price = price.text;
                if (inputQuantity > 0) {
                  widget.addProduct(
                      product, quantity.text.toString(), remark.text);
                } else {
                  CustomToast(
                          '${AppLocalizations.of(context).translate('invalid_input')}',
                          context,
                          gravity: Toast.BOTTOM)
                      .show();
                }
              } on FormatException {
                CustomToast(
                        '${AppLocalizations.of(context).translate('invalid_input')}',
                        context,
                        gravity: Toast.BOTTOM)
                    .show();
              }
            } else {
              CustomToast(
                      '${AppLocalizations.of(context).translate('select_an_item')}',
                      context,
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
          FadeInImage(
              height: 80,
              fit: BoxFit.cover,
              image: NetworkImage('${Domain.imagePath}${product.image}'),
              placeholder:
                  NetworkImage('${Domain.imagePath}no-image-found.png')),
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r"^\d*\.?\d*")),
                      ],
                      controller: price,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText:
                            '${AppLocalizations.of(context).translate('price')}',
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: quantity,
                      decoration: InputDecoration(
                        labelText:
                            '${AppLocalizations.of(context).translate('quantity')}',
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
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            child: Theme(
              data: new ThemeData(
                primaryColor: Colors.orange,
              ),
              child: TextField(
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  controller: remark,
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).translate('remark')}',
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                    hintText:
                        '${AppLocalizations.of(context).translate('remark_hint')}',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget productList(Product product) {
    return ListTile(
        onTap: () => selectItem.add(product),
        leading: FadeInImage(
            height: 50,
            width: 50,
            image: NetworkImage('${Domain.imagePath}${product.image}'),
            placeholder: NetworkImage('${Domain.imagePath}no-image-found.png')),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          product.status == 0
              ? '${AppLocalizations.of(context).translate('available')}'
              : '${AppLocalizations.of(context).translate('unavailable')}',
          style: TextStyle(
              fontSize: 12,
              color: product.status == 0 ? Colors.green : Colors.red),
        ),
        trailing: Text(
          'RM ${product.price}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ));
  }
}
