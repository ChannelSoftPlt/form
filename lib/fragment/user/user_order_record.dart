import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my/fragment/order/child/card_view.dart';
import 'package:my/object/order.dart';
import 'package:my/object/user.dart';
import 'package:my/shareWidget/filter_dialog.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserOrderRecord extends StatefulWidget {
  final User user;

  const UserOrderRecord({Key key, this.user}) : super(key: key);

  @override
  _UserOrderRecordState createState() => _UserOrderRecordState();
}

class _UserOrderRecordState extends State<UserOrderRecord> {
  List<Order> list = [];

  /*
  * pagination
  * */
  int itemPerPage = 20, currentPage = 1;
  bool itemFinish = false;
  bool isLoad = false;

  bool isCalculate = false;
  var totalAmount = 0.0;
  var totalOrderNo = 0.0;

  final selectedDateFormat = DateFormat("yyy-MM-dd");
  var startDate, endDate;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserOrderRecord();
    fetchTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('customer_id')} ${Order.getPhoneNumber(widget.user.phone)}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
          actions: [
            IconButton(
              icon: Icon(
                Icons.sort,
                color: Colors.orange,
              ),
              onPressed: () {
                showFilterDialog(context);
                // do something
              },
            ),
          ],
        ),
        bottomNavigationBar: bottomNavigation(),
        body: SafeArea(child: mainContent()));
  }

  bottomNavigation() {
    return Card(
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
                    Countup(
                      begin: 0,
                      end: totalOrderNo,
                      duration: Duration(seconds: 1),
                      separator: ',',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      '${AppLocalizations.of(context).translate('order_number')}',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              )),
          Container(height: 50, child: VerticalDivider(color: Colors.grey)),
          Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                alignment: Alignment.center,
                height: 70,
                child: Column(
                  children: [
                    Countup(
                      begin: 0,
                      end: totalAmount,
                      precision: 2,
                      duration: Duration(seconds: 1),
                      separator: ',',
                      prefix: 'RM',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      '${AppLocalizations.of(context).translate('total_amount')}',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
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
            child: list.length > 0
                ? listView()
                : isLoad
                    ? notFound()
                    : CustomProgressBar()));
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

  Future fetchUserOrderRecord() async {
    Map data = await Domain().fetchUserOrder(
        currentPage,
        itemPerPage,
        '',
        startDate != null
            ? selectedDateFormat.format(startDate).toString()
            : '',
        endDate != null ? selectedDateFormat.format(endDate).toString() : '',
        widget.user.phone);

    setState(() {
      isLoad = true;
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

  Future fetchTotalAmount() async {
    Map data = await Domain().fetchUserTotalAmount(widget.user.phone);
    List<Order> orderAmount = [];
    setState(() {
      if (data['status'] == '1') {
        isCalculate = true;
        try {
          List responseJson = data['total'];
          orderAmount.addAll(responseJson
              .map((jsonObject) => Order.fromJson(jsonObject))
              .toList());
          orderAmount.forEach((order) {
            totalOrderNo++;
            totalAmount += Order().countTotal(order);
          });
        } catch ($e) {
          totalAmount = 0.0;
        }
      }
    });
  }

  showFilterDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return FilterDialog(
          showDriver: false,
          fromDate: this.startDate,
          toDate: this.endDate,
          onClick: (fromDate, toDate, driver) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);
            this.startDate = fromDate;
            this.endDate = toDate;
            _onRefresh();
          },
        );
      },
    );
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

        isLoad = false;
        itemFinish = false;
        isCalculate = false;
        totalAmount = 0.0;
        totalOrderNo = 0.0;

        fetchUserOrderRecord();
        fetchTotalAmount();

        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchUserOrderRecord();
      });
    }
    _refreshController.loadComplete();
  }
}
