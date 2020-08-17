import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/group/detail/group_order_list.dart';
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

  /*
  * pagination
  * */
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTotalOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            'Group ${Order().orderPrefix(widget.orderGroup.groupName)}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
        ),
        body: SafeArea(child: mainContent()),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.orange[300],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupOrderList(
                  orderGroup: widget.orderGroup,
                ),
              ),
            );
          },
          child: Icon(
            Icons.assignment,
            color: Colors.white,
          ),
        ));
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
                  body = Text("Item finished");
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
            child: totalList.length > 0 ? _listView() : notFound()));
  }

  Widget _listView() {
    return ListView.builder(
        itemCount: totalList.length,
        itemBuilder: (BuildContext context, int index) {
          return totalOrderItemView(totalList[index], index);
        });
  }

  Widget headerLayout() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Date: ${Order().formatDate(widget.orderGroup.date ?? '')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            Spacer(),
            Text(
              'Total Order: ${widget.orderGroup.totalOrder.toString()}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ));
  }

  Future fetchTotalOrder() async {
    Map data = await Domain().fetchGroupDetail(widget.orderGroup.orderGroupId);

    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['group_order_item'];
        //add two blank object
        totalList.add(new OrderItem());
        totalList.add(new OrderItem());

        for (int i = 0; i < responseJson.length; i++) {
          bool isAdded = false;
          for (int j = 0; j < totalList.length; j++) {
            if (responseJson[i]['name'] == totalList[j].name &&
                responseJson[i]['remark'] == totalList[j].remark &&
                responseJson[i]['price'] == totalList[j].price) {
              /*
              * existing record goes here
              * */
              totalList[j].quantity = (int.parse(responseJson[i]['quantity']) +
                      int.parse(totalList[j].quantity))
                  .toString();
              isAdded = true;
              break;
            }
          }
          /*
          * new record goes here
          * */
          if (!isAdded) {
            totalList.add(new OrderItem(
                name: responseJson[i]['name'],
                price: responseJson[i]['price'],
                quantity: responseJson[i]['quantity'],
                remark: responseJson[i]['remark']));
          }
        }
        setState(() {});
      }
    });
  }

  headerLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              'Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Price',
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Quantity',
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget totalOrderItemView(OrderItem orderItem, int position) {
    if (position == 0) {
      return headerLayout();
    } else if (position == 1) {
      return headerLabel();
    } else {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Expanded(
                  flex: 3,
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
                    textAlign: TextAlign.center,
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
  }

  Widget notFound() {
    return NotFound(
        title: 'No Item Found!',
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
        fetchTotalOrder();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted) {}
    _refreshController.loadComplete();
  }
}
