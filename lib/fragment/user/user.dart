import 'package:flutter/material.dart';
import 'package:my/fragment/group/group_list.dart';
import 'package:my/fragment/user/user_list.dart';
import 'package:my/object/order_group.dart';
import 'package:my/object/user.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';

class UserPage extends StatefulWidget {
  final String query, startDate, endDate;

  UserPage({this.query, this.startDate, this.endDate});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
        title: widget.query.length > 1 ? 'No Item Found!' : 'No Customer Found!',
        description: widget.query.length > 1
            ? 'Please try another keyword...'
            : 'Don\'t worry, your customer are coming soon...',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1 ? '' : 'Refresh',
        drawable:
            widget.query.length > 1 ? 'drawable/not_found.png' : 'drawable/user.png');
  }

}
