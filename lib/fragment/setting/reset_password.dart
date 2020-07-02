import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/utils/domain.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  var currentPassword = TextEditingController();
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();

  bool hideCurrentPassword = true;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext innerContext) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Update New Password',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Remember! a stronger password make your data more secure! Make it stronger today!',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Image.asset('drawable/change_password.png'),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: <Widget>[
                        Theme(
                          data: new ThemeData(
                            primaryColor: Colors.orange,
                          ),
                          child: TextField(
                            controller: currentPassword,
                            obscureText: hideCurrentPassword,
                            decoration: InputDecoration(
                              hintText: 'Current Password',
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: Colors.orangeAccent),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      hideCurrentPassword =
                                          !hideCurrentPassword;
                                    });
                                  }),
                              prefixIcon: Icon(Icons.lock),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Colors.orange,
                          ),
                          child: TextField(
                            controller: newPassword,
                            obscureText: hideNewPassword,
                            decoration: InputDecoration(
                              hintText: 'New Password',
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: Colors.orangeAccent),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  setState(() {
                                    hideNewPassword = !hideNewPassword;
                                  });
                                },
                              ),
                              prefixIcon: Icon(Icons.lock),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Colors.orange,
                          ),
                          child: TextField(
                            controller: confirmPassword,
                            obscureText: hideConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: Colors.orangeAccent),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(50.0),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  setState(() {
                                    hideConfirmPassword = !hideConfirmPassword;
                                  });
                                },
                              ),
                              prefixIcon: Icon(Icons.lock),
                            ),
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
                            onPressed: () => updatePassword(innerContext),
                            child: Text(
                              'Sign In',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  updatePassword(context) async {
    if (currentPassword.text.length > 6 &&
        newPassword.text.length > 6 &&
        confirmPassword.text.length > 6) {
      if (newPassword.text == confirmPassword.text) {
        /*
        * update password
        * */
        Map data = await Domain()
            .updatePassword(currentPassword.text, newPassword.text);

        if (data['status'] == '1') {
          CustomSnackBar.show(context, 'Update Successfully!');
          currentPassword.clear();
          newPassword.clear();
          confirmPassword.clear();
          /*
          * invalid password
          * */
        } else if (data['status'] == '3')
          CustomSnackBar.show(context, 'Current Password not match!');
        /*
        * server error
        * */
        else
          CustomSnackBar.show(context, 'Something Went Wrong!');
      }
      /*
      * password not match
      * */
      else
        CustomSnackBar.show(context, 'Password not match!');
    } else {
      CustomSnackBar.show(context, 'Password too short!');
    }
  }
}
