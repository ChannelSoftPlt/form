import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/setting/discount/discount_list_view.dart';
import 'package:my/object/discount.dart';

import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CouponList extends StatefulWidget {
  final List<Coupon> coupons;
  final String query;

  CouponList({this.coupons, this.query});

  @override
  _CouponListState createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {
  List<Coupon> list = [];
  String query;
  int itemPerPage = 8, currentPage = 1;
  bool itemFinish = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = widget.coupons;
    query = widget.query ?? '';
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
              body = Text("${AppLocalizations.of(context).translate('pull_up_load')}");
            } else if (mode == LoadStatus.loading) {
              body = CustomProgressBar();
            } else if (mode == LoadStatus.failed) {
              body = Text("${AppLocalizations.of(context).translate('load_failed')}");
            } else if (mode == LoadStatus.canLoading) {
              body = Text('${AppLocalizations.of(context).translate('release_to_load_more')}');
            } else {
              body = Text('${AppLocalizations.of(context).translate('no_more_data')}');
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
          return DiscountListView(coupon: list[index]);
        });
  }

  _onRefresh() async {
    print('refresh');
    // monitor network fetch
    if (mounted)
      setState(() {
        list.clear();
        currentPage = 1;
        itemFinish = false;
        fetchCoupon();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchCoupon();
      });
    }
    _refreshController.loadComplete();
  }

  Future fetchCoupon() async {
    Map data = await Domain().fetchDiscount(currentPage, itemPerPage, query);
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['coupon'];
        list.addAll(responseJson
            .map((jsonObject) => Coupon.fromJson(jsonObject))
            .toList());
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }
}
