import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/product/product_detail.dart';
import 'package:my/fragment/product/product_list_view.dart';

import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;
  final String query, categoryName;
  final Function(bool, Product) openProductDetail;

  ProductList(
      {this.products, this.query, this.categoryName, this.openProductDetail});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> list = [];
  int itemPerPage = 8, currentPage = 1;
  bool itemFinish = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = widget.products;
  }

  @override
  Widget build(BuildContext context) {
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
        child: customListView());
  }

  Widget customListView() {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductListView(
              product: list[index],
              openProductDetail: (bool isUpdate, Product product) {
                updateProduct(context, true, list[index]);
              });
        });
  }

  updateProduct(mainContext, bool isUpdate, Product product) {
    // flutter defined function
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailDialog(
                product: product,
                isUpdate: isUpdate,
                refresh: (action) {
                  setState(() {
                    if (action == 'delete') list.remove(product);
                  });
                },
              )),
    );
  }

  _onRefresh() async {
    print('refresh');
    // monitor network fetch
    if (mounted)
      setState(() {
        list.clear();
        currentPage = 1;
        itemFinish = false;
        fetchProduct();
        _refreshController.resetNoData();
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

  Future fetchProduct() async {
    Map data = await Domain().fetchProductWithPagination(
        currentPage, itemPerPage, widget.query, widget.categoryName);
    print('data goes here: $data');
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['product'];
        list.addAll(responseJson
            .map((jsonObject) => Product.fromJson(jsonObject))
            .toList());
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }
}
