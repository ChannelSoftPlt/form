import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final key = new GlobalKey<ScaffoldState>();

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
      if (data != null) {
        launchChecking();
      } else
        Navigator.pushReplacementNamed(context, '/login');
    } on Exception catch (e) {
      print('hahahaha $e');
    }
  }

  void launchChecking() async {
    Map data = await Domain().launchCheck();
    if (data['status'] == '1') {
      String merchantStatus = data['merchant_status'][0]['status'].toString();
      if (merchantStatus == '1') {
        Merchant merchant =
            Merchant.fromJson(await SharePreferences().read('merchant'));
        merchant.merchantId != null
            ? Navigator.pushReplacementNamed(context, '/home')
            : Navigator.pushReplacementNamed(context, '/login');
      } else
        openDisableDialog();
    } else
      openDisableDialog();
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
            "Something Went Wrong",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('drawable/error.png'),
                Text(
                  'Unable access into your account..please contact our administrator for future support!',
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
}
