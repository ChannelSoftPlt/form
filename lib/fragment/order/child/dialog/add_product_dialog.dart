import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class AddProductDialog extends StatefulWidget {
  final String formId, quantity;
  final bool isUpdate;
  final OrderItem orderItem;
  final Function(Product, OrderItem, String, String) addProduct;
  final Function(OrderItem) editProduct;

  AddProductDialog(
      {this.formId,
      this.orderItem,
      this.addProduct,
      this.quantity,
      this.editProduct,
      this.isUpdate});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  List<Product> products = [];
  List<VariantGroup> variant = [];
  List<VariantGroup> selectedVariant = [];

  StreamController selectItem;
  StreamController addVariant;
  StreamController countTotal;

  /*
  * add product purpose
  * */
  Product product;
  var total = 0.00;
  var singleProductTotal = 0.00;
  var variantTotal = 0.00;
  bool status = true;
  var name = TextEditingController();
  var price = TextEditingController();
  var quantity = TextEditingController();
  var remark = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectItem = new StreamController();
    addVariant = new StreamController();
    countTotal = new StreamController();
    if (widget.isUpdate) {
      selectItem.add('');
    }
  }

  @override
  Widget build(BuildContext context) {
    selectItem = new StreamController();
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      title: new Text(
          '${AppLocalizations.of(context).translate('add_new_product')}'),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            if (product != null && !widget.isUpdate) {
              reset();
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
            createProduct();
          },
        ),
      ],
      content: selectLayout(),
    );
  }

  Widget selectLayout() {
    if (!widget.isUpdate) {
      return FutureBuilder(
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
          });
    } else {
      product = new Product(
        name: widget.orderItem.name,
        price: widget.orderItem.price,
      );
      if (!mounted) status = widget.orderItem.status == '0';
      quantity.text = widget.orderItem.quantity;
      remark.text = widget.orderItem.remark;
      setupVariantData(widget.orderItem.variation);

      return addProductContent(product);
    }
  }

  Widget mainContent(context) {
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

  createProduct() {
    if (product != null) {
      try {
        //do checking here
        int inputQuantity = int.parse(quantity.text);
        double.parse(price.text);
        product.price = singleProductTotal.toStringAsFixed(2);
        product.variation = jsonEncode(variant);
        //check quantity
        if (inputQuantity > 0) {
          variantTotal = variantTotal * inputQuantity;
          //order item
          OrderItem orderItem = new OrderItem(
              name: name.text,
              status: status ? '0' : '1',
              price: product.price,
              quantity: quantity.text.toString(),
              remark: remark.text,
              orderProductId: widget.orderItem != null
                  ? widget.orderItem.orderProductId
                  : null,
              variation: product.variation);

          //create product
          if (!widget.isUpdate) {
            widget.addProduct(
                product, orderItem, quantity.text.toString(), remark.text);
          }
          //update product
          else {
            widget.editProduct(orderItem);
          }
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
      CustomToast('${AppLocalizations.of(context).translate('select_an_item')}',
              context,
              gravity: Toast.BOTTOM)
          .show();
    }
  }

  Widget addProductContent(Product product) {
    addVariant = new StreamController();
    countTotal = new StreamController();
    //for create product use only. (clear old data when user select new product)
    if (!widget.isUpdate) {
      this.product = product;
    }
    price.text = product.price;
    name.text = product.name;

    //if update then auto trigger calculation
    if (widget.isUpdate) {
      totalPrice();
      countTotal.add('');
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
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
                    Visibility(
                      visible: !widget.isUpdate,
                      child: Container(
                        alignment: Alignment.center,
                        child: FadeInImage(
                            height: 130,
                            image: NetworkImage(
                                '${Domain.imagePath}${product.image}'),
                            placeholder: NetworkImage(
                                '${Domain.imagePath}no-image-found.png')),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
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
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^\d*\.?\d*")),
                              ],
                              controller: price,
                              onChanged: (text) => totalPrice(),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText:
                                    '${AppLocalizations.of(context).translate('price')}',
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Colors.blueGrey),
                                hintText: '0.00',
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
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
                              onChanged: (text) => totalPrice(),
                              decoration: InputDecoration(
                                labelText:
                                    '${AppLocalizations.of(context).translate('quantity')}',
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Colors.blueGrey),
                                hintText: '0',
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
                              )),
                        )
                      ],
                    ),
                    Visibility(
                      visible: widget.isUpdate,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              '${AppLocalizations.of(context).translate('product_available')}'),
                          Switch(
                            value: status,
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                status = value;
                              });
                            },
                            activeTrackColor: Colors.orangeAccent,
                            activeColor: Colors.deepOrangeAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    addOnLayout(),
                    Container(
                      alignment: Alignment.topLeft,
                      child: TextField(
                          minLines: 3,
                          maxLines: 4,
                          keyboardType: TextInputType.text,
                          controller: remark,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context).translate('remark')}',
                            labelStyle:
                                TextStyle(fontSize: 14, color: Colors.blueGrey),
                            alignLabelWithHint: true,
                            hintText:
                                '${AppLocalizations.of(context).translate('remark_hint')}',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        calculateTotal()
      ],
    );
  }

  totalPrice() {
    try {
      singleProductTotal = double.parse(price.text);
      print(singleProductTotal);

      variantTotal = 0.00;
      //calculate add on
      List<VariantChild> addOnList = [];
      for (int i = 0; i < variant.length; i++) {
        addOnList = variant[i].variantChild;
        for (int j = 0; j < addOnList.length; j++) {
          if (addOnList[j].quantity > 0) {
            variantTotal +=
                (addOnList[j].quantity * double.parse(addOnList[j].price));
          }
        }
      }

      total = (singleProductTotal + variantTotal) * double.parse(quantity.text);
    } catch ($e) {
      print('length: ${$e}');
      total = 0.00;
    }
    countTotal.add('');
  }

  Widget calculateTotal() {
    return StreamBuilder(
        stream: countTotal.stream,
        builder: (context, snapshot) {
          return Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).translate('total_amount')),
                  Text(total.toStringAsFixed(2)),
                ],
              ),
            ),
          );
        });
  }

  Widget addOnLayout() {
    return StreamBuilder(
        stream: addVariant.stream,
        builder: (context, snapshot) {
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
                for (int i = 0; i < variant.length; i++)
                  addOnChildLayout(variant[i])
              ],
            ),
          );
        });
  }

  Widget addOnChildLayout(VariantGroup data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.groupName,
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        for (int i = 0; i < data.variantChild.length; i++)
          Container(
            height: 30,
            child: Row(
              children: [
                Checkbox(
                  value: data.variantChild[i].quantity == 1,
                  onChanged: (add) {
                    data.variantChild[i].quantity = add ? 1 : 0;
                    addVariant.add('');
                    totalPrice();
                    // for (int i = 0; i < data.variantChild.length; i++) print(data.variantChild[i].quantity);
                  },
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                      data.variantChild[i].name,
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    )),
                Expanded(
                    flex: 1,
                    child: Text('+ RM${data.variantChild[i].price}',
                        style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        SizedBox(
          height: 10,
        )
      ],
    );
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

  reset() {
    variantTotal = 0.00;
    singleProductTotal = 0.00;
    total = 0.00;
    product = null;
    quantity.clear();
    addVariant.close();
    countTotal.close();
  }
}
