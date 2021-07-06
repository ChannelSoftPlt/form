import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:my/fragment/order/detail/order_detail.dart';
import 'package:my/fragment/order/print/print_dialog.dart';
import 'package:my/object/order.dart';
import 'package:flutter/material.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:my/utils/statusControl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my/utils/paymentStatus.dart';

import 'dialog/driver_dialog.dart';
import 'dialog/grouping_dialog.dart';
import 'package:my/shareWidget/payment_status_dialog.dart';

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
              Text('+' + Order.getPhoneNumber(widget.orders.phone),
                  style: TextStyle(fontSize: 12)),
              Visibility(
                  visible: widget.orders.orderGroupId != null,
                  child: Text(
                      widget.orders.groupName != null
                          ? '${AppLocalizations.of(context).translate('group')}: ${getGroupName(widget.orders.groupName)}'
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
                  Row(
                    children: [
                      Visibility(
                        visible: widget.orders.paymentStatus != '0',
                        child: Container(
                          padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                          decoration: BoxDecoration(
                              color: PaymentStatus()
                                  .setStatusColor(widget.orders.paymentStatus)),
                          child: Text(
                            PaymentStatus().setStatus(
                                widget.orders.paymentStatus, context),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                        decoration: BoxDecoration(
                            color: StatusControl()
                                .setStatusColor(widget.orders.status)),
                        child: Text(
                          StatusControl()
                              .setStatus(widget.orders.status, context),
                          style: TextStyle(
                              fontSize: 12,
                              color: widget.orders.status == '1'
                                  ? Colors.black54
                                  : Colors.white),
                        ),
                      ),
                    ],
                  )
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
          value: 'payment_status',
          child: Text(
              '${AppLocalizations.of(context).translate('change_payment_status')}'),
        ),
        PopupMenuItem(
          value: 'group',
          child:
              Text('${AppLocalizations.of(context).translate('assign_group')}'),
        ),
        PopupMenuItem(
          value: 'driver',
          child: Text(
              '${AppLocalizations.of(context).translate('assign_driver')}'),
        ),
        PopupMenuItem(
          value: 'receipt',
          child: Text(
              '${AppLocalizations.of(context).translate('print_receipt')}'),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Text('${AppLocalizations.of(context).translate('print_pdf')}'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('${AppLocalizations.of(context).translate('delete')}'),
        ),
      ],
      onCanceled: () {},
      onSelected: (value) {
        switch (value) {
          case 'detail':
            openOrderDetail();
            break;
          case 'whatsapp':
            String message =
                'Hi,%20We%20have%20received%20your%20order.%0a*Order%20No.${Order().whatsAppOrderPrefix(widget.orders.orderID)}*%0a%0aPlease%20Check%20Your%20Order%20Here:%0a${Domain.whatsAppLink}?id=${widget.orders.publicUrl}';
            Order().openWhatsApp(
                '+' + Order.getPhoneNumber(widget.orders.phone),
                message,
                context);
            break;
          case 'call':
            launch(('tel://+${Order.getPhoneNumber(widget.orders.phone)}'));
            break;
          case 'status':
            _showDialog(context);
            break;
          case 'payment_status':
            showPaymentStatusDialog(context);
            break;
          case 'group':
            showGroupingDialog(context);
            break;
          case 'driver':
            showDriverDialog(context);
            break;
          case 'receipt':
            openPrintDialog(context);
            break;
          case 'pdf':
            printInvoice(context);
            break;
          case 'delete':
            showDeleteOrderDialog(context);
            break;
        }
      },
    );
  }

  /*
  * update payment status dialog
  * */
  showPaymentStatusDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return PaymentStatusDialog(
            paymentStatus: widget.orders.paymentStatus,
            onClick: (value) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain()
                  .updatePaymentStatus(value, widget.orders.id.toString());

              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                widget.refresh();
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
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
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              widget.refresh();
            } else if (data['status'] == '3') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('group_existed')}');
            } else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            }
          },
        );
      },
    );
  }

  openPrintDialog(mainContext) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        return PrintDialog(
          orderId: widget.orders.id.toString(),
        );
      },
    );
  }

  printInvoice(context) {
    try {
      launch('${Domain.invoiceLink}${widget.orders.publicUrl}');
    } catch ($e) {
      showSnackBar(
          context, AppLocalizations.of(context).translate('invalid_file'));
    }
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
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
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
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('delete_success')}');
                  widget.refresh();
                } else
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
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
              Map data = await Domain().updateStatus(value, widget.orders.id.toString());
              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                /*
                * send whatsApp here
                * */
                var allowWhatsApp =
                    await SharePreferences().read('allow_send_whatsapp');
                if (allowWhatsApp == '0') {
                  Domain().sendWhatsApp2Customer(widget.orders.id.toString());
                }
                widget.refresh();
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  showDriverDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return DriverDialog(
          onClick: (driverName, driverId) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);

            Map data = await Domain()
                .setDriver(driverName, widget.orders.id.toString(), driverId);

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              widget.refresh();
            } else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            }
          },
        );
      },
    );
  }

  String getGroupName(groupName) {
    try {
      return groupName.split('\-')[1];
    } catch (e) {
      return groupName;
    }
  }
}
