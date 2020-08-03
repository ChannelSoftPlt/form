import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:my/fragment/order/detail/order_detail.dart';
import 'package:my/object/order.dart';
import 'package:flutter/material.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/statusControl.dart';
import 'package:url_launcher/url_launcher.dart';

class CardView extends StatefulWidget {
  final Order orders;
  final Function(String) longPress;
  final Function() refresh;
  final List selectedList;

  CardView({Key key, this.orders, this.longPress, this.selectedList, this.refresh})
      : super(key: key);

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  isSelected() {
    for (int i = 0; i < widget.selectedList.length; i++) {
      if (widget.selectedList[i] == widget.orders.id.toString()) {
        return Colors.orangeAccent;
      }
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected(),
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onLongPress: () {
          if (widget.longPress != null)
            widget.longPress(widget.orders.id.toString());
        },
        onTap: () => widget.selectedList.length > 0
            ? widget.longPress(widget.orders.id.toString())
            : openOrderDetail(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${Order().formatDate(widget.orders.date)}',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      Text(
                        Order().orderPrefix(widget.orders.orderID),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  popUpMenu(widget.orders.orderID, context) // Pop Out Menu
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.orders.name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    widget.orders.total != null
                        ? 'RM ${Order().countTotal(widget.orders).toStringAsFixed(2)}'
                        : 'RM --',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Text(widget.orders.phone, style: TextStyle(fontSize: 12)),
              Visibility(
                  visible: widget.orders.orderGroupId != null,
                  child: Text(
                      widget.orders.groupName != null
                          ? 'Group: ${widget.orders.groupName}'
                          : '',
                      style: TextStyle(fontSize: 10, color: Colors.grey))),
              Visibility(
                  visible: widget.orders.driverId != null,
                  child: Text(
                      widget.orders.driverName != null
                          ? 'Deliver By: ${widget.orders.driverName}'
                          : '',
                      style: TextStyle(fontSize: 10, color: Colors.grey))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                    decoration: BoxDecoration(
                        color: StatusControl()
                            .setStatusColor(widget.orders.status)),
                    child: Text(
                      StatusControl().setStatus(widget.orders.status),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget popUpMenu(id, context) {
    return new PopupMenuButton(
      icon: Icon(Icons.tune),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'detail',
          child: Text("View Details"),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child: Text("WhatsApp"),
        ),
        PopupMenuItem(
          value: 'call',
          child: Text("Phone Call"),
        ),
        PopupMenuItem(
          value: 'status',
          child: Text("Update Status"),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text("Delete"),
        ),
      ],
      onCanceled: () {},
      onSelected: (value) {
        print(value);
        switch (value) {
          case 'detail':
            openOrderDetail();
            break;
          case 'whatsapp':
            Order().openWhatsApp(
                '+6' + widget.orders.phone,
                'Hi, ${widget.orders.name}\nThis is your Order Id ${widget.orders.orderID}\n\nDetails Please go through this link\n'
                '${Domain.whatsAppLink}.?id=5915ad448f9d75bd91c247c874ff1914',
                context);
            break;
          case 'call':
            launch(('tel://+6${widget.orders.phone}'));
            break;
          case 'status':
            _showDialog(context);
            break;
          case 'delete':
            showDeleteOrderDialog(context);
            break;
        }
      },
    );
  }

  void showSnackBar(context, text) {
    final snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  openOrderDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetail(
          orderId: widget.orders.orderID,
          id: widget.orders.id.toString(),
          publicUrl: widget.orders.publicUrl,
          refresh: (){
            widget.refresh();
          },
        ),
      ),
    );
  }

  /*
  * delete order
  * */
  showDeleteOrderDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text("Confirm to this these item?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain().deleteOrder(widget.orders.id.toString());
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext, 'Delete Successfully!');
                  widget.refresh();
                } else
                  CustomSnackBar.show(mainContext, 'Something Went Wrong!');
              },
            ),
          ],
        );
      },
    );
  }

  _showDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return StatusDialog(
            status: widget.orders.status,
            onClick: (value) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain()
                  .updateStatus(value, widget.orders.id.toString());

              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Update Successfully!');
                setState(() {
                  widget.orders.status = value;
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }
}
