import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
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
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            '${AppLocalizations.of(context).translate('update_password')}',
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.orangeAccent),
        ),
        body: Builder(builder: (BuildContext innerContext) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            Image.asset('drawable/change_password.png'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${AppLocalizations.of(context).translate('update_password_label')}',
                              style: TextStyle(
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: currentPassword,
                              obscureText: hideCurrentPassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                labelText: '${AppLocalizations.of(context).translate('current_password')}',
                                labelStyle: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                                hintText: '${AppLocalizations.of(context).translate('current_password')}',
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      setState(() {
                                        hideCurrentPassword =
                                            !hideCurrentPassword;
                                      });
                                    }),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: newPassword,
                              obscureText: hideNewPassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                labelText: '${AppLocalizations.of(context).translate('new_password')}',
                                labelStyle: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                                hintText: '${AppLocalizations.of(context).translate('new_password')}',
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      hideNewPassword = !hideNewPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: confirmPassword,
                              obscureText: hideConfirmPassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                labelText: '${AppLocalizations.of(context).translate('confirm_password')}',
                                labelStyle: TextStyle(
                                    fontSize: 16, color: Colors.blueGrey),
                                hintText: '${AppLocalizations.of(context).translate('confirm_password')}',
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal)),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      hideConfirmPassword =
                                          !hideConfirmPassword;
                                    });
                                  },
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
                                  '${AppLocalizations.of(context).translate('sign_in')}',
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
          CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('update_success')}');
          currentPassword.clear();
          newPassword.clear();
          confirmPassword.clear();
          /*
          * invalid password
          * */
        } else if (data['status'] == '3')
          CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('current_password_not_match')}');
        /*
        * server error
        * */
        else
          CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('something_went_wrong')}');
      }
      /*
      * password not match
      * */
      else
        CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('password_not_match')}');
    } else {
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('password_too_short')}');
    }
  }
}
