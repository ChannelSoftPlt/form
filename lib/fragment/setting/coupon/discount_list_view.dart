import 'dart:async';
import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/object/coupon.dart';
import 'package:my/object/order.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:share/share.dart';

import 'discount details/discount_detail.dart';

class DiscountListView extends StatefulWidget {
  final Coupon coupon;
  final Function refresh;

  DiscountListView({this.coupon, this.refresh});

  @override
  _DiscountListViewState createState() => _DiscountListViewState();
}

class _DiscountListViewState extends State<DiscountListView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => openDiscountDetail(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${AppLocalizations.of(context).translate('coupon_code')}: ',
                            style: TextStyle(
                                color: Colors.black26,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            widget.coupon.couponCode,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                maxLines: 10,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${AppLocalizations.of(context).translate('usage')}: ',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: getCouponUsage(),
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.edit,
                                color: Colors.black45,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              InkWell(
                                onTap: () {
                                  Share.share(getCouponShareContent());
                                },
                                child: Icon(
                                  Icons.share,
                                  color: Colors.black45,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      lineThickness: 1.0,
                      dashLength: 4.0,
                      dashColor: Colors.grey,
                      dashRadius: 0.0,
                      dashGapLength: 5.0,
                      dashGapColor: Colors.transparent,
                      dashGapRadius: 0.0,
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate('discount')}',
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          Text(
                            getDiscountAmount(),
                            maxLines: 1,
                            style: GoogleFonts.aBeeZee(
                              textStyle: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      )),
                ]),
          ),
        ),
      ),
    );
  }

  getCouponShareContent() {
    try {
      return 'Use Coupon Code: ${widget.coupon.couponCode} to enjoy ${getDiscountAmount()} discount today!';
    } catch(e) {
      return 'Something Went Wrong';
    }
  }

  getCouponUsage() {
    try {
      if (widget.coupon.usageLimit >= 0) {
        return '${widget.coupon.couponUsed} / ${widget.coupon.usageLimit}';
      } else
        return '${widget.coupon.couponUsed} / ${AppLocalizations.of(context).translate('unlimited')}';
    } catch(e) {
      return '- / -';
    }
  }

  getDiscountAmount() {
    try {
      var discountAmountObject = jsonDecode(widget.coupon.discountType);
      String discountAmountType = discountAmountObject['type'];
      String discountAmount =
          Order().convertToInt(discountAmountObject['rate']).toStringAsFixed(2);

      if (discountAmountType == '0')
        return 'RM$discountAmount';
      else
        return '$discountAmount%';
    } catch(e) {
      print(e);
      return '--';
    }
  }

  openDiscountDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountDetail(
          isUpdate: true,
          couponId: widget.coupon.couponId,
        ),
      ),
    ).then((value) => onGoBack(value));
  }

  FutureOr onGoBack(dynamic value) {
    if (value != null) {
      widget.refresh();
    }
  }
}
