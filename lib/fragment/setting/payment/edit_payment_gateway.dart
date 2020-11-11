import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class PaymentGatewayDialog extends StatefulWidget {
  PaymentGatewayDialog();

  @override
  _PaymentGatewayDialogState createState() => _PaymentGatewayDialogState();
}

class _PaymentGatewayDialogState extends State<PaymentGatewayDialog> {
  var merchantName = TextEditingController();
  var apiKey = TextEditingController();
  var secretKey = TextEditingController();

  bool hideApiKey = true;
  bool hideSecretKey = true;

  StreamController refreshController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title:
            new Text('${AppLocalizations.of(context).translate('setup_fpay')}'),
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
            onPressed: () {
              updateFPayDetail(context);
            },
          ),
        ],
        content: FutureBuilder(
            future: Domain().fetchProfile(),
            builder: (context, object) {
              if (object.hasData) {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    List responseJson = data['profile'];

                    print(responseJson);

                    Merchant merchant = responseJson
                        .map((jsonObject) => Merchant.fromJson(jsonObject))
                        .toList()[0];

                    merchantName.text = merchant.fpayUsername;
                    secretKey.text = merchant.fpaySecretKey;
                    apiKey.text = merchant.fpayApiKey;

                    return mainContent(context);
                  } else {
                    return Container(height: 50, child: CustomProgressBar());
                  }
                }
              }
              return Container(height: 50, child: CustomProgressBar());
            }));
  }

  updateFPayDetail(context) async {
    if (merchantName.text.length <= 0 ||
        apiKey.text.length <= 0 ||
        secretKey.text.length <= 0) {
      return CustomToast(
              '${AppLocalizations.of(context).translate('all_field_required')}',
              context)
          .show();
    }

    Map data = await Domain().updateFPayDetail(merchantName.text.toString(),
        apiKey.text.toString(), secretKey.text.toString());

    if (data['status'] == '1') {
      CustomToast('${AppLocalizations.of(context).translate('update_success')}',
              context)
          .show();
      Navigator.of(context).pop();
    } else
      CustomToast(
              '${AppLocalizations.of(context).translate('something_went_wrong')}',
              context)
          .show();
  }

  Widget mainContent(context) {
    return StreamBuilder<Object>(
        stream: refreshController.stream,
        builder: (context, object) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: TextField(
                  controller: merchantName,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_box),
                      labelText:
                          '${AppLocalizations.of(context).translate('merchant_name')}',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.blueGrey),
                      hintText:
                          '${AppLocalizations.of(context).translate('merchant_name')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: TextField(
                  controller: apiKey,
                  obscureText: hideApiKey,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_lock),
                    labelText:
                        '${AppLocalizations.of(context).translate('api_key')}',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    hintText:
                        '${AppLocalizations.of(context).translate('api_key')}',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: () {
                        hideApiKey = !hideApiKey;
                        refreshController.add('update');
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: TextField(
                  controller: secretKey,
                  obscureText: hideSecretKey,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_key),
                    labelText:
                        '${AppLocalizations.of(context).translate('secret_key')}',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    hintText:
                        '${AppLocalizations.of(context).translate('secret_key')}',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: () {
                        hideSecretKey = !hideSecretKey;
                        refreshController.add('update');
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
