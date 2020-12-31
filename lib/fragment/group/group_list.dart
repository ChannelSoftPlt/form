import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'group_grid_view.dart';

class GroupList extends StatefulWidget {
  final List<OrderGroup> groups;
  final String query, startDate, endDate;

  GroupList({this.groups, this.query, this.startDate, this.endDate});

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  List<OrderGroup> list = [];
  String query;
  int itemPerPage = 20, currentPage = 1;
  bool itemFinish = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = widget.groups;
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
    return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: (100 / 110),
        children: List.generate(list.length, (index) {
          return GroupGridView(orderGroup: list[index]);
        }));
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        list.clear();
        currentPage = 1;
        itemFinish = false;
        fetchGroup();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchGroup();
      });
    }
    _refreshController.loadComplete();
  }

  Future fetchGroup() async {
    Map data = await Domain().fetchGroupWithPagination(
        currentPage, itemPerPage, query, widget.startDate, widget.endDate);
    print(data);
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['order_group'];
        list.addAll(responseJson
            .map((jsonObject) => OrderGroup.fromJson(jsonObject))
            .toList());
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
  }
}
