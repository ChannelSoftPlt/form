import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/setting/shipping/east_west_layout.dart';
import 'package:my/object/shippingSetting/shippingSetting.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class ShippingSetting extends StatefulWidget {
  @override
  _ShippingSettingState createState() => _ShippingSettingState();
}

class _ShippingSettingState extends State<ShippingSetting> {
  final key = new GlobalKey<ScaffoldState>();
  StreamController refreshStream;
  Shipping shipping;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshStream = StreamController();
    fetchShippingSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        actions: [
          TextButton.icon(
            label: Text(
              AppLocalizations.of(context).translate('save'),
              style: TextStyle(color: Colors.blueGrey),
            ),
            icon: Icon(
              Icons.save,
              color: Colors.blueGrey,
            ),
            onPressed: () {},
          ),
        ],
        title: Text(
          '${AppLocalizations.of(context).translate('shipping_setting')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      backgroundColor: Colors.white,
      body: shipping != null ? mainContent() : CustomProgressBar(),
    );
  }

  Widget mainContent() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black12, width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('shipping_type'),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )),
                      Expanded(
                        flex: 5,
                        child: DropdownButton(
                            isExpanded: true,
                            itemHeight: 50,
                            value: shipping.shippingStatus,
                            style:
                                TextStyle(fontSize: 15, color: Colors.black87),
                            items: [
                              DropdownMenuItem(
                                child: Text(AppLocalizations.of(context)
                                    .translate('east_west')),
                                value: 0,
                              ),
                              DropdownMenuItem(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('postcode'),
                                  textAlign: TextAlign.center,
                                ),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text(AppLocalizations.of(context)
                                    .translate('distance')),
                                value: 2,
                              ),
                            ],
                            onChanged: (value) {
                              print(value);
                              shipping.shippingStatus = value;
                              updateShippingStatus();
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                  stream: refreshStream.stream,
                  builder: (context, snapshot) {
                    return EastWestLayout();
                  })
            ],
          ),
        ),
      ),
    );
  }

  fetchShippingSetting() async {
    Map data = await Domain().readShippingSetting();
    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['shipping'];

        shipping = responseJson
            .map((jsonObject) => Shipping.fromJson(jsonObject))
            .toList()[0];

        changeShippingLayout();
      });
    }
  }

  changeShippingLayout() {
    if (shipping.shippingStatus == 0) {
      refreshStream.add('east_west');
    } else if (shipping.shippingStatus == 1) {
      refreshStream.add('postcode');
    } else
      refreshStream.add('distance');
  }

  updateShippingStatus() async {
    Map data =
        await Domain().updateShippingStatus(shipping.shippingStatus.toString());
    if (data['status'] == '1') {
      setState(() {
        changeShippingLayout();
        _showSnackBar('shipping_updated');
      });
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      content: new Text(AppLocalizations.of(context).translate(message)),
    ));
  }
}
