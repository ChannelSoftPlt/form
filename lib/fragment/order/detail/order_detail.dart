import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:my/fragment/order/child/dialog/add_edit_product/add_product_dialog.dart';
import 'package:my/fragment/order/child/dialog/driver_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_address_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_coupon_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_discount_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_name_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_phone_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_customer_note_dialog.dart';
import 'package:my/fragment/order/child/dialog/edit_shipping_tax_dialog.dart';
import 'package:my/fragment/order/child/dialog/grouping_dialog.dart';
import 'package:my/fragment/order/detail/proof_of_delivery.dart';
import 'package:my/fragment/order/print/print_dialog.dart';
import 'package:my/object/coupon.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/shareWidget/payment_status_dialog.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/status_dialog.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/paymentStatus.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:my/utils/statusControl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int totalQuantity;

  bool discountEnable = false;
  bool allowTakePhoto = false;

  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    preChecking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('order')} ${Order().orderPrefix(widget.orderId)}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
        actions: <Widget>[
          printMenu(context),
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

                //count total order item quantity
                totalQuantity = 0;
                for (int i = 0; i < orderItems.length; i++)
                  totalQuantity += int.parse(orderItems[i].quantity);

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
                  Visibility(
                    visible: order.selfCollect != 1,
                    child: Text(
                      '${AppLocalizations.of(context).translate('self_collect')}',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                  Visibility(
                    visible:
                        order.deliveryDate != '' || order.deliveryTime != '',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).translate('delivery_date')}: ${order.deliveryDate} ${order.deliveryTime}',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: GestureDetector(
                            onTap: () => checkCurrentTimeForDatePicker(),
                            child: Text(
                              '${AppLocalizations.of(context).translate('edit')}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                                decoration: BoxDecoration(
                                    color: StatusControl()
                                        .setStatusColor(order.status)),
                                child: Text(
                                  StatusControl()
                                      .setStatus(order.status, context),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Visibility(
                                visible: order.paymentStatus != '0',
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                                  decoration: BoxDecoration(
                                      color: PaymentStatus()
                                          .setStatusColor(order.paymentStatus)),
                                  child: Text(
                                    PaymentStatus().setStatus(
                                        order.paymentStatus, context),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                              visible: order.orderGroupId != null,
                              child: SizedBox(
                                height: 5,
                              )),
                          Visibility(
                              visible: order.orderGroupId != null,
                              child: Text(
                                  '${AppLocalizations.of(context).translate('group')}: ${getGroupName(order.groupName)}',
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
                              '${AppLocalizations.of(context).translate('delivery_by')}: ${order.driverName}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                      Container(
                          alignment: Alignment.topRight,
                          child: popUpMenu(context)),
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
                    '${AppLocalizations.of(context).translate('products')}',
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
                          '${AppLocalizations.of(context).translate('no_item_found')}',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton.icon(
                            onPressed: () =>
                                showAddProductDialog(context, null, null),
                            elevation: 5,
                            color: Colors.orangeAccent,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            label: Text(
                              '${AppLocalizations.of(context).translate('add_item')}',
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate('special_remark')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: RaisedButton.icon(
                            onPressed: () => showCustomerNoteDialog(context),
                            elevation: 5,
                            color: Colors.red,
                            icon: Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: Text(
                              '${AppLocalizations.of(context).translate('edit_note')}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                  Container(
                    alignment: order.note != ''
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      child: Text(
                        order.note != ''
                            ? order.note
                            : '${AppLocalizations.of(context).translate('no_remark')}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: order.note != ''
                                ? Colors.black
                                : Colors.grey[600],
                            fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${AppLocalizations.of(context).translate('payment')}',
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
                      Text(
                          '${AppLocalizations.of(context).translate('products_total')}'),
                      Text('RM ${order.total.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                            '${AppLocalizations.of(context).translate('shipping')}'),
                      ),
                      GestureDetector(
                        onTap: () =>
                            showEditShippingTaxDialog(context, 'delivery_fee'),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            '${AppLocalizations.of(context).translate('edit')}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                            'RM ${Order().convertToInt(order.deliveryFee).toStringAsFixed(2)}',
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                            '${AppLocalizations.of(context).translate('discount')}'),
                      ),
                      GestureDetector(
                        onTap: () => showEditDiscountDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                          child: Text(
                            '${AppLocalizations.of(context).translate('edit')}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                            '-RM ${Order().convertToInt(order.discountAmount).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: discountEnable,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Visibility(
                    visible: discountEnable,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: RichText(
                            maxLines: 10,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${AppLocalizations.of(context).translate('coupon')} ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: order.couponCode,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: order.couponCode != null,
                          child: GestureDetector(
                            onTap: () => deleteCoupon(context),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                              child: Text(
                                '${AppLocalizations.of(context).translate('remove')}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showEditCouponDialog(context),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                            child: Text(
                              '${AppLocalizations.of(context).translate('edit')}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '-RM ${Order().convertToInt(order.couponDiscount).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          flex: 3,
                          child: Text(
                              '${AppLocalizations.of(context).translate('tax')}')),
                      GestureDetector(
                        onTap: () => showEditShippingTaxDialog(context, 'tax'),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                              '${AppLocalizations.of(context).translate('edit')}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'RM ${Order().convertToInt(order.tax).toStringAsFixed(2)}',
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${AppLocalizations.of(context).translate('order_total')}',
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
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${AppLocalizations.of(context).translate('payment_method')}',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        getPaymentMethod(order.paymentMethod),
                        style: TextStyle(fontSize: 11),
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
                    '${AppLocalizations.of(context).translate('customer_information')}',
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
                    '${AppLocalizations.of(context).translate('details')}',
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
                                  color: Colors.grey[600], fontSize: 15),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            if (order.selfCollect == 1)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                              )
                            else
                              Text(
                                '${AppLocalizations.of(context).translate('self_collect')}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: editCustomerDetailMenu(context),
                      ),
                      Visibility(
                        visible: order.selfCollect == 1,
                        child: Expanded(
                          flex: 1,
                          child: IconButton(
                              icon: Icon(Icons.navigation),
                              color: Colors.blueAccent,
                              onPressed: () => openMapsSheet(context)),
                        ),
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
                        '+${Order.getPhoneNumber(order.phone)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.grey,
                          onPressed: () => showEditPhoneDialog(context)),
                      whatsAppMenu(context),
                      IconButton(
                          icon: Icon(Icons.call),
                          color: Colors.greenAccent,
                          onPressed: () => launch(
                              ('tel://+${Order.getPhoneNumber(order.phone)}')))
                    ],
                  ),
                  Visibility(
                    visible: order.email != '',
                    child: Divider(
                      color: Colors.teal.shade100,
                      thickness: 1.0,
                    ),
                  ),
                  Visibility(
                    visible: order.email != '',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          order.email,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        IconButton(
                            icon: Icon(Icons.email),
                            color: Colors.red,
                            onPressed: () => launch(('mailto:${order.email}')))
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          /*
          * proof of delivery
          * */
          Visibility(
            visible: allowTakePhoto,
            child: ProofOfDelivery(
              orders: order,
              refresh: (message) {
                showSnackBar(AppLocalizations.of(context).translate(message));
                setState(() {});
              },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${orderItem.quantity} x ${orderItem.name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                AppLocalizations.of(context).translate('price'),
                                style: TextStyle(fontSize: 12),
                              )),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'RM ${Order().convertToInt(orderItem.price).toStringAsFixed(2)}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      Visibility(
                          visible: orderItem.variation != '',
                          child: addOnList(orderItem.variation)),
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: orderItem.remark != null &&
                            orderItem.remark.length > 0,
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            '${AppLocalizations.of(context).translate('remark')}: ${orderItem.remark}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'RM ${((Order().convertToInt(orderItem.price) + countVariantTotal(orderItem.variation)) * Order().convertToInt(orderItem.quantity)).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.orangeAccent[100],
                              onPressed: () => showAddProductDialog(
                                  context, orderItem, position)),
                          IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                deleteOrderItem(
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

  Widget addOnList(variation) {
    //variant setting
    List<VariantGroup> variant = [];
    try {
      if (variation != '') {
        List data = jsonDecode(variation);
        variant.addAll(data
            .map((jsonObject) => VariantGroup.fromJson(jsonObject))
            .toList());
      }
    } catch ($e) {}

    return Column(
      children: [
        for (int i = 0; i < variant.length; i++)
          if (isUsedVariant(variant[i].variantChild))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5,
                ),
                for (int j = 0; j < variant[i].variantChild.length; j++)
                  if (variant[i].variantChild[j].quantity > 0)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            variant[i].variantChild[j].name,
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('+RM ${variant[i].variantChild[j].price}',
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 14),
                              textAlign: TextAlign.end),
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
              ],
            )
      ],
    );
  }

  countVariantTotal(variation) {
    var totalVariant = 0.00;

    if (variation != '') {
      List<VariantGroup> variant = [];
      List<VariantChild> variantChild = [];

      try {
        List data = jsonDecode(variation);
        variant.addAll(data
            .map((jsonObject) => VariantGroup.fromJson(jsonObject))
            .toList());
      } catch ($e) {}

      for (int i = 0; i < variant.length; i++) {
        variantChild = variant[i].variantChild;
        for (int j = 0; j < variantChild.length; j++) {
          if (variantChild[j].quantity > 0) {
            totalVariant += (variantChild[j].quantity *
                double.parse(variantChild[j].price));
          }
        }
      }
    }
    return totalVariant;
  }

  bool isUsedVariant(List<VariantChild> data) {
    for (int j = 0; j < data.length; j++) {
      if (data[j].quantity > 0) return true;
    }
    return false;
  }

  String getGroupName(groupName) {
    try {
      return groupName.split('\-')[1];
    } catch (e) {
      return groupName;
    }
  }

  Widget printMenu(context) {
    return new PopupMenuButton(
      icon: Image.asset('drawable/printer.png'),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('receipt',
            '${AppLocalizations.of(context).translate('print_receipt')}', true),
        _buildMenuItem('pdf',
            '${AppLocalizations.of(context).translate('print_pdf')}', true),
      ],
      onCanceled: () {},
      onSelected: (value) {
        if (value == 'receipt')
          openPrintDialog(context);
        else
          printInvoice();
      },
    );
  }

  /*
  *
  *  whatsApp menu
  * */
  Widget whatsAppMenu(context) {
    return new PopupMenuButton(
      icon: Image.asset('drawable/whatsapp.png'),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('message',
            '${AppLocalizations.of(context).translate('send_message')}', true),
        _buildMenuItem('confirm',
            '${AppLocalizations.of(context).translate('confirm_order')}', true),
        _buildMenuItem('receipt',
            '${AppLocalizations.of(context).translate('send_receipt')}', true),
      ],
      onCanceled: () {},
      onSelected: (value) {
        switch (value) {
          case 'message':
            openWhatsApp(1);
            break;
          case 'confirm':
            openWhatsApp(0);
            break;
          case 'receipt':
            openWhatsApp(2);
            break;
        }
      },
    );
  }

  String getPaymentMethod(paymentMethod) {
    if (paymentMethod == '0')
      return AppLocalizations.of(context).translate('bank_transfer');
    else if (paymentMethod == '1')
      return AppLocalizations.of(context).translate('cash_on_delivery');
    else if (paymentMethod == '2')
      return 'Fpay Amount Received RM ${order.fpayReceiveAmount != '' ? order.fpayReceiveAmount : '-'}';
    else if (paymentMethod == '3')
      return 'Touch \'n Go E-Wallet';
    else if (paymentMethod == '4')
      return 'Boost E-Wallet';
    else if (paymentMethod == '5')
      return 'DuitNow QR';
    else
      return 'Sarawak Pay';
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
        _buildMenuItem('group',
            '${AppLocalizations.of(context).translate('assign_group')}', true),
        _buildMenuItem('status',
            '${AppLocalizations.of(context).translate('change_status')}', true),
        _buildMenuItem(
            'payment_status',
            '${AppLocalizations.of(context).translate('change_payment_status')}',
            true),
        _buildMenuItem('driver',
            '${AppLocalizations.of(context).translate('assign_driver')}', true),
        _buildMenuItem('delete',
            '${AppLocalizations.of(context).translate('delete_order')}', true)
      ],
      onCanceled: () {},
      onSelected: (value) {
        switch (value) {
          case 'group':
            showGroupingDialog(context);
            break;
          case 'status':
            showStatusDialog(context);
            break;
          case 'payment_status':
            showPaymentStatusDialog(context);
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

  /*
  *
  *  edit customer details menu
  * */
  Widget editCustomerDetailMenu(context) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.edit,
        color: Colors.grey,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        _buildMenuItem('name',
            '${AppLocalizations.of(context).translate('edit_name')}', true),
        _buildMenuItem(
            'address',
            '${AppLocalizations.of(context).translate('edit_address')}',
            order.selfCollect == 1),
      ],
      onCanceled: () {},
      onSelected: (value) {
        if (value == 'name')
          showEditNameDialog(context);
        else
          showEditAddressDialog(context);
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
  * edit calculate current time for date picker
  * */
  checkCurrentTimeForDatePicker() {
    try {
      var date, time;
      var now = new DateTime.now();

      if (order.deliveryDate != '') {
        date = order.deliveryDate.split("\-");
      }

      if (order.deliveryTime != '') {
        time = order.deliveryTime.split("\:");
      }

      showDatePicker(DateTime(
          date != null ? int.parse(date[0]) : now.year,
          date != null ? int.parse(date[1]) : now.month,
          date != null ? int.parse(date[2]) : now.day,
          time != null ? int.parse(time[0]) : now.hour,
          time != null ? int.parse(time[1]) : now.minute));
    } catch (e) {
      showDatePicker(null);
    }
  }

  showDatePicker(DateTime date) {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        currentTime: date,
        onChanged: (date) {}, onConfirm: (date) async {
      String selectedDate = DateFormat("yyyy-MM-dd").format(date);
      String selectedTime = DateFormat("hh:mm").format(date);

      Map data = await Domain()
          .updateDeliveryDate(selectedDate, selectedTime, order.id.toString());
      if (data['status'] == '1') {
        showSnackBar(
            '${AppLocalizations.of(context).translate('update_success')}');
        setState(() {
          orderItems.clear();
        });
      } else {
        showSnackBar(
            "${AppLocalizations.of(context).translate('something_went_wrong')}");
      }
    });
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
              "${AppLocalizations.of(context).translate('delete_request')}"),
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
                Map data = await Domain().deleteOrder(widget.id.toString());
                if (data['status'] == '1') {
                  widget.refresh();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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

            if (data['status'] == '1') {
              showSnackBar(
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              setState(() {
                orderItems.clear();
              });
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
              showSnackBar(
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              setState(() {
                orderItems.clear();
              });
            } else {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            }
          },
        );
      },
    );
  }

  /*
  * update merchant note / remark
  * */
  showCustomerNoteDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditRemarkDialog(
            order: order,
            onClick: (note) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data =
                  await Domain().updateCustomerNote(note, order.id.toString());
              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
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
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                  order.status = value;
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
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
            paymentStatus: order.paymentStatus,
            onClick: (value) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain()
                  .updatePaymentStatus(value, order.id.toString());

              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                  order.status = value;
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * update phone number
  * */
  showEditNameDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditNameDialog(
            order: order,
            onClick: (name) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain().updateName(name, order.id.toString());
              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                  order.name = name;
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * update phone number
  * */
  showEditPhoneDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditPhoneDialog(
            order: order,
            onClick: (phone) async {
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(mainContext);
              Map data = await Domain().updatePhone(phone, order.id.toString());

              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                  order.phone = phone;
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * edit product dialog
  * */
  deleteOrderItem(mainContext, OrderItem orderItem, int position) {
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
                orderItems.removeAt(position);

                Map data = await Domain().deleteOrderItem(
                    orderItem.orderProductId.toString(),
                    order.id.toString(),
                    countProductTotal(),
                    calculateStock(orderItem),
                    orderItem.productId.toString());

                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('delete_success')}');
                  setState(() {
                    orderItems.clear();
                  });
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

  calculateStock(OrderItem item) {
    if (item.stock != '') {
      try {
        int currentStock = int.parse(item.stock) + int.parse(item.quantity);
        return currentStock.toString();
      } catch (e) {
        return 0;
      }
    } else
      return '';
  }

  /*
  * edit product dialog
  * */
  deleteCoupon(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              AppLocalizations.of(mainContext).translate('delete_request')),
          content: Text(
              '${AppLocalizations.of(mainContext).translate('remove_coupon')}'),
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
                Map data =
                    await Domain().removeCouponFromOrder(order.couponUsageId);
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  CustomSnackBar.show(mainContext,
                      '${AppLocalizations.of(mainContext).translate('delete_success')}');
                  setState(() {
                    orderItems.clear();
                  });
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

  /*
  * edit shipping tax dialog
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
              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * edit discount dialog
  * */
  showEditDiscountDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditDiscountDialog(
            order: order,
            onClick: (order) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);

              Map data = await Domain().updateDiscount(order);
              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * edit discount dialog
  * */
  showEditCouponDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return EditCouponDialog(
            order: order,
            totalQuantity: totalQuantity,
            applyCoupon: (Coupon coupon, discountAmount) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);
              Map data =
                  await Domain().applyCoupon(coupon, discountAmount, widget.id);

              if (data['status'] == '1') {
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('apply_success')}');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  /*
  * add product dialog
  * */
  showAddProductDialog(mainContext, OrderItem orderItem, position) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AddProductDialog(
          orderItem: orderItem,
          isUpdate: orderItem != null,
          formId: order.formId.toString(),
          /*
          *
          * add order product
          *
          * */
          addProduct:
              (Product product, OrderItem orderItem, quantity, remark) async {
            //delay timer
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.pop(mainContext);
            //add order item (for calculate total amount purpose)
            orderItems.add(orderItem);

            Map data = await Domain().addOrderItem(product, order.id.toString(),
                quantity, remark, countProductTotal());

            if (data['status'] == '1') {
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('add_success')}');
              setState(() {
                orderItems.clear();
              });
            } else
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
          },
          /*
          *
          * edit order product
          *
          * */
          editProduct: (OrderItem object, stock) async {
            //delay timer
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.pop(mainContext);
            //update current order item list
            orderItems[position] = object;
            //update db
            Map data = await Domain()
                .updateOrderItem(object, order.id, countProductTotal(), stock);

            if (data['status'] == '1') {
              showSnackBar(
                  '${AppLocalizations.of(mainContext).translate('update_success')}');
              setState(() {
                orderItems.clear();
              });
            } else
              CustomSnackBar.show(mainContext,
                  '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
          },
        );
      },
    );
  }

  countProductTotal() {
    var productTotal = 0.00;
    //loop all order item
    for (int i = 0; i < orderItems.length; i++) {
      var variationTotal = 0.00;
      //for calculate variation total purpose
      try {
        String variation = orderItems[i].variation;
        if (variation != '') {
          //convert variant from string to list
          List<VariantGroup> variant = [];
          List data = jsonDecode(variation);
          variant.addAll(data
              .map((jsonObject) => VariantGroup.fromJson(jsonObject))
              .toList());

          //loop all the variant and calculate variant total
          for (int j = 0; j < variant.length; j++) {
            List<VariantChild> variantChild = variant[j].variantChild;
            for (int k = 0; k < variantChild.length; k++) {
              variationTotal += (variantChild[k].quantity *
                  double.parse(variantChild[k].price));
            }
          }
        }
      } catch ($e) {
        variationTotal = 0.00;
      }
      productTotal += (double.parse(orderItems[i].price) + variationTotal) *
          int.parse(orderItems[i].quantity);
    }
    return productTotal.toStringAsFixed(2);
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
                showSnackBar(
                    '${AppLocalizations.of(mainContext).translate('update_success')}');
                setState(() {
                  orderItems.clear();
                });
              } else
                CustomSnackBar.show(mainContext,
                    '${AppLocalizations.of(mainContext).translate('something_went_wrong')}');
            });
      },
    );
  }

  openWhatsApp(int messageType) async {
    String message = '';
    if (messageType == 0) {
      message =
          'Hi,%20*${order.name.replaceAll(' ', '%20')}*%0aWe%20have%20received%20your%20order.%0a*Order%20No.${Order().whatsAppOrderPrefix(widget.orderId)}*%0a%0aPlease%20Check%20Your%20Order%20Here:%0a${Domain.whatsAppLink}?id=${order.publicUrl}';
    }
    //send receipt
    else if (messageType == 2) {
      message = '${Domain.whatsAppLink}?id=${order.publicUrl}';
    }

    Order().openWhatsApp(
        '+' + Order.getPhoneNumber(order.phone), message, context);
  }

  openMapsSheet(context) async {
    try {
      final query =
          '${order.address + ' ' + order.postcode + ' ' + order.city}';
      String apiKey = await SharePreferences().read('google_api_key');

      var addresses =
          await Geocoder.google(apiKey).findAddressesFromQuery(query);
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
      showSnackBar(
          '${AppLocalizations.of(context).translate('invalid_address')}');
    }
  }

  openPrintDialog(mainContext) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return PrintDialog(
          orderId: widget.id,
        );
      },
    );
  }

  printInvoice() {
    try {
      launch('${Domain.invoiceLink}${order.publicUrl}');
    } catch ($e) {
      showSnackBar(AppLocalizations.of(context).translate('invalid_file'));
    }
  }

  preChecking() async {
    //check discount features
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('allow_discount') == null ||
        prefs.getString('allow_discount') == '1') {
      discountEnable = false;
    } else
      discountEnable = true;

    //check allow take photo
    if (prefs.getString('allow_take_photo') == null ||
        prefs.getString('allow_take_photo') == '1') {
      allowTakePhoto = false;
    } else
      allowTakePhoto = true;

    setState(() {});
  }

  showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
    ));
  }
}
