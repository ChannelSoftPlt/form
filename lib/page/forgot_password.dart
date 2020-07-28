import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/main.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var email = TextEditingController();
  var pac = TextEditingController();

  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  StreamController pageStream;
  String pacNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageStream = StreamController();
    pageStream.add('email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: StreamBuilder(
                stream: pageStream.stream,
                builder: (context, object) {
                  if (object.data == 'email') {
                    return enterEmail(context);
                  } else if (object.data == 'pac') {
                    return verifyPac(context);
                  } else
                    return resetPassword(context);
                })),
      ),
    );
  }

  enterEmail(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.grey,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/forgot_password_icon.png',
                      height: 200),
                ),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'We just need your registered email address to send you password reset',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    textAlign: TextAlign.start,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.blueGrey),
                      hintText: '',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: RaisedButton(
                    elevation: 5,
                    onPressed: () => sendPac(context),
                    child: Text(
                      'Send Pac',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  verifyPac(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.grey,
          ),
          onPressed: () => pageStream.add('email'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/email_icon.png', height: 200),
                ),
                Text(
                  'Email Verification',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'A verification number is sent to your email. Please check your inbox and spam or jun email',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*")),
                    ],
                    controller: pac,
                    textAlign: TextAlign.start,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.verified_user),
                      labelText: 'Pac No',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.black54),
                      hintText: '',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Text(
                  "Didn't received email? Click here to resend",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: RaisedButton(
                    elevation: 5,
                    onPressed: () => checkPac(context),
                    child: Text(
                      'Verify Email',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  resetPassword(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.grey,
          ),
          onPressed: () => pageStream.add('pac'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/change_password_icon.png',
                      height: 200),
                ),
                Text(
                  'Reset Password',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Please enter your new password in order to reset your password',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: newPassword,
                    obscureText: hideNewPassword,
                    textAlign: TextAlign.start,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'New Password',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.black54),
                      hintText: '',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              hideNewPassword = !hideNewPassword;
                            });
                          }),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    obscureText: hideConfirmPassword,
                    controller: confirmPassword,
                    textAlign: TextAlign.start,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.verified_user),
                      labelText: 'Confirmation Password',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.black54),
                      hintText: '',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          }),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: RaisedButton(
                    elevation: 5,
                    onPressed: () => updatePassword(context),
                    child: Text(
                      'Update Password',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  /*
  * send pac via email
  * */
  sendPac(context) async {
    pacNumber = (new Random().nextInt(900000) + 100000).toString();
    Map data = await Domain().sendPac(email.text, pacNumber);

    if (data['status'] == '1') {
      CustomSnackBar.show(context, 'Pac Sent!');
      pageStream.add('pac');
    } else
      CustomSnackBar.show(context, 'Invalid Email!');
  }

  checkPac(context) {
    if (pac.text == pacNumber) {
      CustomSnackBar.show(context, 'Verify Successfully!');
      pageStream.add('reset');
    } else
      CustomSnackBar.show(context, 'Invalid Pac Number!');
  }

  updatePassword(context) async {
    if (newPassword.text == confirmPassword.text) {
      Map data = await Domain().setNewPassword(newPassword.text, email.text);
      if (data['status'] == '1') {
//        CustomSnackBar.show(context, 'Password Update Successfully!');
        CustomToast('Password Update Successfully!', context,
                gravity: Toast.BOTTOM)
            .show();
        Navigator.pushReplacementNamed(context, '/login');
//        pageStream.add('e');
      } else
        CustomSnackBar.show(context, 'Something Went Wrong!');
    } else
      CustomSnackBar.show(context, 'Password Not Matched!');
  }
}
