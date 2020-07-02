import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:my/fragment/order/child/dialog/add_product_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_address_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_product_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_shipping_tax_dialog.dart';
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

  OrderDetail({this.id, this.orderId, this.publicUrl});

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
      ),
      body: FutureBuilder(
          future: Domain().fetchOrderDetail(widget.publicUrl, widget.id),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List orderDetail = data['order_detail'];
                  List orderItem = data['order_item'];

                  orderItems.addAll(orderItem
                      .map((jsonObject) => OrderItem.fromJson(jsonObject))
                      .toList());
                  order = Order.fromJson(orderDetail[0]);
                  return mainContent(context);
                }
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
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                        decoration: BoxDecoration(
                            color:
                                StatusControl().setStatusColor(order.status)),
                        child: Text(
                          StatusControl().setStatus(order.status),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showStatusDialog(context);
                          })
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
                  Column(
                    children: <Widget>[
                      for (var i = 0; i < orderItems.length; i++)
                        orderProductList(orderItems[i], i, context)
                    ],
                  ),
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
                      Column(
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
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.grey,
                          onPressed: () => showEditAddressDialog(context)),
                      IconButton(
                          icon: Icon(Icons.navigation),
                          color: Colors.blueAccent,
                          onPressed: () => openMapsSheet(context)),
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
                      IconButton(
                          icon: Icon(Icons.message),
                          color: Colors.greenAccent,
                          onPressed: () => openWhatsApp()),
                      IconButton(
                          icon: Icon(Icons.call),
                          color: Colors.greenAccent,
                          onPressed: () => launch(('tel://+6${order.phone}')))
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
            addProduct: (Product product, quantity) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().addOrderItem(product, order.id.toString(), quantity);
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

  openWhatsApp() {
    Order().openWhatsApp(
        '+6' + order.phone,
        'Hi, ${order.name}\nThis is your Order Id ${order.orderID}\n\nDetails Please go through this link\n'
        '${Domain.whatsAppLink}.?id=5915ad448f9d75bd91c247c874ff1914',
        context);
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
