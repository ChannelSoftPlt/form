import 'dart:convert';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';

class ReceiptLayout {
  String orderId;
  Merchant merchant;
  Order order;
  List<OrderItem> orderItems = [];
  String url = '';

  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("hh:mm");

  ReceiptLayout(this.orderId);

  Future<Ticket> ticket(PaperSize paper) async {
    try {
      await fetchPrintData();
      await getUrl();
      return paper == PaperSize.mm58 ? get58mmTicket() : get80mmTicket();
    } catch ($e) {
      print($e);
      return null;
    }
  }

  Future<Ticket> testing() async {
    final profile = await CapabilityProfile.load();
    final Ticket ticket = Ticket(PaperSize.mm58, profile);

    for (int i = 0; i < orderItems.length; i++) {
      ticket.reset();
      ticket.row([
        PosColumn(
            text: orderItems[i].name,
            width: 9,
            containsChinese: true,
            styles: PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: 'x ${orderItems[i].quantity}',
            width: 3,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      /*
      * product add on
      * */
      var variation = orderItems[i].variation;
      List<VariantGroup> variant = [];

      if (variation != '') {
        List data = jsonDecode(variation);
        variant.addAll(data
            .map((jsonObject) => VariantGroup.fromJson(jsonObject))
            .toList());

        for (int i = 0; i < variant.length; i++) {
          if (isUsedVariant(variant[i].variantChild)) {
            for (int j = 0; j < variant[i].variantChild.length; j++) {
              if (variant[i].variantChild[j].quantity > 0) {
                ticket.reset();
                ticket.row([
                  PosColumn(
                    text: '-${variant[i].variantChild[j].name}',
                    width: 10,
                    containsChinese: true,
                  ),
                  PosColumn(
                      text: '',
                      width: 2,
                      styles: PosStyles(align: PosAlign.right)),
                ]);
              }
            }
          }
        }
      }
      //product remark
      ticket.reset();
      if (orderItems[i].remark != '') {
        ticket.row([
          PosColumn(
              text: '**${orderItems[i].remark}',
              width: 10,
              containsChinese: true),
          PosColumn(
              text: '', width: 2, styles: PosStyles(align: PosAlign.right)),
        ]);
      }
      //product price
      ticket.reset();
      ticket.text(
          calEachTotal(orderItems[i].price, orderItems[i].quantity,
              orderItems[i].variation),
          styles: PosStyles(align: PosAlign.right));

      ticket.feed(1);
    }
    ticket.cut();
    return ticket;
  }

  Future<Ticket> get80mmTicket() async {
    try {
      final profile = await CapabilityProfile.load();
      final Ticket ticket = Ticket(PaperSize.mm80, profile);
      /*
      * header
      * */
      ticket.text(merchant.companyName,
          containsChinese: true,
          styles: PosStyles(
              bold: true,
              align: PosAlign.center,
              width: PosTextSize.size2,
              height: PosTextSize.size2));

      ticket.feed(1);

      //address
      ticket.text(merchant.address,
          containsChinese: true, styles: PosStyles(align: PosAlign.center));
      //telephone
      ticket.text('Tel: ${merchant.phone}',
          styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1));
      //cash
      ticket.hr();
      ticket.text('CASH', styles: PosStyles(align: PosAlign.left));
      ticket.hr();
      //receipt & date
      ticket.row([
        PosColumn(text: 'RECEIPT: ', width: 3),
        PosColumn(
            text: '${Order().orderPrefix(order.orderID)}',
            width: 4,
            styles: PosStyles(align: PosAlign.left)),
        PosColumn(text: 'DATE: ', width: 2),
        PosColumn(
            text: '${formatDate(order.date, 'date')}',
            width: 3,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      //admin & time
      ticket.row([
        PosColumn(text: 'CASHIER: ', width: 3),
        PosColumn(
            text: 'ADMIN', width: 4, styles: PosStyles(align: PosAlign.left)),
        PosColumn(text: 'TIME: ', width: 2),
        PosColumn(
            text: '${formatDate(order.date, 'time')}',
            width: 3,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      /*
    *
    * body
    *
    * */
      ticket.hr();
      ticket.row([
        PosColumn(text: 'ITEM', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: 'QTY ',
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right)),
        PosColumn(
            text: 'AMOUNT',
            width: 4,
            styles: PosStyles(bold: true, align: PosAlign.right)),
      ]);
      ticket.hr();
      /*
    * product row
    * */
      for (int i = 0; i < orderItems.length; i++) {
        ticket.row([
          PosColumn(
              text: '${orderItems[i].name}',
              width: 6,
              containsChinese: true,
              styles: PosStyles(align: PosAlign.left)),
          PosColumn(
              text: '${orderItems[i].quantity} ',
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: calEachTotal(orderItems[i].price, orderItems[i].quantity,
                  orderItems[i].variation),
              width: 4,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        /*
      * product add on
      * */
        var variation = orderItems[i].variation;
        List<VariantGroup> variant = [];

        if (variation != '') {
          List data = jsonDecode(variation);
          variant.addAll(data
              .map((jsonObject) => VariantGroup.fromJson(jsonObject))
              .toList());

          for (int i = 0; i < variant.length; i++) {
            if (isUsedVariant(variant[i].variantChild)) {
              for (int j = 0; j < variant[i].variantChild.length; j++) {
                if (variant[i].variantChild[j].quantity > 0) {
                  ticket.row([
                    PosColumn(
                        text: '-${variant[i].variantChild[j].name}',
                        width: 6,
                        containsChinese: true),
                    PosColumn(
                        text: '',
                        width: 2,
                        styles: PosStyles(align: PosAlign.right)),
                    PosColumn(
                        text: '',
                        width: 4,
                        styles: PosStyles(align: PosAlign.right)),
                  ]);
                }
              }
            }
          }
        }
        /*
        * product remark
        * */
        ticket.reset();
        if (orderItems[i].remark != '') {
          ticket.row([
            PosColumn(
                text: '**${orderItems[i].remark}',
                width: 6,
                containsChinese: true),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.right)),
            PosColumn(
                text: '', width: 4, styles: PosStyles(align: PosAlign.right)),
          ]);
        }
        ticket.feed(1);
      }
      ticket.hr();
      //subtotal
      ticket.row([
        PosColumn(
            text: 'SubTotal',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '${order.total.toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //delivery fee
      ticket.row([
        PosColumn(
            text: 'Delivery Fee',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '${Order().convertToInt(order.deliveryFee).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //discount fee
      ticket.row([
        PosColumn(
            text: 'Discount Fee',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '-${Order().convertToInt(order.discountAmount).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //coupon fee
      ticket.row([
        PosColumn(
            text: 'Coupon Discount',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '-${Order().convertToInt(order.couponDiscount).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //tax
      ticket.row([
        PosColumn(
            text: 'Service Tax',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '${Order().convertToInt(order.tax).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      ticket.hr();
      ticket.row([
        PosColumn(
            text: 'Total',
            width: 8,
            styles: PosStyles(
                align: PosAlign.right, height: PosTextSize.size2, bold: true)),
        PosColumn(
            text: '${Order().countTotal(order).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(
                align: PosAlign.right, height: PosTextSize.size2, bold: true)),
      ]);
      ticket.hr();
      /*
    * footer
    * */
      ticket.reset();
      ticket.row([
        PosColumn(
            text: 'Payment Method: ',
            width: 8,
            styles: PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
            text: getPaymentMethod(order.paymentMethod),
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);

      ticket.feed(1);

      //note
      if (order.note != '') {
        ticket.reset();
        ticket.text('Special Note:',
            styles: PosStyles(align: PosAlign.left, bold: true));

        ticket.reset();
        ticket.text(order.note,
            containsChinese: true, styles: PosStyles(align: PosAlign.left));

        ticket.feed(1);
      }

      ticket.text('Scan here to visit our store',
          styles:
              PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));
      //qr code
      ticket.qrcode(url, align: PosAlign.center, size: QRSize.Size6);

      ticket.feed(1);

      ticket.text('POWERED BY E-MENU',
          styles:
              PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));

      ticket.feed(2);
      ticket.cut();
      return ticket;
    } catch ($e) {
      print($e);
      return null;
    }
  }

  Future<Ticket> get58mmTicket() async {
    try {
      final profile = await CapabilityProfile.load();
      final Ticket ticket = Ticket(PaperSize.mm58, profile);
      /*
      * header
      * */
      ticket.text(merchant.companyName,
          containsChinese: true,
          styles: PosStyles(
              bold: true,
              align: PosAlign.center,
              width: PosTextSize.size2,
              height: PosTextSize.size2));

      ticket.reset();

      //address
      ticket.text(merchant.address,
          containsChinese: true,
          styles: PosStyles(
            align: PosAlign.center,
          ));

      ticket.reset();

      //telephone
      ticket.text('Tel: ${merchant.phone}',
          styles: PosStyles(align: PosAlign.center));

      //cash
      ticket.hr();
      ticket.text('CASH', styles: PosStyles(align: PosAlign.left));
      ticket.hr();

      //receipt & date
      ticket.row([
        PosColumn(text: 'RECEIPT:  ', width: 4),
        PosColumn(
            text: '${Order().orderPrefix(order.orderID)}',
            width: 8,
            styles: PosStyles(align: PosAlign.left))
      ]);
      //admin & time
      ticket.row([
        PosColumn(text: 'CASHIER:  ', width: 4),
        PosColumn(
            text: 'ADMIN', width: 8, styles: PosStyles(align: PosAlign.left)),
      ]);
      //admin & time
      ticket.row([
        PosColumn(text: 'DATE: ', width: 4),
        PosColumn(
            text:
                '${formatDate(order.date, 'date')} ${formatDate(order.date, 'time')}',
            width: 8,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      /*
    *
    * body
    *
    * */
      ticket.hr();
      ticket.row([
        PosColumn(
            text: 'ITEM',
            width: 10,
            styles: PosStyles(bold: true, align: PosAlign.left)),
        PosColumn(
            text: 'QTY ',
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right)),
      ]);
      ticket.hr();
      /*
    * product row
    * */
      for (int i = 0; i < orderItems.length; i++) {
        ticket.reset();
        ticket.row([
          PosColumn(
              text: orderItems[i].name,
              width: 9,
              containsChinese: true,
              styles: PosStyles(align: PosAlign.left, bold: true)),
          PosColumn(
              text: 'x ${orderItems[i].quantity}',
              width: 3,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        /*
      * product add on
      * */
        var variation = orderItems[i].variation;
        List<VariantGroup> variant = [];

        if (variation != '') {
          List data = jsonDecode(variation);
          variant.addAll(data
              .map((jsonObject) => VariantGroup.fromJson(jsonObject))
              .toList());

          for (int i = 0; i < variant.length; i++) {
            if (isUsedVariant(variant[i].variantChild)) {
              for (int j = 0; j < variant[i].variantChild.length; j++) {
                if (variant[i].variantChild[j].quantity > 0) {
                  ticket.reset();
                  ticket.row([
                    PosColumn(
                      text: '-${variant[i].variantChild[j].name}',
                      width: 9,
                      containsChinese: true,
                    ),
                    PosColumn(
                        text: '',
                        width: 3,
                        styles: PosStyles(align: PosAlign.right)),
                  ]);
                }
              }
            }
          }
        }
        //product remark
        ticket.reset();
        if (orderItems[i].remark != '') {
          ticket.row([
            PosColumn(
                text: '**${orderItems[i].remark}',
                width: 9,
                containsChinese: true),
            PosColumn(
                text: '', width: 3, styles: PosStyles(align: PosAlign.right)),
          ]);
        }
        //product price
        ticket.reset();
        ticket.text(
            calEachTotal(orderItems[i].price, orderItems[i].quantity,
                orderItems[i].variation),
            styles: PosStyles(align: PosAlign.right));
        ticket.feed(1);
      }
      ticket.hr();
      ticket.reset();
//      //subtotal
      ticket.row([
        PosColumn(
            text: 'SubTotal',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '${order.total.toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //delivery fee
      ticket.row([
        PosColumn(
            text: 'Delivery Fee',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '${Order().convertToInt(order.deliveryFee).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //discount fee
      ticket.row([
        PosColumn(
            text: 'Discount Fee',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '-${Order().convertToInt(order.discountAmount).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
//      //coupon fee
      ticket.row([
        PosColumn(
            text: 'Coupon Discount',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text:
                '-${Order().convertToInt(order.couponDiscount).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      //tax
      ticket.row([
        PosColumn(
            text: 'Service Tax',
            width: 8,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: '${Order().convertToInt(order.tax).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      ticket.hr();
      ticket.row([
        PosColumn(
            text: 'Total',
            width: 8,
            styles: PosStyles(
                align: PosAlign.right, height: PosTextSize.size2, bold: true)),
        PosColumn(
            text: '${Order().countTotal(order).toStringAsFixed(2)}',
            width: 4,
            styles: PosStyles(
                align: PosAlign.right, height: PosTextSize.size2, bold: true)),
      ]);
      ticket.hr();
      //payment method
      ticket.reset();
      ticket.row([
        PosColumn(
            text: 'Payment Method: ',
            width: 6,
            styles: PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: getPaymentMethod(order.paymentMethod),
            width: 6,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      /*
    * footer
    * */
      if (order.note != '') {
        ticket.reset();
        ticket.text('Special Note:',
            styles: PosStyles(align: PosAlign.left, bold: true));

        ticket.reset();
        ticket.text(order.note,
            containsChinese: true, styles: PosStyles(align: PosAlign.left));
        ticket.feed(1);
      }

      ticket.reset();
      ticket.text('Scan here to visit our store',
          styles:
              PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));
      ticket.feed(1);

      //qr code
      ticket.reset();
      ticket.qrcode(url, align: PosAlign.center, size: QRSize.Size6);
      ticket.feed(1);

      ticket.reset();
      ticket.text('POWERED BY E-MENU',
          styles:
              PosStyles(align: PosAlign.center, fontType: PosFontType.fontB));

      ticket.cut();
      return ticket;
    } catch ($e) {
      print($e);
      return null;
    }
  }

  String getPaymentMethod(paymentMethod) {
    if (paymentMethod == '0')
      return 'Bank Transfer';
    else if (paymentMethod == '1')
      return 'Cash On Delivery';
    else if (paymentMethod == '2')
      return 'Fpay';
    else if (paymentMethod == '3')
      return 'Touch \'n Go';
    else if (paymentMethod == '4')
      return 'Boost E-Wallet';
    else if (paymentMethod == '5')
      return 'DuitNow QR';
    else
      return 'Sarawak Pay';
  }

  bool isUsedVariant(List<VariantChild> data) {
    for (int j = 0; j < data.length; j++) {
      if (data[j].quantity > 0) return true;
    }
    return false;
  }

  calEachTotal(price, quantity, variation) {
    return ((Order().convertToInt(price) + countVariantTotal(variation)) *
            Order().convertToInt(quantity))
        .toStringAsFixed(2);
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

  String formatDate(date, type) {
    try {
      DateTime todayDate = DateTime.parse(date);
      if (type == 'date')
        return dateFormat.format(todayDate).toString();
      else
        return timeFormat.format(todayDate).toString();
    } catch (e) {
      return '';
    }
  }

  getUrl() async {
    this.url = await SharePreferences().read('url');
  }

  fetchPrintData() async {
    Map data = await Domain().fetchPrintData(orderId);
    if (data['status'] == '1') {
      merchant = Merchant.fromJson(data['merchant'][0]);
      order = Order.fromJson(data['order'][0]);

      List orderItem = data['order_item'];
      orderItems.addAll(orderItem
          .map((jsonObject) => OrderItem.fromJson(jsonObject))
          .toList());
    }
  }
}
