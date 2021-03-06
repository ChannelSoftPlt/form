import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/group/detail/group_order_list.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_group.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../edit_group_name_dialog.dart';

class GroupDetail extends StatefulWidget {
  final OrderGroup orderGroup;

  const GroupDetail({Key key, this.orderGroup}) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  List<OrderItem> totalList = [];
  final key = new GlobalKey<ScaffoldState>();

  /*
  * pagination
  * */
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var totalAmount = 0.00;
  var totalQuantity = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTotalOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('group')} ${getGroupName(widget.orderGroup.groupName)}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showEditGroupNameDialog(context);
              },
            ),
          ],
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
                  body = Text(
                      '${AppLocalizations.of(context).translate('item_finish')}');
                } else if (mode == LoadStatus.loading) {
                  body = CustomProgressBar();
                } else if (mode == LoadStatus.failed) {
                  body = Text(
                      '${AppLocalizations.of(context).translate('load_failed')}');
                } else if (mode == LoadStatus.canLoading) {
                  body = Text(
                      '${AppLocalizations.of(context).translate('release_to_load_more')}');
                } else {
                  body = Text(totalList.length > 0
                      ? "${AppLocalizations.of(context).translate('no_more_data')}"
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('date')}: ${Order().formatDate(widget.orderGroup.date ?? '')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                Spacer(),
                Text(
                  '${AppLocalizations.of(context).translate('total_order')} ${widget.orderGroup.totalOrder.toString()}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
            Card(
              elevation: 4,
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        alignment: Alignment.center,
                        height: 70,
                        child: Column(
                          children: [
                            Text(
                              '${totalQuantity.toInt()}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Text(
                              '${AppLocalizations.of(context).translate('total_quantity')}',
                              textAlign: TextAlign.end,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      )),
                  Container(
                      height: 50, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        alignment: Alignment.center,
                        height: 70,
                        child: Column(
                          children: [
                            Text(
                              'RM ${totalAmount.toDouble().toStringAsFixed(2)}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Text(
                              '${AppLocalizations.of(context).translate('total_amount')}',
                              textAlign: TextAlign.end,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ));
  }

  Future fetchTotalOrder() async {
    Map data = await Domain().fetchGroupDetail(widget.orderGroup.orderGroupId);
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
              responseJson[i]['price'] == totalList[j].price &&
              responseJson[i]['variation'] == totalList[j].variation) {
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
              variation: responseJson[i]['variation'],
              remark: responseJson[i]['remark']));
        }
      }
    }
    if (totalList.length > 0) countProductTotal();
    setState(() {});
  }

  headerLabel() {
    return Card(
      elevation: 3,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  '${AppLocalizations.of(context).translate('product')}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${AppLocalizations.of(context).translate('price')}',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${AppLocalizations.of(context).translate('quantity')}',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          )),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderItem.name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87),
                              ),
                            ],
                          )),
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
                  addOnList(orderItem.variation),
                  remarkLayout(orderItem)
                ],
              )),
          Divider(
            color: Colors.teal.shade100,
            thickness: 1.0,
          ),
        ],
      );
    }
  }

  Widget addOnList(variation) {
    //variant setting
    List<VariantGroup> variant = [];
    try {
      if (variation != '') {
        List data = jsonDecode(variation);
        variant.addAll(data
            .map((jsonObject) => VariantGroup.fromJson(jsonObject))
            .toList());
      }
    } catch ($e) {}

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          for (int i = 0; i < variant.length; i++)
            if (isUsedVariant(variant[i].variantChild))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int j = 0; j < variant[i].variantChild.length; j++)
                    if (variant[i].variantChild[j].quantity > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              variant[i].variantChild[j].name,
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '+ ${variant[i].variantChild[j].price}',
                              textAlign: TextAlign.end,
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(''),
                          )
                        ],
                      ),
                ],
              )
        ],
      ),
    );
  }

  Widget remarkLayout(OrderItem orderItem) {
    return Visibility(
        visible: orderItem.remark != '',
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('remark'),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    orderItem.remark,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  countProductTotal() {
    totalAmount = 0.00;
    totalQuantity = 0;
    //loop all order item
    for (int i = 2; i < totalList.length; i++) {
      var variationTotal = 0.00;
      //for calculate variation total purpose
      try {
        String variation = totalList[i].variation;
        if (variation != '') {
          //convert variant from string to list
          List<VariantGroup> variant = [];
          List data = jsonDecode(variation);
          variant.addAll(data
              .map((jsonObject) => VariantGroup.fromJson(jsonObject))
              .toList());

          //loop all the variant and calculate variant total
          for (int j = 0; j < variant.length; j++) {
            List<VariantChild> variantChild = variant[j].variantChild;
            for (int k = 0; k < variantChild.length; k++) {
              variationTotal += (variantChild[k].quantity *
                  double.parse(variantChild[k].price));
            }
          }
        }
      } catch ($e) {
        variationTotal = 0.00;
      }
      totalQuantity += int.parse(totalList[i].quantity);
      totalAmount += (double.parse(totalList[i].price) + variationTotal) *
          int.parse(totalList[i].quantity);
    }
    return totalAmount.toStringAsFixed(2);
  }

  bool isUsedVariant(List<VariantChild> data) {
    for (int j = 0; j < data.length; j++) {
      if (data[j].quantity > 0) return true;
    }
    return false;
  }

  /*
  * edit product dialog
  * */
  showEditGroupNameDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditGroupNameDialog(
            orderGroup: widget.orderGroup,
            onClick: (OrderGroup orderGroup) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateGroupName(orderGroup);
              print(data);
              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {});
              } else if (data['status'] == '3') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('group_existed')}');
              } else
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  String getGroupName(groupName) {
    try {
      return groupName.split('\-')[1];
    } catch (e) {
      return groupName;
    }
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

  showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }
}
