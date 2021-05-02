import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:my/translation/AppLocalizations.dart';

import 'child/orderFragment.dart';

class OrderPage extends StatefulWidget {
  final String startDate, endDate, driverId;

  OrderPage({this.startDate, this.endDate, this.driverId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    FlutterAppBadger.removeBadge();
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                constraints: BoxConstraints.expand(height: 50),
                child: TabBar(
                    indicatorColor: Colors.orangeAccent,
                    labelColor: Colors.orangeAccent,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                          text:
                              '${AppLocalizations.of(context).translate('new_order')}'),
                      Tab(
                          text:
                              '${AppLocalizations.of(context).translate('processing')}'),
                      Tab(
                          text:
                              '${AppLocalizations.of(context).translate('all_orders')}'),
                    ]),
              ),
              Expanded(
                child: Container(
                  child: TabBarView(children: [
                    orderFragment('1'),
                    orderFragment('2'),
                    orderFragment('')
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget orderFragment(String status) {
    return OrderFragment(
      orderStatus: status,
      query: '',
      startDate: widget.startDate ?? '',
      endDate: widget.endDate ?? '',
      driverId: widget.driverId ?? '',
    );
  }
}
