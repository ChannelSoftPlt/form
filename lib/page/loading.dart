import 'package:flutter/material.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/sharePreference.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomProgressBar(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkMerchantInformation();
  }

  void checkMerchantInformation() async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      var data = await SharePreferences().read('merchant');
      if (data != null) {
        Merchant merchant =
            Merchant.fromJson(await SharePreferences().read('merchant'));
        merchant.merchantId != null
            ? Navigator.pushReplacementNamed(context, '/home')
            : Navigator.pushReplacementNamed(context, '/login');
      } else
        Navigator.pushReplacementNamed(context, '/login');
    } on Exception catch (e) {
      print('hahahaha $e');
    }
  }
}
