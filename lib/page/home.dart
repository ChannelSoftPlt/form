import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my/fragment/group/group.dart';
import 'package:my/fragment/order/order.dart';
import 'package:my/fragment/order/searchPage.dart';
import 'package:my/fragment/product/product.dart';
import 'package:my/fragment/setting/settingFragment.dart';
import 'package:my/fragment/user/user.dart';
import 'package:my/object/driver.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/notification_plugin.dart';
import 'package:my/shareWidget/filter_dialog.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<HomePage> {
  final key = new GlobalKey<ScaffoldState>();

  /*
  * filter purpose
  * */
  var startDate, endDate;
  Driver driver;
  final selectedDateFormat = DateFormat("yyy-MM-dd");

  int currentIndex = 0;
  String url;
  var shareContent = TextEditingController();

  /*
  * network checking purpose
  * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  /*
  * firebase messaging
  * */
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static Future<dynamic> backgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      await notificationPlugin.showNotification(message['data']);
    }
// Or do other work.
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUrl();

    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
      });
    });

    //initialize
//    notificationPlugin
//        .setListenerForLowerVersions(onNotificationInLowerVersions);
//    notificationPlugin.setOnNotificationClick(setOnNotificationClick);

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _setupNotificationSound(message);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onBackgroundMessage: backgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        setState(() {
          currentIndex = 0;
        });
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    /*
    * register token
    * */
    _firebaseMessaging.getToken().then((token) async {
      Map data = await Domain().registerDeviceToken(token);
      print(data);
    });
  }

  _setupNotificationSound(message) async {
    print(message['data']);
    Merchant merchant =
        Merchant.fromJson(await SharePreferences().read('merchant'));

    if (merchant != null &&
        message['data']['merchant_id'] ==
            Merchant.fromJson(await SharePreferences().read("merchant"))
                .merchantId) {
      showSnackBar('New Order Received', 'See Now');
      final assetsAudioPlayer = AssetsAudioPlayer();
      assetsAudioPlayer.open(
        Audio("audio/notification.mp3"),
      );
    }
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}

  setOnNotificationClick(String payload) {}

  // Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    connectivity.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(getTitle(),
            textAlign: TextAlign.center,
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            'drawable/logo.jpg',
            height: 50,
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible: currentIndex == 1 || currentIndex == 0,
            child: IconButton(
              icon: Icon(
                Icons.sort,
                color: Colors.orange,
              ),
              onPressed: () {
                showDriverDialog(context);
                // do something
              },
            ),
          ),
          Visibility(
            visible: currentIndex != 4 || currentIndex != 3,
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.orange,
              ),
              onPressed: () {
                openSearchPage();
                // do something
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.orange,
            ),
            onPressed: () {
              openShareDialog(context);
//              Share.share('$url');
              // do something
            },
          )
        ],
      ),
      body: networkConnection ? pageList()[currentIndex] : notFound(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orangeAccent,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Order'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            title: Text('Group'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Customer'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            title: Text('Product'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
          ),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget notFound() {
    return NotFound(
        title: 'No Network Found!',
        description:
            'We can\'t detect any network connection from your device...',
        showButton: true,
        refresh: () {
          setState(() {});
        },
        button: 'Retry',
        drawable: 'drawable/no_wifi.png');
  }

  List<Widget> pageList() {
    return [
      OrderPage(
        startDate: startDate != null
            ? selectedDateFormat.format(startDate).toString()
            : '',
        endDate: endDate != null
            ? selectedDateFormat.format(endDate).toString()
            : '',
        driverId: driver != null ? driver.driverId.toString() : '',
      ),
      GroupPage(
        startDate: startDate != null
            ? selectedDateFormat.format(startDate).toString()
            : '',
        endDate: endDate != null
            ? selectedDateFormat.format(endDate).toString()
            : '',
        query: ''
      ),
      UserPage(
        query: '',
      ),
      ProductPage(
        query: '',
      ),
      SettingFragment()
    ];
  }

  String getTitle() {
    switch (currentIndex) {
      case 0:
        return 'Order';
        break;
      case 1:
        return 'Group';
        break;
      case 2:
        return 'Customer';
        break;
      case 3:
        return 'Product';
        break;
      default:
        return 'Setting';
    }
  }

  getUrl() async {
    this.url = Merchant.fromJson(await SharePreferences().read("merchant")).url;

    shareContent.text = 'Welcome to visit My Store!\n$url';
    setState(() {});
  }

  /*
  * edit product dialog
  * */
  openShareDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Share Link"),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.orange,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: shareContent,
                    textAlign: TextAlign.start,
                    minLines: 1,
                    maxLines: 5,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.textsms),
                      labelText: 'Content',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.blueGrey),
                      hintText: 'Write some content to share..',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                ),
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
                'Share',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Share.share(shareContent.text);
              },
            ),
          ],
        );
      },
    );
  }

  openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          type: getSearchType(),
        ),
      ),
    );
  }

  String getSearchType() {
    switch (currentIndex) {
      case 0:
        return 'Order';
      case 1:
        return 'Group';
      default:
        return 'User';
    }
  }

  showDriverDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return FilterDialog(
          showDriver: currentIndex != 1,
          fromDate: this.startDate,
          toDate: this.endDate,
          driver: this.driver,
          onClick: (fromDate, toDate, driver) async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(mainContext);
            setState(() {
              this.startDate = fromDate;
              this.endDate = toDate;
              this.driver = driver;
            });
          },
        );
      },
    );
  }

  showSnackBar(message, button) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(message),
        action: SnackBarAction(
          label: button,
          onPressed: () {
            setState(() {
              currentIndex = 0;
            });
            // Some code to undo the change.
          },
        )));
  }
}
