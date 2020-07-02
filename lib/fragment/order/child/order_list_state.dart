import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/order/child/dialog/grouping_dialog.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'card_view.dart';

class OrderList extends StatefulWidget {
  final List<Order> orders;
  final String orderStatus, query;

  OrderList({this.orders, this.orderStatus, this.query});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Order> list = [];
  String status, query;
  int itemPerPage = 5, currentPage = 1;
  bool itemFinish = false;

  /*
  * selected list
  * */
  bool grouping = false;
  List selectedList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = widget.orders;
    status = widget.orderStatus;
    query = widget.query ?? '';
    checkGrouping();
  }

  checkGrouping() async {
    grouping =
        Merchant.fromJson(await SharePreferences().read('merchant')).grouping;
    print(grouping);
    setState(() {});
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
              body = Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CustomProgressBar();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
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
        child: grouping ? groupingListView() : customListView());
  }

  Widget customListView() {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return CardView(orders: list[index], selectedList: selectedList);
        });
  }

  Widget groupingListView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(
            'Select Item ${selectedList.length}',
            style: TextStyle(fontSize: 14),
          ),
          floating: true,
          expandedHeight: selectedList.length > 0 ? 110 : 50,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Visibility(
                visible: selectedList.length > 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedList.clear();
                          });
                        },
                        color: Colors.red[200],
                        icon: Icon(
                          Icons.clear_all,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white),
                        )),
                    RaisedButton.icon(
                        onPressed: () {
                          selectAll();
                        },
                        color: Colors.green[200],
                        icon: Icon(
                          Icons.format_line_spacing,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Select All',
                          style: TextStyle(color: Colors.white),
                        )),
                    RaisedButton.icon(
                        onPressed: () {
                          showGroupingDialog(context);
                        },
                        color: Colors.orange[200],
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => CardView(
                orders: list[index],
                selectedList: selectedList,
                longPress: (orderId) {
                  print(orderId);
                  if (selectedList.contains(orderId)) {
                    selectedList.remove(orderId);
                  } else
                    selectedList.add(orderId);
                  setState(() {});
                }),
            childCount: list.length,
          ),
        ),
      ],
    );
  }

  selectAll() {
    for (int i = 0; i < list.length; i++) {
      if (!selectedList.contains(list[i].id.toString())) {
        selectedList.add(list[i].id.toString());
      }
    }
    setState(() {});
  }

  _onRefresh() async {
    print('refresh');
    // monitor network fetch
    if (mounted)
      setState(() {
        list.clear();
        currentPage = 1;
        itemFinish = false;
        fetchOrder();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    print('loading');

    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchOrder();
      });
    }
    _refreshController.loadComplete();
  }

  Future fetchOrder() async {
    Map data =
        await Domain().fetchOrder(currentPage, itemPerPage, status, query);

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

  void showGroupingDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return GroupingDialog(
          status: status,
          onClick: () {},
        );
      },
    );
  }
}
