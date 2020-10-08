import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:my/fragment/order/detail/order_detail.dart';
import 'package:my/object/order.dart';
import 'package:flutter/material.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/statusControl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog/grouping_dialog.dart';

class CardView extends StatefulWidget {
  final Order orders;
  final Function(String) longPress;
  final Function() refresh;
  final List selectedList;

  CardView(
      {Key key, this.orders, this.longPress, this.selectedList, this.refresh})
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
                          ? '${AppLocalizations.of(context).translate('group')}: ${widget.orders.groupName}'
                          : '',
                      style: TextStyle(fontSize: 10, color: Colors.grey))),
              Visibility(
                  visible: widget.orders.driverId != null,
                  child: Text(
                      widget.orders.driverName != null
                          ? '${AppLocalizations.of(context).translate('delivery_by')}: ${widget.orders.driverName}'
                          : '',
                      style: TextStyle(fontSize: 10, color: Colors.grey))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Visibility(
                    visible: widget.orders.selfCollect == 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text(
                        '${AppLocalizations.of(context).translate('self_collect')}',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  Spacer(),
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
          child:
              Text('${AppLocalizations.of(context).translate('view_detail')}'),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child: Text('${AppLocalizations.of(context).translate('whatsapp')}'),
        ),
        PopupMenuItem(
          value: 'call',
          child:
              Text('${AppLocalizations.of(context).translate('phone_call')}'),
        ),
        PopupMenuItem(
          value: 'status',
          child: Text(
              '${AppLocalizations.of(context).translate('update_status')}'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('${AppLocalizations.of(context).translate('delete')}'),
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
                '👋你好, *${widget.orders.name}*\n我们已经收到你的订单的哦。\nWe have received your order.\n\n*订单号码/Order ID*👇\nNo.${Order().whatsAppOrderPrefix(widget.orders.orderID)}'
                '\n\n\n*检查订单/Check Order*\n点击这里/Click here👇\n'
                '${Domain.whatsAppLink}?id=${widget.orders.publicUrl}',
                context);
            break;
          case 'call':
            launch(('tel://+6${widget.orders.phone}'));
            break;
          case 'status':
            if (widget.orders.status == '1')
              showGroupingDialog(context);
            else
              _showDialog(context);
            break;
          case 'delete':
            showDeleteOrderDialog(context);
            break;
        }
      },
    );
  }

  showGroupingDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return GroupingDialog(
          onClick: (groupName, orderGroupId) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);
            Map data = await Domain().setOrderGroup(
                '1', groupName, widget.orders.id.toString(), orderGroupId);
            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(context).translate('update_success')}');
              widget.refresh();
            } else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(context).translate('something_went_wrong')}');
            }
          },
        );
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
          refresh: () {
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
          title: Text(
              '${AppLocalizations.of(context).translate('delete_request')}'),
          content: Text(
              '${AppLocalizations.of(context).translate('delete_message')}'),
          actions: <Widget>[
            FlatButton(
              child: Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data =
                    await Domain().deleteOrder(widget.orders.id.toString());
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext, '${AppLocalizations.of(context).translate('delete_success')}');
                  widget.refresh();
                } else
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(context).translate('something_went_wrong')}');
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
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(context).translate('update_success')}');
                setState(() {
                  widget.orders.status = value;
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(context).translate('something_went_wrong')}');
            });
      },
    );
  }
}
