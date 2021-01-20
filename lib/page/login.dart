import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my/object/merchant.dart';
import 'package:my/page/forgot_password.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:http/http.dart' as http;
import 'package:my/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginPage> {
  String _platformVersion = 'Default';

  //clear message purpose
  var email = TextEditingController();
  var password = TextEditingController();
  bool hidePassword = true;

  @override
  initState() {
    super.initState();
    getVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext innerContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Image.asset('drawable/logo.png', height: 200),
                  Theme(
                    child: customTextField(email, 'email', null),
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Theme(
                    child: customTextField(password, 'password', hidePassword),
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        '${AppLocalizations.of(context).translate('forgot_password')}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 5,
                      child: Text(
                        '${AppLocalizations.of(context).translate('sign_in')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onPressed: () {
                        login(innerContext);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('drawable/logo.jpg', height: 50),
              Text(
                '${AppLocalizations.of(context).translate('all_right_reserved_by')} CHANNEL SOFT PLT',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text(
                '${AppLocalizations.of(context).translate('version')} $_platformVersion',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
    );
  }

  // Toggles the password show status
  void showPassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _platformVersion = version;
    });
  }

  void login(context) async {
    if (email.text.length > 0 && password.text.length > 0) {
      var response = await http.post(Domain.registration,
          body: {'login': '1', 'email': email.text, 'password': password.text});
      Map data = jsonDecode(response.body);
      print(data);
      if (data['status'] == '1') {
        //google api key
        storeGoogleApiKey(data['key']);
        //user information
        storeUser(data['user_detail']);
        showSnackBar(context,
            '${AppLocalizations.of(context).translate('login_success')}');
      } else
        showSnackBar(context,
            '${AppLocalizations.of(context).translate('invalid_email_password')}');
    } else {
      showSnackBar(context,
          '${AppLocalizations.of(context).translate('all_field_required')}');
    }
  }

  storeUser(data) async {
    print('form id: ${data['form_id'].toString()}');
    try {
      await SharePreferences().save(
          'merchant',
          Merchant(
              merchantId: data['merchant_id'].toString(),
              formId: data['form_id'].toString(),
              name: data['name'],
              url: getUrl(data['url']),
              email: data['email']));
      Navigator.pushReplacementNamed(context, '/');
    } on Exception catch (e) {
      print('Error!! $e');
    }
  }

  String getUrl(url) {
    try {
      String headerUrl = url.substring(0, 4);
      if (headerUrl == 'http')
        return url;
      else
        return 'https://www.emenu.com.my/$url';
    } catch(err) {
      return 'https://www.emenu.com.my/$url';
    }
  }

  storeGoogleApiKey(data) async {
    try {
      //google api key
      await SharePreferences()
          .save('google_api_key', data[0]['google_api_key']);
    } on Exception catch (e) {
      print('Error!! $e');
    }
  }

  void showSnackBar(context, text) {
    final snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  TextField customTextField(controller, String hint, hidePassword) {
    return TextField(
      controller: controller,
      obscureText: hint == 'password' ? hidePassword : false,
      decoration: InputDecoration(
        hintText: '${AppLocalizations.of(context).translate(hint)}',
        border: InputBorder.none,
        enabledBorder: new OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]),
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
        suffixIcon: IconButton(
            icon: hint == 'password'
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.clear),
            onPressed: () =>
                hint == 'password' ? showPassword() : controller.clear()),
        prefixIcon: Icon(hint == 'password' ? Icons.lock : Icons.email),
      ),
    );
  }
}
