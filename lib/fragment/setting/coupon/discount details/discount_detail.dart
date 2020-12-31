import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my/object/coupon.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/toast.dart';

import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class DiscountDetail extends StatefulWidget {
  final bool isUpdate;
  final couponId;

  DiscountDetail({this.isUpdate, this.couponId}) : assert(isUpdate != null);

  @override
  _DiscountDetailState createState() => _DiscountDetailState();
}

class _DiscountDetailState extends State<DiscountDetail> {
  var couponCode = TextEditingController();
  var couponDescription = TextEditingController();
  var discountAmount = TextEditingController();
  var maxDiscountAmount = TextEditingController();
  var conditionAmount = TextEditingController();
  var usageLimit = TextEditingController();
  var usageLimitUser = TextEditingController();

  //0 = fixed cart, 1 = percentage
  int discountType = 0;

  //start and end date
  var startDate, endDate;
  final selectedDateFormat = DateFormat("yyy-MM-dd hh:mm");

  //0 = reach certain amount, 1 = reach certain quantity
  int discountCondition = 0;

  bool couponCodeValidate = false;
  bool discountAmountValidate = false;

  StreamController freshStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    freshStream = StreamController();
    if (widget.isUpdate) {
      fetchCouponDetail(context);
    } else
      freshStream.add('display');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate(widget.isUpdate ? 'update_coupon' : 'create_coupon')}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
          actions: [
            Visibility(
              visible: widget.isUpdate,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  deleteCoupon(context);
                  // do something
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext innerContext) {
          return StreamBuilder(
              stream: freshStream.stream,
              builder: (context, object) {
                if (object.hasData && object.data.toString().length >= 1) {
                  return mainContent(innerContext);
                }
                return CustomProgressBar();
              });
        }));
  }

  Widget mainContent(context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                generalLayout(),
                SizedBox(
                  height: 10,
                ),
                restrictionLayout(),
                SizedBox(
                  height: 10,
                ),
                usageLayout(),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 5,
                      onPressed: () {
                        checkingInput(context);
                      },
                      child: Text(
                        '${AppLocalizations.of(context).translate(widget.isUpdate ? 'update_coupon' : 'create_discount')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget generalLayout() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            '${AppLocalizations.of(context).translate('coupon_general_setting')}',
                        style: TextStyle(
                            color: Color.fromRGBO(89, 100, 109, 1),
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: '\n'),
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context).translate('coupon_general_setting_description')}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Theme(
              data: new ThemeData(
                primaryColor: Colors.orange,
              ),
              child: TextField(
                controller: couponCode,
                textAlign: TextAlign.start,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  errorText: couponCodeValidate
                      ? '${AppLocalizations.of(context).translate('invalid_code')}'
                      : null,
                  prefixIcon: Icon(Icons.local_offer),
                  labelText:
                      '${AppLocalizations.of(context).translate('coupon_code')}',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('coupon_code')}',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                      '${AppLocalizations.of(context).translate('discount_type')}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(89, 100, 109, 1))),
                ),
                Expanded(
                  flex: 3,
                  child: DropdownButton(
                      value: discountType,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      items: [
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('fix_cart_discount')),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('percentage_discount')),
                          value: 1,
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          discountAmount.clear();
                          discountType = value;
                        });
                      }),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.orange,
                    ),
                    child: TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r"^\d*\.?\d*")),
                      ],
                      controller: discountAmount,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      decoration: InputDecoration(
                        errorText: discountAmountValidate
                            ? '${AppLocalizations.of(context).translate('invalid_discount_amount')}'
                            : null,
                        prefixIcon: Icon(Icons.monetization_on),
                        labelText:
                            '${AppLocalizations.of(context).translate(discountType == 0 ? 'discount_amount' : 'discount_percentage')}',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.blueGrey),
                        hintText: '20',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: discountType == 1,
                  child: SizedBox(
                    width: 5,
                  ),
                ),
                Visibility(
                  visible: discountType == 1,
                  child: Expanded(
                    child: Theme(
                      data: new ThemeData(
                        primaryColor: Colors.orange,
                      ),
                      child: TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^\d*\.?\d*")),
                        ],
                        controller: maxDiscountAmount,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                        decoration: InputDecoration(
                          errorText: discountAmountValidate
                              ? '${AppLocalizations.of(context).translate('invalid_discount_amount')}'
                              : null,
                          prefixIcon: Icon(Icons.monetization_on),
                          labelText:
                              '${AppLocalizations.of(context).translate('max_discount_amount')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          hintText: '20',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${AppLocalizations.of(context).translate('start_date')}',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(89, 100, 109, 1))),
                      FlatButton.icon(
                          padding: EdgeInsets.zero,
                          label: Text(
                            startDate != null
                                ? selectedDateFormat
                                    .format(startDate)
                                    .toString()
                                : '${AppLocalizations.of(context).translate('select_date')}',
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 13,
                                color: startDate != null
                                    ? Colors.black87
                                    : Colors.grey),
                          ),
                          icon: Icon(Icons.date_range,
                              color: startDate != null
                                  ? Colors.orangeAccent
                                  : Colors.black54),
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                onChanged: (date) {}, onConfirm: (date) {
                              setState(() {
                                startDate = date;
                              });
                            },
                                currentTime: startDate != null
                                    ? startDate
                                    : DateTime.now(),
                                locale: LocaleType.zh);
                          }),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${AppLocalizations.of(context).translate('end_date')}',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(89, 100, 109, 1))),
                      FlatButton.icon(
                          padding: EdgeInsets.zero,
                          label: Text(
                            endDate != null
                                ? selectedDateFormat.format(endDate).toString()
                                : '${AppLocalizations.of(context).translate('select_date')}',
                            style: TextStyle(
                                fontSize: 13,
                                color: endDate != null
                                    ? Colors.black87
                                    : Colors.grey),
                          ),
                          icon: Icon(Icons.date_range,
                              color: endDate != null
                                  ? Colors.orangeAccent
                                  : Colors.black54),
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                onChanged: (date) {}, onConfirm: (date) {
                              setState(() {
                                endDate = date;
                              });
                            },
                                currentTime:
                                    endDate != null ? endDate : DateTime.now(),
                                locale: LocaleType.zh);
                          })
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget restrictionLayout() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            '${AppLocalizations.of(context).translate('usage_restriction')}',
                        style: TextStyle(
                            color: Color.fromRGBO(89, 100, 109, 1),
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: '\n'),
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context).translate('usage_restriction_description')}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                      '${AppLocalizations.of(context).translate('when_can_use')}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(89, 100, 109, 1))),
                ),
                Expanded(
                  flex: 3,
                  child: DropdownButton(
                      value: discountCondition,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      items: [
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('reach_certain_amount')),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('reach_certain_quantity')),
                          value: 1,
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          discountCondition = value;
                          conditionAmount.clear();
                        });
                      }),
                ),
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
                keyboardType: discountCondition == 0
                    ? TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                ],
                controller: conditionAmount,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                decoration: InputDecoration(
                  prefixIcon: discountCondition == 0
                      ? Icon(Icons.attach_money_outlined)
                      : Icon(Icons.format_list_numbered),
                  labelText:
                      '${AppLocalizations.of(context).translate(discountCondition == 0 ? 'amount' : 'quantity')}',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate(discountCondition == 0 ? 'any_amount' : 'any_quantity')}',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget usageLayout() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            '${AppLocalizations.of(context).translate('usage_limit')}',
                        style: TextStyle(
                            color: Color.fromRGBO(89, 100, 109, 1),
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: '\n'),
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context).translate('usage_limit_description')}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
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
                controller: usageLimit,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.data_usage),
                  labelText:
                      '${AppLocalizations.of(context).translate('usage_limit_per_coupon')}',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('unlimited_usage')}',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                ),
              ),
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
                controller: usageLimitUser,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.people),
                  labelText:
                      '${AppLocalizations.of(context).translate('usage_limit_per_user')}',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  hintText:
                      '${AppLocalizations.of(context).translate('unlimited_usage')}',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  checkingInput(context) {
    print('discount type: ${getDiscountType()}');
    if (couponCode.text.isEmpty) {
      couponCodeValidate = true;
      showSnackBar(context, 'invalid_code');
      return;
    }
    //check discount amount
    if (discountAmount.text.isEmpty) {
      discountAmountValidate = true;
      showSnackBar(context, 'invalid_discount_amount');
      return;
    }

    if (!widget.isUpdate)
      createCoupon(context);
    else
      updateCoupon(context);
  }

  createCoupon(context) async {
    print(getDiscountCondition().toString());
    Coupon coupon = Coupon(
        couponCode: couponCode.text,
        startDate: startDate != null ? startDate.toString() : '',
        endDate: endDate != null ? endDate.toString() : '',
        status: 0,
        usageLimit: usageChecking(usageLimit.text),
        usageLimitPerUser: usageChecking(usageLimitUser.text),
        discountType: getDiscountType().toString(),
        discountCondition: getDiscountCondition().toString(),
        productRestriction: getProductRestriction().toString());

    Map data = await Domain().createCoupon(coupon, 0);
    if (data['status'] == '1') {
      showSnackBar(context, 'create_success');
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context, true);
    } else if (data['status'] == '3') {
      showSnackBar(context, 'repeated_coupon');
    } else
      showSnackBar(context, 'something_went_wrong');
  }

  updateCoupon(context) async {
    Coupon coupon = Coupon(
        couponId: widget.couponId,
        couponCode: couponCode.text,
        startDate: startDate != null
            ? selectedDateFormat.format(startDate).toString()
            : '',
        endDate: endDate != null
            ? selectedDateFormat.format(endDate).toString()
            : '',
        status: 0,
        usageLimit: usageChecking(usageLimit.text),
        usageLimitPerUser: usageChecking(usageLimitUser.text),
        discountType: getDiscountType().toString(),
        discountCondition: getDiscountCondition().toString(),
        productRestriction: getProductRestriction().toString());

    Map data = await Domain().updateCoupon(coupon, 0);
    print(data);
    if (data['status'] == '1') {
      showSnackBar(context, 'update_success');
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context, true);
    } else if (data['status'] == '3') {
      showSnackBar(context, 'repeated_coupon');
    } else
      showSnackBar(context, 'something_went_wrong');
  }

  deleteCoupon(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('delete_message')}"),
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
                /*
              * delete coupon
              * */
                Map data = await Domain().deleteCoupon(widget.couponId);
                if (data['status'] == '1') {
                  CustomToast(
                          '${AppLocalizations.of(context).translate('delete_success')}',
                          context)
                      .show();
                  await Future.delayed(Duration(milliseconds: 300));
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
                } else
                  CustomToast(
                          '${AppLocalizations.of(context).translate('something_went_wrong')}',
                          context)
                      .show();
              },
            ),
          ],
        );
      },
    );
  }

  Future fetchCouponDetail(context) async {
    Map data = await Domain().fetchDiscountDetail(widget.couponId.toString());
    if (data['status'] == '1') {
      try {
        Coupon coupon = Coupon.fromJson(data['coupon'][0]);
        couponCode.text = coupon.couponCode;

        var discountType = jsonDecode(coupon.discountType);
        this.discountType = int.parse(discountType['type']);
        this.discountAmount.text =
            Order().convertToInt(discountType['rate']).toStringAsFixed(2);
        this.maxDiscountAmount.text =
            discountType['max_rate'] != '-1' && discountType['max_rate'] != null
                ? Order()
                    .convertToInt(setUsage(discountType['max_rate']))
                    .toStringAsFixed(2)
                : '';

        startDate = coupon.startDate.isNotEmpty
            ? DateTime.parse(coupon.startDate)
            : null;
        endDate =
            coupon.endDate.isNotEmpty ? DateTime.parse(coupon.endDate) : null;

        var discountCondition = jsonDecode(coupon.discountCondition);
        this.discountCondition = int.parse(discountCondition['type']);
        this.conditionAmount.text = Order()
            .convertToInt(discountCondition['condition'])
            .toStringAsFixed(2);

        usageLimit.text = setUsage(coupon.usageLimit.toString());
        usageLimitUser.text = setUsage(coupon.usageLimitPerUser.toString());
      } catch(e) {
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

    setState(() {
      freshStream.add('display');
    });
  }

  Map<String, dynamic> getDiscountType() {
    return {
      jsonEncode('type'): jsonEncode(discountType.toString()),
      jsonEncode('rate'): jsonEncode(discountAmount.text),
      jsonEncode('max_rate'): jsonEncode(usageChecking(maxDiscountAmount.text)),
    };
  }

  Map<String, dynamic> getDiscountCondition() {
    return {
      jsonEncode('type'): jsonEncode(discountCondition.toString()),
      jsonEncode('condition'):
          jsonEncode(conditionAmount.text.isEmpty ? '0' : conditionAmount.text),
    };
  }

  Map<String, dynamic> getProductRestriction() {
    return {
      jsonEncode('restriction'): jsonEncode('0'),
      jsonEncode('product_id'): jsonEncode(''),
    };
  }

  usageChecking(String value) {
    return value.isEmpty || value == '-1' ? '-1' : value;
  }

  setUsage(String value) {
    return value == '-1' ? '' : value;
  }

  showSnackBar(context, message) {
    CustomSnackBar.show(
        context, '${AppLocalizations.of(context).translate(message)}');
  }
}
