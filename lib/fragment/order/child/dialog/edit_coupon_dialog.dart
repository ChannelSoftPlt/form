import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my/object/coupon.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class EditCouponDialog extends StatefulWidget {
  final Function(Coupon coupon, String discountAmount) applyCoupon;
  final Order order;
  final int totalQuantity;

  EditCouponDialog({this.applyCoupon, this.order, this.totalQuantity});

  @override
  _EditCouponDialogState createState() => _EditCouponDialogState();
}

class _EditCouponDialogState extends State<EditCouponDialog> {
  var couponCode = TextEditingController();

  Coupon coupon;

  //start and end date
  var startDate, endDate;

  //condition amount
  int usageLimit, usageLimitPerUser;
  int couponUsed, couponUsedByUser;

  //0 = reach certain amount, 1 = reach certain quantity
  int discountCondition = 0;
  double conditionAmount;

  //0 = fixed cart, 1 = percentage
  int discountType = 0;

  double discountAmount;
  double maxDiscountAmount;

  final selectedDateFormat = DateFormat("yyy-MM-dd hh:mm");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    couponCode.text = widget.order.couponCode;
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
            '${AppLocalizations.of(context).translate('apply')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            applyCoupon(context);
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: TextField(
                keyboardType: TextInputType.text,
                controller: couponCode,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText:
                  '${AppLocalizations.of(context).translate('coupon_code')}',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  hintStyle: TextStyle(fontSize: 14),
                  hintText: '${AppLocalizations.of(context).translate('code')}',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                )),
          ),
        ],
      ),
    );
  }

  Future applyCoupon(context) async {
    Map data =
    await Domain().fetchDiscountByCode(couponCode.text, widget.order.phone);
    print(data);
    if (data['status'] == '1') {
      try {
        coupon = Coupon.fromJson(data['coupon'][0]);
        var discountType = jsonDecode(coupon.discountType);
        this.discountType = int.parse(discountType['type']);
        this.discountAmount = double.parse(discountType['rate']);
        this.maxDiscountAmount = double.parse(discountType['max_rate']);

        startDate = coupon.startDate.isNotEmpty
            ? DateTime.parse(coupon.startDate)
            : null;

        endDate =
        coupon.endDate.isNotEmpty ? DateTime.parse(coupon.endDate) : null;

        var discountCondition = jsonDecode(coupon.discountCondition);
        this.discountCondition = int.parse(discountCondition['type']);
        this.conditionAmount = double.parse(discountCondition['condition']);

        usageLimit = coupon.usageLimit;
        usageLimitPerUser = coupon.usageLimitPerUser;
        couponUsed = coupon.couponUsed;
        couponUsedByUser = coupon.couponUsedByUser;

        applyDiscount();
      } on Exception {
        CustomToast(
            '${AppLocalizations.of(context).translate('something_went_wrong')}',
            context)
            .show();
      }
    } else if (data['status'] == '2') {
      CustomToast('${AppLocalizations.of(context).translate('invalid_coupon')}',
          context)
          .show();
    } else {
      CustomToast(
          '${AppLocalizations.of(context).translate('something_went_wrong')}',
          context)
          .show();
    }
  }

  applyDiscount() {
    if (isValidCoupon()) {
      var totalDiscountAmount = discountAmount;
      if (discountType == 1) {
        totalDiscountAmount = widget.order.total * discountAmount / 100;
        //check any maximum discount or not
        if(maxDiscountAmount != -1){
          //if exceed maximum discount
          if(totalDiscountAmount > maxDiscountAmount)
            totalDiscountAmount = maxDiscountAmount;
        }
      }
      widget.applyCoupon(coupon, totalDiscountAmount.toString());
    }
  }

  isValidCoupon() {
    /*
    * start date checking
    * */
    DateTime now = DateTime.now();
    if (startDate != null) {
      if (now.isBefore(startDate)) {
        showToast('invalid_time');
        return false;
      }
    }
    /*
    * end date checking
    *  */
    if (endDate != null) {
      if (now.isAfter(endDate)) {
        showToast('invalid_time');
        return false;
      }
    }

    /*
    * discount condition
    * */
    var currentAmountOrQuantity = (discountCondition == 0
        ? widget.order.total
        : widget.totalQuantity);
    if (currentAmountOrQuantity < conditionAmount) {
      showToast('invalid_condition');
      return false;
    }
    /*
    * usage limit
    * */
    if (usageLimit != -1 && couponUsed >= usageLimit) {
      showToast('redemption_limit');
      return false;
    }
    /*
    * usage limit by user
    * */
    if (usageLimitPerUser != -1 && couponUsedByUser >= usageLimitPerUser) {
      showToast('redemption_limit');
      return false;
    }
    return true;
  }

  showToast(message) {
    CustomToast('${AppLocalizations.of(context).translate(message)}', context)
        .show();
  }
}
