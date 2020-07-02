import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/setting/reset_password.dart';
import 'package:my/page/loading.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingFragment extends StatefulWidget {
  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  String _platformVersion = 'Default';
  bool isButtonPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'User Detail',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                    leading: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.blue,
                    ),
                    title: Text(
                      'Edit Profile',
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
                      'Change Password',
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
                  height: 20,
                ),
                Text(
                  'Settings',
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
                      'Notification',
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
                  height: 20,
                ),
                Text(
                  'About the App',
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
                      'Contact Us',
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
                    onTap: () => launch(
                        ('https://www.channelsoft.com.my/privacy-policy/')),
                    title: Text(
                      'Privacy Policy',
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
                Column(
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
                              'Log Out',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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
                      'All Right Reserved By CHANNEL SOFT PLT',
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
                ),
              ],
            ),
          ),
        ));
  }

  getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print(version);
    setState(() {
      _platformVersion = version;
    });
  }

  Future<void> showLogOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out Request'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure that you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Confirm',
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

  logOut() {
    SharePreferences().clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoadingPage()),
        ModalRoute.withName('/'));
  }
}
