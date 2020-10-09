import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my/fragment/group/group.dart';
import 'package:my/fragment/order/child/orderFragment.dart';
import 'package:my/fragment/product/product.dart';
import 'package:my/fragment/user/user.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/translation/AppLocalizations.dart';

class SearchPage extends StatefulWidget {
  final String type;

  SearchPage({this.type});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  StreamController queryStream;
  List<Order> list = [];

  var queryController = TextEditingController();

  int itemPerPage = 5, currentPage = 1;

  @override
  void initState() {
    super.initState();
    queryStream = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: TextField(
          controller: queryController,
          decoration: InputDecoration(
            hintText:
                '${AppLocalizations.of(context).translate('search_by')}${AppLocalizations.of(context).translate(widget.type)}',
            border: InputBorder.none,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                color: Colors.orangeAccent,
                onPressed: () {
                  queryController.clear();
                  queryStream.add('');
                }),
          ),
          style: TextStyle(color: Colors.black87),
          onChanged: (text) async {
            await Future.delayed(Duration(milliseconds: 300));
            queryStream.add(text);
          },
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      body: StreamBuilder(
          stream: queryStream.stream,
          builder: (context, object) {
            if (object.hasData && object.data.toString().length >= 1) {
              if (widget.type == 'order') {
                return OrderFragment(
                  query: object.data,
                  orderStatus: '',
                  driverId: '',
                  startDate: '',
                  endDate: '',
                );
              } else if (widget.type == 'group') {
                return GroupPage(
                  query: object.data,
                  startDate: '',
                  endDate: '',
                );
              } else if (widget.type == 'user') {
                return UserPage(
                  query: object.data,
                );
              } else {
                return ProductPage(
                  query: object.data,
                );
              }
            }

            return NotFound(
                title:
                    '${AppLocalizations.of(context).translate('search')}${AppLocalizations.of(context).translate(widget.type)}',
                description:
                    '${AppLocalizations.of(context).translate('try_some_keyword_to_find')}${AppLocalizations.of(context).translate(widget.type)}',
                showButton: false,
                button: '',
                drawable: 'drawable/search_icon.png');
          }),
    );
  }
}
