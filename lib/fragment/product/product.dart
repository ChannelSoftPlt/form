import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my/fragment/product/product_detail.dart';
import 'package:my/fragment/product/product_list.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  final String query, categoryName;

  ProductPage({this.query, this.categoryName});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  StreamController refreshController = StreamController();

  final int itemPerPage = 8, currentPage = 1;
  String maxProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController.add('loading');

    getProductLimit();
  }

  getProductLimit() async {
    //check discount features
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('product_limit') == null) {
      maxProduct = 'Unknown';
    } else
      maxProduct = prefs.getString('product_limit');
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Domain().fetchProductWithPagination(currentPage, itemPerPage,
            widget.query ?? '', widget.categoryName ?? ''),
        builder: (context, object) {
          if (object.hasData) {
            if (object.connectionState == ConnectionState.done) {
              Map data = object.data;
              if (data['status'] == '1') {
                int currentTotalProduct = data['product_total'];
                List responseJson = data['product'];
                return mainContent(currentTotalProduct, responseJson);
              } else {
                return notFound();
              }
            }
          }
          return Center(child: CustomProgressBar());
        });
  }

  Widget mainContent(currentTotalProduct, List responseJson) {
    return Scaffold(
        appBar: widget.query.isEmpty
            ? AppBar(
                toolbarHeight: 30,
                elevation: 2,
                title: Container(
                  alignment: Alignment.topRight,
                  child: Text('$currentTotalProduct / $maxProduct Products',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
              )
            : null,
        body: ProductList(
            products: responseJson
                .map((jsonObject) => Product.fromJson(jsonObject))
                .toList(),
            query: widget.query ?? '',
            categoryName: widget.categoryName ?? ''),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.orange[300],
          onPressed: () {
            addProduct(context, false, null);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }

  addProduct(mainContext, bool isUpdate, Product product) {
    // flutter defined function
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailDialog(
                product: product,
                isUpdate: isUpdate,
                refresh: (action) {
                  setState(() {});
                },
              )),
    );
  }

  Widget notFound() {
    return NotFound(
        title: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('no_item')}'
            : '${AppLocalizations.of(context).translate('no_product_found')}',
        description: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('try_other_keyword')}'
            : '${AppLocalizations.of(context).translate('no_item_upload')}',
        showButton: widget.query.length < 1,
        refresh: () {
          addProduct(context, false, null);
        },
        button: widget.query.length > 1
            ? ''
            : '${AppLocalizations.of(context).translate('add_product')}',
        drawable: widget.query.length > 1
            ? 'drawable/not_found.png'
            : 'drawable/folder.png');
  }
}
