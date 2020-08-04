import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/order/child/card_view.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_group.dart';
import 'package:my/object/order_item.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GroupDetail extends StatefulWidget {
  final OrderGroup orderGroup;

  const GroupDetail({Key key, this.orderGroup}) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  List<OrderItem> totalList = [];
  List<Order> list = [];

  /*
  * pagination
  * */
  int itemPerPage = 5,
      currentPage = 1;
  bool itemFinish = false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOrder();
    fetchTotalOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: mainContent()));
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
                  body = Text("pull up load");
                } else if (mode == LoadStatus.loading) {
                  body = CustomProgressBar();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text(totalList.length > 0 ? "No more Data" : '');
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
            child: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                title: Text(
                  'Group ${Order().orderPrefix(widget.orderGroup.groupName)}',
                  style: GoogleFonts.cantoraOne(
                    textStyle: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                floating: true,
                pinned: true,
                elevation: 5,
                expandedHeight: totalList.length > 0 ? 170 + (50 * totalList.length.toDouble()) : 400,
                flexibleSpace: FlexibleSpaceBar(
                  background: totalList.length > 0
                      ? headerLayout()
                      : notFound(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                      CardView(
                        orders: list[index],
                        selectedList: [],
                        refresh: () {
                          _onRefresh();
                        },
                      ),
                  childCount: list.length,
                ),
              ),
            ])));
  }


  Widget headerLayout() {
    print('total ${widget.orderGroup.totalOrder}');
    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 70, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${Order().formatDate(widget.orderGroup.date ?? '')}' +
                  ' \. ' +
                  '${Order().orderPrefix(
                      widget.orderGroup.groupName.toString())}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Total Order: ${widget.orderGroup.totalOrder.toString()}',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Column(children: <Widget>[
              for (int i = 0; i < totalList.length; i++)
                totalOrderItemView(totalList[i])
            ])
          ],
        ));
  }

  refresh() {
    fetchOrder();
    fetchTotalOrder();
  }

  Future fetchTotalOrder() async {
    Map data = await Domain().fetchGroupDetail(widget.orderGroup.orderGroupId);
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['group_order_item'];
        totalList.addAll(responseJson
            .map((jsonObject) => OrderItem.fromJson(jsonObject))
            .toList());
        setState(() {});
      }
    });
  }

  Future fetchOrder() async {
    Map data = await Domain().fetchOrder(
        currentPage,
        itemPerPage,
        '',
        '',
        widget.orderGroup.orderGroupId,
        '',
        '',
        '');

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

  Widget totalOrderItemView(OrderItem orderItem) {
    print(orderItem.quantity);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                flex: 2,
                child: Text(
                  orderItem.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87),
                ),
              ),
              Spacer(),
              new Expanded(
                flex: 1,
                child: Text(
                  orderItem.price,
                  textAlign: TextAlign.end,
                ),
              ),
              new Expanded(
                flex: 1,
                child: Text(
                  'x${orderItem.quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.teal.shade100,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget notFound() {
    return NotFound(
        title: 'No Order Found in this Group!',
        description: 'No order is added into this group so far..!',
        showButton: false,
        button: '',
        drawable: 'drawable/folder.png');
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        totalList.clear();
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
