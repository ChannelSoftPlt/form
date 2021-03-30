import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:my/object/product.dart';
import 'package:my/object/productVariant/variantGroup.dart';
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
  List<VariantGroup> variant = [];
  List<VariantGroup> selectedVariant = [];
  StreamController selectItem;

  /*
  * add product purpose
  * */
  Product product;
  var name = TextEditingController();
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
            return Container(width: 500, child: CustomProgressBar());
          }),
    );
  }

  Widget mainContent(context) {
//    selectedVariant.clear();
//    return addProductContent(product);
    return StreamBuilder<Object>(
        stream: selectItem.stream,
        builder: (context, product) {
          if (product.hasData) {
            if (product.data != 'back_action') {
              return addProductContent(product.data);
            }
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
    name.text = product.name;

    return SingleChildScrollView(
      child: Theme(
        data: new ThemeData(
          primaryColor: Colors.orange,
        ),
        child: Container(
          width: 1000,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: FadeInImage(
                    height: 130,
                    image: NetworkImage('${Domain.imagePath}${product.image}'),
                    placeholder:
                        NetworkImage('${Domain.imagePath}no-image-found.png')),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: name,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText:
                        '${AppLocalizations.of(context).translate('name')}',
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
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
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                  )
                ],
              ),
              SizedBox(
                height: 7,
              ),
              addOnLayout(),
              Container(
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget addOnLayout() {
    return Visibility(
      visible: variant.length > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('product_variant'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          for (int i = 0; i < variant.length; i++) addOnChildLayout(variant[i])
        ],
      ),
    );
  }

  Widget addOnChildLayout(VariantGroup data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.groupName,
          style: TextStyle(color: Colors.black87),
        ),
        CheckboxGroup(
            itemBuilder: (Checkbox cb, Text txt, int i) {
              return Row(
                children: <Widget>[
                  cb,
                  Expanded(
                      flex: 2,
                      child: Text(
                        data.variantChild[i].name,
                        style: TextStyle(fontSize: 14),
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        '+ RM ${data.variantChild[i].price}',
                        style: TextStyle(fontSize: 12),
                      )),
                ],
              );
            },
            labels: <String>[
              for (int i = 0; i < data.variantChild.length; i++)
                data.variantChild[i].name
            ],
            onChange: (bool isChecked, String label, int index) {
              //allow one only
              if (data.type == 1 && countSelect(data.variantChild) > 1) {
                return;
              }
              data.variantChild[index].quantity = 1;
            },
            onSelected: (List<String> checked) {
              //allow one only
              if (data.type == 1 && checked.length > 1) {
                checked.removeLast();
                for (int i = 0; i < data.variantChild.length; i++) {
                  print(data.variantChild[i].quantity);
                }
                return;
              }
            }),
      ],
    );
  }

  countSelect(List<VariantChild> list) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].quantity == 1) count++;
    }
    return count;
  }

  /*
  * setup variant data
  * */
  setupVariantData(String variantData) async {
    try {
      variant.clear();
      List data = jsonDecode(variantData);
      variant.addAll(
          data.map((jsonObject) => VariantGroup.fromJson(jsonObject)).toList());
    } catch ($e) {
      print($e);
    }
  }

  Widget productList(Product product) {
    return ListTile(
        onTap: () async {
          print(product.variation);
          await setupVariantData(product.variation);
          selectItem.add(product);
        },
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
