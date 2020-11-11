import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/order/child/dialog/driver_dialog.dart';
import 'package:my/fragment/order/child/dialog/grouping_dialog.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'card_view.dart';

class OrderList extends StatefulWidget {
  final List<Order> orders;
  final String orderStatus, query, groupId, driverId, startDate, endDate;

  OrderList(
      {this.orders,
      this.orderStatus,
      this.query,
      this.groupId,
      this.driverId,
      this.startDate,
      this.endDate});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Order> list = [];
  String status;
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
    checkGrouping();
  }

  checkGrouping() async {
    grouping =
        Merchant.fromJson(await SharePreferences().read('merchant')).grouping;
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
        child: grouping ? groupingListView() : customListView());
  }

  Widget customListView() {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return CardView(
            orders: list[index],
            selectedList: selectedList,
            refresh: () => _onRefresh(),
          );
        });
  }

  /*
  * when long click then use this list view
  * */
  Widget groupingListView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            '${AppLocalizations.of(context).translate('select_item')} ${selectedList.length}',
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
                          '${AppLocalizations.of(context).translate('clear_all')}',
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
                          '${AppLocalizations.of(context).translate('select_all')}',
                          style: TextStyle(color: Colors.white),
                        )),
                    popUpMenu(context),
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
              },
              refresh: () => _onRefresh(),
            ),
            childCount: list.length,
          ),
        ),
      ],
    );
  }

  Widget popUpMenu(context) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.settings,
        color: Colors.grey,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('group',
            '${AppLocalizations.of(context).translate('assign_group')}', true),
        _buildMenuItem(
            'status',
            '${AppLocalizations.of(context).translate('change_status')}',
            status != '1'),
        _buildMenuItem(
            'driver',
            '${AppLocalizations.of(context).translate('assign_driver')}',
            status != '1'),
        _buildMenuItem('delete',
            '${AppLocalizations.of(context).translate('delete_order')}', true)
      ],
      onCanceled: () {},
      onSelected: (value) {
        print(value);
        switch (value) {
          case 'group':
            showGroupingDialog(context);
            break;
          case 'status':
            showStatusDialog(context);
            break;
          case 'driver':
            showDriverDialog(context);
            break;
          case 'delete':
            showDeleteOrderDialog(context);
            break;
        }
      },
    );
  }

  PopupMenuItem _buildMenuItem(String value, String text, bool enabled) {
    return PopupMenuItem(
      value: value,
      child: Text(text),
      enabled: enabled,
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
        selectedList.clear();
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
    Map data = await Domain().fetchOrder(currentPage, itemPerPage, status,
        widget.query, '', widget.driverId, widget.startDate, widget.endDate);

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

  showGroupingDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return GroupingDialog(
          onClick: (groupName, orderGroupId) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);

            Map data = await Domain().setOrderGroup(
                status, groupName, selectedList.join(","), orderGroupId);

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              _onRefresh();
            }
            else if(data['status'] == '3') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('group_existed')}');
            }
            else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            }
          },
        );
      },
    );
  }

  showDriverDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return DriverDialog(
          onClick: (driverName, driverId) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);

            Map data = await Domain()
                .setDriver(driverName, selectedList.join(","), driverId);

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              _onRefresh();
            } else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            }
          },
        );
      },
    );
  }

  showStatusDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return StatusDialog(
            status: '-1',
            onClick: (value) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain()
                  .updateMultipleStatus(value, selectedList.join(','));

              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                _onRefresh();
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * edit product dialog
  * */
  showDeleteOrderDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              '${AppLocalizations.of(context).translate('delete_request')}'),
          content: Text(
              '${AppLocalizations.of(context).translate('delete_message')}'),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain().deleteOrder(selectedList.join(','));
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('delete_success')}');
                  _onRefresh();
                } else
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
              },
            ),
          ],
        );
      },
    );
  }
}
