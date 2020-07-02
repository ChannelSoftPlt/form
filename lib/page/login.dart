import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my/object/merchant.dart';
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
                  Image.asset('drawable/logo.jpg', height: 250),
                  Theme(
                    child: customTextField(email, 'Email', null),
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Theme(
                    child: customTextField(password, 'Password', hidePassword),
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Forgot Password'),
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 5,
                      child: Text('Sign In', style: TextStyle(color: Colors.white),),
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
        child: Text(
          _platformVersion,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 10),
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
      var response = await http.post(Domain.registration, body: {'login': '1', 'email': email.text, 'password': password.text});
      Map data = jsonDecode(response.body);
      print(data);
      if (data['status'] == '1') {
        storeUser(data['user_detail']);
        showSnackBar(context, 'Login Successfully!');
      } else
        showSnackBar(context, 'Invalid email or username!');
    } else {
      showSnackBar(context, 'All fields are required!');
    }
  }

  storeUser(data) async {
    try {
      await SharePreferences().save(
          'merchant',
          Merchant(
              merchantId: data['merchant_id'].toString(),
              name: data['name'],
              email: data['email']));
      Navigator.pushReplacementNamed(context, '/home');
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
      obscureText: hint == 'Password' ? hidePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.orangeAccent),
          borderRadius: const BorderRadius.all(
            const Radius.circular(50.0),
          ),
        ),
        suffixIcon: IconButton(
            icon: hint == 'Password'
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.clear),
            onPressed: () =>
                hint == 'Password' ? showPassword() : controller.clear()),
        prefixIcon: Icon(hint == 'Password' ? Icons.lock : Icons.email),
      ),
    );
  }
}
