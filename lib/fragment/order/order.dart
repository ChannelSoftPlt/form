import 'package:flutter/material.dart';

import 'child/orderFragment.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
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
                      Tab(text: "New Orders"),
                      Tab(text: "Processing"),
                      Tab(text: "All Orders"),
                    ]),
              ),
              Expanded(
                child: Container(
                  child: TabBarView(children: [
                    OrderFragment(orderStatus: '1'),
                    //Processing Order
                    OrderFragment(orderStatus: '3'),
                    //All Orders
                    OrderFragment(orderStatus: '')
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
