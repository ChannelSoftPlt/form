import 'package:flutter/material.dart';
import 'package:my/fragment/group/group_list.dart';
import 'package:my/object/order_group.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class GroupPage extends StatefulWidget {
  final String query, startDate, endDate;

  GroupPage({this.query, this.startDate, this.endDate});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final int itemPerPage = 20, currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Domain().fetchGroupWithPagination(currentPage, itemPerPage,
              widget.query ?? '', widget.startDate, widget.endDate),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                print(data);
                if (data['status'] == '1') {
                  List responseJson = data['order_group'];
                  return GroupList(
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      groups: (responseJson
                          .map((jsonObject) => OrderGroup.fromJson(jsonObject))
                          .toList()));
                } else {
                  return notFound();
                }
              }
            }
            return Center(child: CustomProgressBar());
          }),
    );
  }

  Widget notFound() {
    return NotFound(
        title: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('not_item_found')}'
            : '${AppLocalizations.of(context).translate('no_group_found')}',
        description: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('try_other_keyword')}'
            : '${AppLocalizations.of(context).translate('no_group_description')}',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1 ? '' : '${AppLocalizations.of(context).translate('refresh')}',
        drawable: widget.query.length > 1
            ? 'drawable/not_found.png'
            : 'drawable/folder.png');
  }
}
