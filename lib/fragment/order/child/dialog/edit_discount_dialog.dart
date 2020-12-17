import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my/object/discount.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class EditDiscountDialog extends StatefulWidget {
  final Function(Order) onClick;
  final Order order;
  final int totalQuantity;

  EditDiscountDialog({this.onClick, this.order, this.totalQuantity});

  @override
  _EditDiscountDialogState createState() => _EditDiscountDialogState();
}

class _EditDiscountDialogState extends State<EditDiscountDialog> {
  var couponCode = TextEditingController();
  var totalDiscountAmount = TextEditingController();

  Order object;

  //start and end date
  var startDate, endDate;

  //condition amount
  int usageLimit, usageLimitPerUser;

  //0 = reach certain amount, 1 = reach certain quantity
  int discountCondition = 0;
  double conditionAmount;

  //0 = fixed cart, 1 = percentage
  int discountType = 0;

  double discountAmount;

  final selectedDateFormat = DateFormat("yyy-MM-dd hh:mm");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    couponCode.text = widget.order.couponCode;
    totalDiscountAmount.text = widget.order.discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          '${AppLocalizations.of(context).translate('apply_discount')}'),
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
          onPressed: () {},
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                    keyboardType: TextInputType.text,
                    controller: couponCode,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                        labelText:
                            '${AppLocalizations.of(context).translate('coupon_code')}',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.blueGrey),
                        hintStyle: TextStyle(fontSize: 14),
                        hintText:
                            '${AppLocalizations.of(context).translate('code')}')),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: RaisedButton(
                      onPressed: () {
                        if (couponCode.toString().isNotEmpty)
                          fetchCouponDetail(context);
                        else
                          CustomToast(
                                  '${AppLocalizations.of(context).translate('invalid_input')}',
                                  context,
                                  gravity: Toast.BOTTOM)
                              .show();
                      },
                      elevation: 5,
                      color: Colors.orangeAccent,
                      child: Text(
                        '${AppLocalizations.of(context).translate('apply')}',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                ],
                controller: totalDiscountAmount,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText:
                      '${AppLocalizations.of(context).translate('discount_amount')}',
                  labelStyle: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  hintText: '0.00',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
          ),
        ],
      ),
    );
  }

  Future fetchCouponDetail(context) async {
    Map data =
        await Domain().fetchDiscountByCode(couponCode.text, widget.order.phone);
    if (data['status'] == '1') {
      try {
        Coupon coupon = Coupon.fromJson(data['coupon'][0]);
        var discountType = jsonDecode(coupon.discountType);
        this.discountType = int.parse(discountType['type']);
        discountAmount = double.parse(discountType['rate']);

        startDate = coupon.startDate.isNotEmpty
            ? DateTime.parse(coupon.startDate)
            : null;
        endDate =
            coupon.endDate.isNotEmpty ? DateTime.parse(coupon.endDate) : null;

        var discountCondition = jsonDecode(coupon.discountCondition);
        this.discountCondition = int.parse(discountCondition['type']);
        this.conditionAmount = double.parse(discountCondition['condition']);

        usageLimit = int.parse(coupon.usageLimit.toString());
        usageLimitPerUser = int.parse(coupon.usageLimitPerUser.toString());

        print('checking: ${checkingCoupon()}');
      } on Exception {
        CustomToast(
                '${AppLocalizations.of(context).translate('something_went_wrong')}',
                context)
            .show();
      }
    } else {
      CustomToast(
              '${AppLocalizations.of(context).translate('something_went_wrong')}',
              context)
          .show();
    }
    setState(() {});
  }

  bool checkingCoupon() {
    /*
    * date checking
    * */
    if (startDate != null && endDate != null) {
      DateTime now = DateTime.now();
      if (now.isBefore(startDate) || now.isAfter(endDate)) {
        showToast('invalid_time');
        return false;
      }
    }
    /*
    * discount condition
    * */
    var currentAmountOrQuantity = (discountCondition == 0 ? widget.order.total : widget.totalQuantity);
    if (currentAmountOrQuantity < conditionAmount) {
      showToast('invalid_coupon');
      return false;
    }

    return true;
  }

  showToast(message) {
    CustomToast('${AppLocalizations.of(context).translate(message)}', context)
        .show();
  }
}
