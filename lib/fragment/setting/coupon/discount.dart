import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/order/searchPage.dart';
import 'package:my/object/coupon.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'discount details/discount_detail.dart';
import 'discount_list.dart';

class DiscountPage extends StatefulWidget {
  final String query;
  final bool showActionBar;

  DiscountPage({this.query, this.showActionBar});

  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final int itemPerPage = 8, currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.showActionBar ? AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('discount_coupon')}',
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
              icon: Icon(
                Icons.search,
                color: Colors.orange,
              ),
              onPressed: () {
                openSearchPage();
                // do something
              },
            ),
            IconButton(
              icon: Icon(
                Icons.create_new_folder,
                color: Colors.orange,
              ),
              onPressed: () {
                openDiscountDetail();
                // do something
              },
            ),
          ],
        ) : null,
        body: FutureBuilder(
            future: Domain()
                .fetchDiscount(currentPage, itemPerPage, widget.query ?? ''),
            builder: (context, object) {
              if (object.hasData) {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    List responseJson = data['coupon'];
                    return CouponList(
                        coupons: (responseJson
                            .map((jsonObject) => Coupon.fromJson(jsonObject))
                            .toList()));
                  } else {
                    return notFound();
                  }
                }
              }
              return Center(child: CustomProgressBar());
            }));
  }

  openDiscountDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountDetail(
          isUpdate: false,
        ),
      ),
    ).then((val) => {onGoBack(val)});
  }

  FutureOr onGoBack(dynamic value) {
    if (value != null) {
      setState(() {});
    }
  }

  openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          type: 'discount_coupon',
        ),
      ),
    );
  }

  Widget notFound() {
    return NotFound(
        title: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('not_item_found')}'
            : '${AppLocalizations.of(context).translate('no_coupon_found')}',
        description: widget.query.length > 1
            ? '${AppLocalizations.of(context).translate('try_other_keyword')}'
            : '${AppLocalizations.of(context).translate('no_coupon_found_description')}',
        showButton: widget.query.length < 1,
        refresh: () {
          setState(() {});
        },
        button: widget.query.length > 1
            ? ''
            : '${AppLocalizations.of(context).translate('refresh')}',
        drawable: widget.query.length > 1
            ? 'drawable/not_found.png'
            : 'drawable/coupon.png');
  }
}
