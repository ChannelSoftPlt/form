import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DuplicateDialog extends StatefulWidget {
  final Function(String) duplicateVariant;

  DuplicateDialog({this.duplicateVariant});

  @override
  _DuplicateDialogState createState() => _DuplicateDialogState();
}

class _DuplicateDialogState extends State<DuplicateDialog> {
  List<Product> products = [];
  StreamController actionStream;
  String action = 'display';

  int itemPerPage = 50, currentPage = 1;
  bool itemFinish = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actionStream = StreamController();
    actionStream.add('loading');
    fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        insetPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        title: new Text(
            '${AppLocalizations.of(context).translate('select_product')}'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '${AppLocalizations.of(context).translate('close')}',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        content: mainContent(context));
  }

  Widget mainContent(context) {
    return Container(
      height: 600,
      width: 800,
      child: StreamBuilder(
          stream: actionStream.stream,
          builder: (context, data) {
            if (data.data == 'display') {
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
            return CustomProgressBar();
          }),
    );
  }

  _onRefresh() async {
    print('refresh');
    // monitor network fetch
    if (mounted)
      setState(() {
        products.clear();
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

  Widget customListView() {
    return ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return listViewChild(products[index], index);
        });
  }

  Widget listViewChild(Product product, int position) {
    return Card(
        key: Key(product.name),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 8, 8, 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  product.name,
                  maxLines: 2,
                  style: TextStyle(
                      color: Color.fromRGBO(89, 100, 109, 1), fontSize: 14),
                ),
              ),
              OutlineButton(
                padding: EdgeInsets.all(1),
                onPressed: () {
                  widget.duplicateVariant(product.variation);
                  Navigator.of(context).pop();
                },
                borderSide: BorderSide(
                  color: Colors.green,
                  style: BorderStyle.solid,
                ),
                child: Text(
                  '${AppLocalizations.of(context).translate('duplicate')}',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
                color: Colors.orange,
              ),
            ],
          ),
        ));
  }

  Future fetchProduct() async {
    Map data = await Domain()
        .fetchProductWithPagination(currentPage, itemPerPage, '', '');
    print('data goes here: $data');
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['product'];
        products.addAll(responseJson
            .map((jsonObject) => Product.fromJson(jsonObject))
            .toList());

        actionStream.add('display');
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }
}
