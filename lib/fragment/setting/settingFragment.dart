import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my/fragment/setting/edit_profile.dart';
import 'package:my/fragment/setting/export_setting.dart';
import 'package:my/fragment/setting/payment/edit_payment_method.dart';
import 'package:my/fragment/setting/payment/language_setting.dart';
import 'package:my/fragment/setting/promotion_dialog.dart';
import 'package:my/fragment/setting/qr_dialog.dart';
import 'package:my/fragment/setting/reset_password.dart';
import 'package:my/fragment/setting/shipping/shipping_setting.dart';
import 'package:my/page/loading.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'coupon/discount.dart';
import 'edit_form.dart';
import 'orderSetting/order_setting.dart';

class SettingFragment extends StatefulWidget {
  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  String _platformVersion = 'Default';
  bool isButtonPressed = false;
  String url = '';

  String expiredDate = '-';
  String dayLeft = '-';

  bool discountEnable = false;

  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVersionNumber();
    getUrl();
    discountFeatureChecking();
    expiredChecking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              accountLayout(),
              SizedBox(
                height: 20,
              ),
              toolLayout(),
              aboutAppLayout(),
              footerLayout()
            ],
          ),
        ));
  }

  Widget accountLayout() {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('user_detail')}',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: Card(
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                              '${AppLocalizations.of(context).translate('payment_due')} $expiredDate',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 14))),
                      Expanded(
                          flex: 1,
                          child: Text(
                              '$dayLeft ${AppLocalizations.of(context).translate('days')}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)))
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
                leading: Icon(
                  Icons.link,
                  size: 35,
                  color: Colors.lightBlueAccent,
                ),
                title: Text(
                  url,
                  style: TextStyle(
                      color: Color.fromRGBO(89, 100, 109, 1), fontSize: 12),
                ),
                trailing: IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      size: 30,
                    ),
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(text: url));
                      key.currentState.showSnackBar(new SnackBar(
                        content: new Text(
                            '${AppLocalizations.of(context).translate('copy_to_clipboard')}'),
                      ));
                    })),
            SizedBox(
              height: 10,
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.blue,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('edit_profile')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPassword(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.lock_outline,
                  size: 35,
                  color: Colors.green,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('change_password')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  showLanguageDialog();
                },
                leading: Icon(
                  Icons.language,
                  size: 35,
                  color: Colors.amberAccent,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('language')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  showQRCodeDialog();
                },
                leading: Icon(
                  Icons.qr_code,
                  size: 35,
                  color: Colors.redAccent,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('qr_code')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
          ],
        ),
      ),
    );
  }

  Widget toolLayout() {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('marketing_tool')}',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditForm(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.web,
                  size: 35,
                  color: Colors.pink,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('form_setting')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShippingSetting(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.local_shipping,
                  size: 35,
                  color: Colors.green,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('shipping_setting')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPaymentMethod(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.payment,
                  size: 35,
                  color: Colors.lightBlue,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('payment_method')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSetting(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.settings_applications,
                  size: 35,
                  color: Colors.red,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('order_setting')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            Visibility(
              visible: discountEnable,
              child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiscountPage(
                          query: '',
                          showActionBar: true,
                        ),
                      ),
                    );
                  },
                  leading: Icon(
                    Icons.local_offer,
                    size: 35,
                    color: Colors.purpleAccent,
                  ),
                  title: Text(
                    '${AppLocalizations.of(context).translate('discount_coupon')}',
                    style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    size: 30,
                  )),
            ),
            Visibility(
              visible: discountEnable,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: Divider(
                  color: Colors.teal.shade100,
                  thickness: 1.0,
                ),
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPromotionDialog(),
                    ),
                  );
                },
                leading: Icon(
                  Icons.perm_media,
                  size: 35,
                  color: Colors.blue,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('promotion_dialog')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            ListTile(
                onTap: () {
                  showExportDialog();
                },
                leading: Icon(
                  Icons.insert_drive_file,
                  size: 35,
                  color: Colors.blueGrey,
                ),
                title: Text(
                  '${AppLocalizations.of(context).translate('export_data')}',
                  style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                )),
          ],
        ),
      ),
    );
  }

  Widget aboutAppLayout() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Visibility(
            visible: false,
            child: Column(
              children: <Widget>[
                Text(
                  '${AppLocalizations.of(context).translate('setting')}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                    leading: Icon(
                      Icons.notifications,
                      size: 35,
                      color: Colors.red,
                    ),
                    title: Text(
                      '${AppLocalizations.of(context).translate('notification')}',
                      style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right,
                      size: 30,
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            '${AppLocalizations.of(context).translate('about_the_app')}',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
              onTap: () => launch(('https://www.channelsoft.com.my')),
              title: Text(
                'CHANNEL SOFT PLT',
                style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                size: 30,
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
            child: Divider(
              color: Colors.teal.shade100,
              thickness: 1.0,
            ),
          ),
          ListTile(
              onTap: () =>
                  launch(('https://www.channelsoft.com.my/contact-us/')),
              title: Text(
                '${AppLocalizations.of(context).translate('contact_us')}',
                style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                size: 30,
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
            child: Divider(
              color: Colors.teal.shade100,
              thickness: 1.0,
            ),
          ),
          ListTile(
              onTap: () =>
                  launch(('https://www.channelsoft.com.my/privacy-policy/')),
              title: Text(
                '${AppLocalizations.of(context).translate('privacy_policy')}',
                style: TextStyle(color: Color.fromRGBO(89, 100, 109, 1)),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                size: 30,
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
            child: Divider(
              color: Colors.teal.shade100,
              thickness: 1.0,
            ),
          ),
          SizedBox(
            height: 35,
          ),
        ],
      ),
    );
  }

  Widget footerLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: double.infinity,
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: RaisedButton(
                elevation: 5,
                color: Colors.orangeAccent,
                padding: const EdgeInsets.fromLTRB(40, 12, 40, 12),
                onPressed: () {
                  setState(() {
                    isButtonPressed = !isButtonPressed;
                    showLogOutDialog();
//                            logOut();
                  });
                },
                child: Text(
                  '${AppLocalizations.of(context).translate('log_out')}',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Image.asset('drawable/logo.jpg', height: 30),
        Text(
          '${AppLocalizations.of(context).translate('all_right_reserved_by')} CHANNEL SOFT PLT',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          _platformVersion,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 10),
        )
      ],
    );
  }

  getUrl() async {
    this.url = await SharePreferences().read('url');
    if (url.length > 0) this.url = url.substring(8, url.length);
    setState(() {});
  }

  getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print(version);
    setState(() {
      _platformVersion = version;
    });
  }

  Future<void> showLanguageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return LanguageDialog();
      },
    );
  }

  Future<void> showExportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ExportDialog();
      },
    );
  }

  Future<void> showQRCodeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return QrDialog();
      },
    );
  }

  Future<void> showLogOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '${AppLocalizations.of(context).translate('sign_out_request')}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppLocalizations.of(context).translate('sign_out_message')}'),
              ],
            ),
          ),
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
              onPressed: () {
                logOut();
              },
            ),
          ],
        );
      },
    );
  }

  logOut() async {
    String token = await SharePreferences().read('token');

    Map data = await Domain().updateTokenStatus(token);
    //print(data);
    print(data);
    if (data['status'] == '1') {
      SharePreferences().clear();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoadingPage()),
          ModalRoute.withName('/'));
    } else
      key.currentState.showSnackBar(new SnackBar(
        content: new Text(
            '${AppLocalizations.of(context).translate('something_went_wrong')}'),
      ));
  }

  expiredChecking() async {
    Map data = await Domain().expiredChecking();
    print('expired data: $data');
    if (data['status'] == '1') {
      //check expired date
      String expiredDate = data['expired_date'][0]['end_date'].toString();
      this.expiredDate = setExpiredDate(expiredDate);
      this.dayLeft = countDayLeft(expiredDate);
      setState(() {});
    }
  }

  discountFeatureChecking() async {
    //check discount features
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('allow_discount') == null ||
        prefs.getString('allow_discount') == '1') {
      discountEnable = false;
    } else
      discountEnable = true;
    setState(() {});
  }

  String setExpiredDate(date) {
    final dateFormat = DateFormat("dd/MM/yyyy");
    try {
      DateTime todayDate = DateTime.parse(date);
      return dateFormat.format(todayDate);
    } on Exception {
      return '';
    }
  }

  String countDayLeft(date) {
    final currentDate = DateTime.now();
    try {
      DateTime expired = DateTime.parse(date);
      return (expired.difference(currentDate).inDays + 1).toString();
    } on Exception {
      return '';
    }
  }
}
