import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:my/fragment/order/child/dialog/add_product_dialog.dart';
import 'package:my/fragment/order/child/dialog/driver_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_address_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_product_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_shipping_tax_dialog.dart';
import 'package:my/fragment/order/child/dialog/grouping_dialog.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/statusControl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetail extends StatefulWidget {
  final String orderId, id, publicUrl;
  final Function() refresh;

  OrderDetail({this.id, this.orderId, this.publicUrl, this.refresh});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  Order order = Order();
  List<OrderItem> orderItems = [];
  int updatePosition = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          'Order ${Order().orderPrefix(widget.orderId)}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('drawable/location.png'),
            onPressed: () {
              openMapsSheet(context);
            },
          ),
          whatsAppMenu(context),
        ],
      ),
      body: FutureBuilder(
          future: Domain().fetchOrderDetail(widget.publicUrl, widget.id),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                print(data);
                if (data['order_detail_status'] == '1') {
                  List orderDetail = data['order_detail'];
                  order = Order.fromJson(orderDetail[0]);
                }

                if (data['order_item_status'] == '1') {
                  List orderItem = data['order_item'];
                  orderItems.addAll(orderItem
                      .map((jsonObject) => OrderItem.fromJson(jsonObject))
                      .toList());
                }
                return mainContent(context);
              }
            }
            return CustomProgressBar();
          }),
    );
  }

  Widget mainContent(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          /*
                * header part
                * */
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${Order().formatDate(order.date ?? '')}' +
                        ' \. ' +
                        '${Order().orderPrefix(widget.orderId)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    order.name ?? '',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                            decoration: BoxDecoration(
                                color: StatusControl()
                                    .setStatusColor(order.status)),
                            child: Text(
                              StatusControl().setStatus(order.status),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                          Visibility(
                              visible: order.orderGroupId != null,
                              child: SizedBox(
                                height: 5,
                              )),
                          Visibility(
                              visible: order.orderGroupId != null,
                              child: Text('Group: ${order.groupName}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Visibility(
                              visible: order.driverId != null,
                              child: SizedBox(
                                height: 3,
                              )),
                          Visibility(
                            visible: order.driverId != null,
                            child: Text(
                              'Delivery By: ${order.driverName}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                      popUpMenu(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          /*
                * product part
                * */
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Products',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: orderItems.length > 0,
                    child: Column(
                      children: <Widget>[
                        for (var i = 0; i < orderItems.length; i++)
                          orderProductList(orderItems[i], i, context)
                      ],
                    ),
                  ),
                  Visibility(
                      visible: orderItems.length <= 0,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          'No Item Found',
                          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton.icon(
                            onPressed: () => showAddProductDialog(context),
                            elevation: 5,
                            color: Colors.orangeAccent,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Add Item',
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          /*
                * Payment part
                * */
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Payment',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Products Total'),
                      Text('RM ${order.total.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Shipping'),
                      Spacer(),
                      GestureDetector(
                        onTap: () =>
                            showEditShippingTaxDialog(context, 'delivery_fee'),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Text(
                          'RM ${Order().convertToInt(order.deliveryFee).toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Taxes'),
                      Spacer(),
                      GestureDetector(
                        onTap: () => showEditShippingTaxDialog(context, 'tax'),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text('Edit',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ),
                      Text(
                          'RM ${Order().convertToInt(order.tax).toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Order total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'RM${Order().countTotal(order).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          /*
              * customer information
              * */
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Customer Information',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Details',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              order.name,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              order.address,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${order.postcode} ${order.city}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.grey,
                            onPressed: () => showEditAddressDialog(context)),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                            icon: Icon(Icons.navigation),
                            color: Colors.blueAccent,
                            onPressed: () => openMapsSheet(context)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '+6${order.phone}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Spacer(),
                      whatsAppMenu(context),
                      IconButton(
                          icon: Icon(Icons.call),
                          color: Colors.greenAccent,
                          onPressed: () => launch(('tel://+${order.phone}')))
                    ],
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        order.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      IconButton(
                          icon: Icon(Icons.email),
                          color: Colors.red,
                          onPressed: () => launch(('mailto:${order.email}')))
                    ],
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget orderProductList(OrderItem orderItem, position, mainContent) {
    return Ink(
      color: orderItem.status == '0' ? null : Color.fromRGBO(255, 0, 0, 0.4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      orderItem.name,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'RM ${Order().convertToInt(orderItem.price).toStringAsFixed(2)} x ${orderItem.quantity}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: orderItem.remark != null &&
                          orderItem.remark.length > 0,
                      child: Text(
                        'Remark: ${orderItem.remark}',
                        style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'RM ${(Order().convertToInt(orderItem.price) * Order().convertToInt(orderItem.quantity)).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.orangeAccent[100],
                              onPressed: () {
                                showEditProductDialog(
                                    mainContent, orderItem, position);
                              }),
                          IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                deleteOrderItem(mainContent, orderItem);
                              })
                        ])
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  /*
*
*
*  action bar part
*
* */
  Widget whatsAppMenu(context) {
    return new PopupMenuButton(
      icon: Image.asset('drawable/whatsapp.png'),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('message', 'Send Message', true),
        _buildMenuItem('confirm', 'Confirm Order', true),
      ],
      onCanceled: () {},
      onSelected: (value) {
        print(value);
        switch (value) {
          case 'message':
            openWhatsApp(1);
            break;
          case 'confirm':
            openWhatsApp(0);
            break;
        }
      },
    );
  }

/*
*
*
*  header part
*
* */
  Widget popUpMenu(context) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.settings,
        color: Colors.grey,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('group', 'Assign Group / 统计', true),
        _buildMenuItem('status', 'Change Status / 状态', order.status != '1'),
        _buildMenuItem('driver', 'Assign Driver / 司机', order.status != '1'),
        _buildMenuItem('delete', 'Delete Order / 删除', true)
      ],
      onCanceled: () {},
      onSelected: (value) {
        print(value);
        switch (value) {
          case 'group':
            showGroupingDialog(context);
            break;
          case 'status':
            showStatusDialog(context);
            break;
          case 'driver':
            showDriverDialog(context);
            break;
          case 'delete':
            showDeleteOrderDialog(context);
            break;
        }
      },
    );
  }

  PopupMenuItem _buildMenuItem(String value, String text, bool enabled) {
    return PopupMenuItem(
      value: value,
      child: Text(text),
      enabled: enabled,
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
          content: Text("Confirm to this this item?"),
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
                Map data = await Domain().deleteOrder(widget.id.toString());
                if (data['status'] == '1') {
                  widget.refresh();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else
                  CustomSnackBar.show(mainContext, 'Something Went Wrong!');
              },
            ),
          ],
        );
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
                order.status, groupName, order.id.toString(), orderGroupId);

            print(data);

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext, 'Update Successfully!');
              setState(() {
                orderItems.clear();
              });
            } else {
              CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            }
          },
        );
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
                .setDriver(driverName, order.id.toString(), driverId);

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext, 'Update Successfully!');
              setState(() {
                orderItems.clear();
              });
            } else {
              CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            }
          },
        );
      },
    );
  }

  /*
  * update status dialog
  * */
  showStatusDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return StatusDialog(
            status: order.status,
            onClick: (value) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data =
                  await Domain().updateStatus(value, order.id.toString());

              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Update Successfully!');
                setState(() {
                  orderItems.clear();
                  order.status = value;
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }

  /*
  * edit product dialog
  * */
  showEditProductDialog(mainContext, OrderItem orderItem, position) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditProductDialog(
            order: orderItem,
            onClick: (orderItem) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateOrderItem(orderItem);
              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Update Successfully!');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }

  /*
  * edit product dialog
  * */
  deleteOrderItem(mainContext, OrderItem orderItem) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text("Confirm to this this item? \n${orderItem.name}"),
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
                Map data = await Domain()
                    .deleteOrderItem(orderItem.orderProductId.toString());
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext, 'Delete Successfully!');
                  setState(() {
                    orderItems.clear();
                  });
                } else
                  CustomSnackBar.show(mainContext, 'Something Went Wrong!');
              },
            ),
          ],
        );
      },
    );
  }

  /*
  * edit product dialog
  * */
  showEditShippingTaxDialog(mainContext, String type) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditShippingTaxDialog(
            order: order,
            type: type,
            onClick: (order) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateShippingFeeAndTax(order);
              print(data);
              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Update Successfully!');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }

  /*
  * add product dialog
  * */
  showAddProductDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AddProductDialog(
            formId: order.formId.toString(),
            addProduct: (Product product, quantity, remark) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain()
                  .addOrderItem(product, order.id.toString(), quantity, remark);

              print(data);
              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Add Successfully!');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }

  /*
  * edit address dialog
  * */
  showEditAddressDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditAddressDialog(
            order: order,
            onClick: (Order order) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateAddress(order);

              if (data['status'] == '1') {
                CustomSnackBar.show(mainContext, 'Update Successfully!');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext, 'Something Went Wrong!');
            });
      },
    );
  }

  openWhatsApp(int messageType) async {
    print(Order().orderPrefix(widget.orderId));
    String message = '';
    if (messageType == 0)
      message =
          '👋你好, *${order.name}*\n我们已经收到你的订单的哦。\nWe have received your order.\n\n*订单号码/Order ID*👇\nNo.${orderPrefix(widget.orderId)}'
          '\n\n\n*检查订单/Check Order*\n点击这里/Click here👇\n'
          '${Domain.whatsAppLink}?id=${order.publicUrl}';

    Order().openWhatsApp('+6' + order.phone, message, context);
  }

  String orderPrefix(orderID) {
    String prefix = '';
    for (int i = orderID.length; i < 5; i++) {
      prefix = prefix + "0";
    }
    return prefix + orderID;
  }

  openMapsSheet(context) async {
    try {
      final query =
          '${order.address + ' ' + order.postcode + ' ' + order.city}';
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var addressCoordinate = addresses.first;

      final coordinate = Coords(addressCoordinate.coordinates.latitude,
          addressCoordinate.coordinates.longitude);
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coordinate,
                          title: order.name,
                          description: order.address,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
