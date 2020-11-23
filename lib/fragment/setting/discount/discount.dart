import 'package:flutter/material.dart';
import 'package:my/fragment/user/user_list.dart';
import 'package:my/object/user.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class DiscountPage extends StatefulWidget {
  final String query;

  DiscountPage({this.query});

  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final int itemPerPage = 8, currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Domain().fetchUser(currentPage, itemPerPage, widget.query ?? ''),
          builder: (context, object) {
            print(object);
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                print(data);
                if (data['status'] == '1') {
                  List responseJson = data['user'];
                  return UserList(
                      users: (responseJson
                          .map((jsonObject) => User.fromJson(jsonObject))
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
        title: widget.query.length > 1 ? '${AppLocalizations.of(context).translate('not_item_found')}' : '${AppLocalizations.of(context).translate('no_customer_found')}',
        description: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('try_other_keyword')}'
            : '${AppLocalizations.of(context).translate('no_customer_found_description')}',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1 ? '' : '${AppLocalizations.of(context).translate('refresh')}',
        drawable:
            widget.query.length > 1 ? 'drawable/not_found.png' : 'drawable/user.png');
  }

}
