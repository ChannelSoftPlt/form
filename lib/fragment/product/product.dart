import 'package:flutter/material.dart';
import 'package:my/fragment/product/product_detail.dart';
import 'package:my/fragment/product/product_list.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';

class ProductPage extends StatefulWidget {
  final String query, categoryName;

  ProductPage({this.query, this.categoryName});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final int itemPerPage = 8, currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: Domain().fetchProductWithPagination(currentPage,
                itemPerPage, widget.query ?? '', widget.categoryName ?? ''),
            builder: (context, object) {
              if (object.hasData) {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    List responseJson = data['product'];
                    return ProductList(
                      products: responseJson
                          .map((jsonObject) => Product.fromJson(jsonObject))
                          .toList(),
                      query: widget.query ?? '',
                      categoryName: widget.categoryName ?? '',
                    );
                  } else {
                    return notFound();
                  }
                }
              }
              return Center(child: CustomProgressBar());
            }),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.orange[300],
          onPressed: () {
            showProductDetail(context);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }

  showProductDetail(mainContext) {
    // flutter defined function
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailDialog(
                isUpdate: false,
                refresh: () {
                  setState(() {});
                },
              )),
    );
  }

  Widget notFound() {
    return NotFound(
        title: widget.query.length > 1 ? 'No Item Found!' : 'No Group Found!',
        description: widget.query.length > 1
            ? 'Please try another keyword...'
            : 'Argh...your order are on its way now. Be Smile :)',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1 ? '' : 'Refresh',
        drawable: widget.query.length > 1
            ? 'drawable/not_found.png'
            : 'drawable/folder.png');
  }
}
