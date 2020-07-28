import 'package:flutter/material.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';
import '../../../shareWidget/not_found.dart';
import 'order_list_state.dart';

class OrderFragment extends StatefulWidget {
  final String orderStatus, query, driverId, startDate, endDate;

  OrderFragment(
      {this.orderStatus,
      this.query,
      this.driverId,
      this.startDate,
      this.endDate});

  @override
  _OrderFragmentState createState() => _OrderFragmentState();
}

class _OrderFragmentState extends State<OrderFragment> {
  final int itemPerPage = 5, currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Domain().fetchOrder(
              currentPage,
              itemPerPage,
              widget.orderStatus,
              widget.query ?? '',
              '',
              widget.driverId ?? '',
              widget.startDate ?? '',
              widget.endDate ?? ''),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List responseJson = data['order'];
                  return OrderList(
                      orderStatus: widget.orderStatus,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      driverId: widget.driverId,
                      query: widget.query,
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

  Widget notFound() {
    return NotFound(
        title:
            widget.query.length > 1 ? 'No Item Found!' : 'No Order Right Now!',
        description: widget.query.length > 1
            ? 'Please try another keyword...'
            : 'You\'re up-to-date! would work well',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1 ? '' : 'Refresh',
        drawable: widget.query.length > 1
            ? 'drawable/not_found.png'
            : 'drawable/no_order.png');
  }
}
