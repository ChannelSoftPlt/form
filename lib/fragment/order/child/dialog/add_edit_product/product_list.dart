import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductList extends StatefulWidget {
  final Function(Product) selectItem;

  ProductList({this.selectItem});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = [];

  /*
   * search purpose
   */
  Timer _debounce;
  var queryController = TextEditingController();
  String query = '';
  String searchQuery = "Search query";

  /*
   * pagination purpose
   */
  int itemPerPage = 20, currentPage = 1;
  bool itemFinish = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000,
      width: 1000,
      child: Column(
        children: [searchWidget(), Expanded(child: smartRefresher())],
      ),
    );
  }

  Widget searchWidget() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TextField(
            controller: queryController,
            decoration: InputDecoration(
              hintText:
                  '${AppLocalizations.of(context).translate('search_by')}',
              border: InputBorder.none,
              suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  color: Colors.orangeAccent,
                  onPressed: () {
                    queryController.clear();
                  }),
            ),
            style: TextStyle(color: Colors.black87),
            onChanged: _onSearchChanged),
      ),
    );
  }

  Widget smartRefresher() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text(
                  '${AppLocalizations.of(context).translate('pull_up_load')}');
            } else if (mode == LoadStatus.loading) {
              body = CustomProgressBar();
            } else if (mode == LoadStatus.failed) {
              body = Text(
                  '${AppLocalizations.of(context).translate('load_failed')}');
            } else if (mode == LoadStatus.canLoading) {
              body = Text(
                  '${AppLocalizations.of(context).translate('release_to_load_more')}');
            } else {
              body = Text(
                  '${AppLocalizations.of(context).translate('no_more_data')}');
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              return productList(products[index]);
            }));
  }

  Widget productList(Product product) {
    return ListTile(
        onTap: () async {
          widget.selectItem(product);
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
          '${AppLocalizations.of(context).translate('stock_available')} ${product.stock != '' ? product.stock : '-'}',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: stockStatus(product.stock) ? Colors.green : Colors.red),
        ),
        trailing: Text(
          'RM ${product.price}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ));
  }

  Future fetchProduct() async {
    Map data = await Domain().fetchProduct(query, currentPage, itemPerPage);
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['product'];
        products.addAll(responseJson
            .map((jsonObject) => Product.fromJson(jsonObject))
            .toList());
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      products.clear();
      this.query = query;
      fetchProduct();
    });
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        products.clear();
        currentPage = 1;
        itemFinish = false;
        _refreshController.resetNoData();
        fetchProduct();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchProduct();
      });
    }
    _refreshController.loadComplete();
  }

  stockStatus(stock) {
    try {
      if (stock == '') {
        return true;
      } else {
        int currentStock = int.parse(stock);
        return currentStock > 0;
      }
    } catch (e) {
      return false;
    }
  }
}
