import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final key = new GlobalKey<ScaffoldState>();
  String status;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkMerchantInformation();
    return Scaffold(
      key: key,
      body: CustomProgressBar(),
    );
  }

  netWorkChecking() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      launchChecking();
    } else {
      key.currentState.showSnackBar(new SnackBar(
          duration: Duration(days: 1),
          content: new Text("No Internet Connection!"),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              key.currentState.hideCurrentSnackBar();
              setState(() {});
              // Some code to undo the change.
            },
          )));
    }
  }

  void checkMerchantInformation() async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      var data = await SharePreferences().read('merchant');
      print('merchant data: $data');
      if (data != null) {
        launchChecking();
      } else
        Navigator.pushReplacementNamed(context, '/login');
    } on Exception {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void launchChecking() async {
    Map data = await Domain().launchCheck();
    print(data);
    if (data['status'] == '1') {
      status = data['merchant_status'][0]['status'].toString();

      String latestVersion = data['version'][0]['version'].toString();
      String currentVersion = await getVersionNumber();
      print('current: $currentVersion');

      var prefs = await SharedPreferences.getInstance();
      print('product limit: ${data['user_preference'][0]['product_limit']}');
      await prefs.setString('allow_discount', data['user_preference'][0]['allow_discount'].toString());
      await prefs.setString('product_limit', data['user_preference'][0]['product_limit'].toString());
      await prefs.setString('allow_take_photo', data['user_preference'][0]['allow_take_photo'].toString());

      if (latestVersion != currentVersion) {
        openUpdateDialog(data);
        return;
      }
      checkMerchantStatus();
    } else
      openDisableDialog();
  }

  checkMerchantStatus() async {
    String merchantStatus = status;
    if (merchantStatus == '1') {
      Merchant merchant =
          Merchant.fromJson(await SharePreferences().read('merchant'));
      merchant.merchantId != null
          ? Navigator.pushReplacementNamed(context, '/home')
          : Navigator.pushReplacementNamed(context, '/login');
    } else
      openDisableDialog();
  }

  getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /*
  * edit product dialog
  * */
  openDisableDialog() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
            "${AppLocalizations.of(context).translate('something_went_wrong')}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('drawable/error.png'),
                Text(
                  '${AppLocalizations.of(context).translate('account_disable_description')}',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            FlatButton(
              child: Text(
                'Contact',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                launch(('https://www.emenu.com.my'));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*
  * update available
  * */
  openUpdateDialog(data) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
            "${AppLocalizations.of(context).translate('new_version')}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${AppLocalizations.of(context).translate('new_version_description')}',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).translate('later')),
              onPressed: () {
                Navigator.of(context).pop();
                checkMerchantStatus();
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('update_now'),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                launch((Platform.isIOS
                    ? data['version'][0]['appstore_url'].toString()
                    : data['version'][0]['playstore_url'].toString()));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
