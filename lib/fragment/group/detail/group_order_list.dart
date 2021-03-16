import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/order/child/card_view.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GroupOrderList extends StatefulWidget {
  final OrderGroup orderGroup;

  const GroupOrderList({Key key, this.orderGroup}) : super(key: key);

  @override
  _GroupOrderListState createState() => _GroupOrderListState();
}

class _GroupOrderListState extends State<GroupOrderList> {
  List<Order> list = [];

  /*
  * pagination
  * */
  int itemPerPage = 5, currentPage = 1;
  bool itemFinish = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('order_item')} ${Order().orderPrefix(widget.orderGroup.groupName)}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
        ),
        body: SafeArea(child: mainContent()));
  }

  Widget mainContent() {
    return Container(
        color: Colors.white,
        child: SmartRefresher(
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
                  body = Text(list.length > 0
                      ? '${AppLocalizations.of(context).translate('no_more_data')}'
                      : '');
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
            child: list.length > 0 ? listView() : notFound()));
  }

  Widget listView() {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return CardView(
            orders: list[index],
            selectedList: [],
            refresh: () {
              _onRefresh();
            },
          );
        });
  }

  refresh() {
    fetchOrder();
  }

  Future fetchOrder() async {
    Map data = await Domain().fetchOrder(currentPage, itemPerPage, '', '',
        widget.orderGroup.orderGroupId, '', '', '');

    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['order'];
        list.addAll(responseJson
            .map((jsonObject) => Order.fromJson(jsonObject))
            .toList());
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }

  Widget notFound() {
    return NotFound(
        title:
            '${AppLocalizations.of(context).translate('no_item_found_in_group')}',
        description:
            '${AppLocalizations.of(context).translate('no_item_found_in_group_description')}',
        showButton: false,
        button: '',
        drawable: 'drawable/folder.png');
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        list.clear();
        currentPage = 1;
        itemFinish = false;
        refresh();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchOrder();
      });
    }
    _refreshController.loadComplete();
  }
}
