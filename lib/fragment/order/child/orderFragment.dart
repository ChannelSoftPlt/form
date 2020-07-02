
import 'package:flutter/material.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';
import '../../../shareWidget/not_found.dart';
import 'order_list_state.dart';

class OrderFragment extends StatelessWidget {
  final int itemPerPage = 5, currentPage = 1;
  final String orderStatus, query;

  OrderFragment({this.orderStatus, this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Domain().fetchOrder(currentPage, itemPerPage, orderStatus, query ?? ''),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List responseJson = data['order'];
                  return OrderList(
                      orderStatus: orderStatus,
                      orders: (responseJson
                          .map((jsonObject) => Order.fromJson(jsonObject))
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

  Widget notFound(){
    return NotFound(
        title: query.length > 1 ? 'No Item Found!' : 'No Order Right Now!',
        description: query.length > 1 ? 'Please try another keyword...' : 'You\'re up-to-date! would work well',
        showButton: query.length < 1,
        button: query.length > 1 ? '' : 'Refresh',
        drawable: query.length > 1 ? 'drawable/not_found.png' : 'drawable/no_order.png');
  }

}
