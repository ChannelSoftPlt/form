import 'dart:async';

import 'dart:io' show Platform;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my/fragment/group/group.dart';
import 'package:my/fragment/order/order.dart';
import 'package:my/fragment/order/searchPage.dart';
import 'package:my/fragment/product/product.dart';
import 'package:my/fragment/product/product_filter.dart';
import 'package:my/fragment/setting/settingFragment.dart';
import 'package:my/fragment/user/user.dart';
import 'package:my/object/category.dart';
import 'package:my/object/driver.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/notification_plugin.dart';
import 'package:my/shareWidget/filter_dialog.dart';
import 'package:my/shareWidget/not_found.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Category category;
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /*
  * product sequence order
  * */
  int orderType = 0;
  var appLanguage;

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

    setupNotification();
  }

  Future<void> setupNotification() async {
    //initialize
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);

    notificationPlugin.setOnNotificationClick(setOnNotificationClick);

    // Update the iOS foreground notification presentation options to allow
    // heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('on message: $message');
      _setupNotificationSound(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('on message open app: $message');
      setState(() {
        currentIndex = 0;
      });
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      print('initialize message: $message');
      if (message != null) {}
    });

    if (Platform.isIOS) {
      _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    /*
    * register token
    * */
    _firebaseMessaging.getToken().then((token) async {
      await SharePreferences().save('token', token);
      await Domain().registerDeviceToken(token);
    });
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('lower version: $receivedNotification');
  }

  setOnNotificationClick(String payload) {
    print('payload here: $payload');
  }

  _setupNotificationSound(message) async {
    print('message');
    Merchant merchant =
        Merchant.fromJson(await SharePreferences().read('merchant'));
    String merchantId = merchant.merchantId;
    if (merchant != null) {
      if (message.data['merchant_id'] != merchantId) return;
      showSnackBar(
          '${AppLocalizations.of(context).translate('new_order_received')}',
          '${AppLocalizations.of(context).translate('see_now')}');
      final assetsAudioPlayer = AssetsAudioPlayer();
      assetsAudioPlayer.open(
        Audio("audio/notification.mp3"),
      );
      FlutterAppBadger.updateBadgeCount(1);
    }
  }

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
        elevation: currentIndex == 0 || currentIndex == 3 ? 0 : 2,
        title: Text(getTitle(),
            textAlign: TextAlign.center,
            style: GoogleFonts.cantoraOne(
              textStyle: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            'drawable/new_logo.jpg',
            height: 50,
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible:
                currentIndex == 1 || currentIndex == 0 || currentIndex == 3,
            child: IconButton(
              icon: Icon(
                Icons.sort,
                color: Colors.orange,
              ),
              onPressed: () {
                showFilterDialog(context);
                // do something
              },
            ),
          ),
          Visibility(
            visible: currentIndex == 4,
            child: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: Colors.orange,
              ),
              onPressed: () {
                print(url);
                launch((url));
              },
            ),
          ),
          Visibility(
            visible: currentIndex != 4,
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
            label: '${AppLocalizations.of(context).translate('order')}',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '${AppLocalizations.of(context).translate('group')}',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '${AppLocalizations.of(context).translate('customer')}',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: '${AppLocalizations.of(context).translate('product')}',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '${AppLocalizations.of(context).translate('setting')}',
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
        title: '${AppLocalizations.of(context).translate('no_network_found')}',
        description:
            '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () {
          setState(() {});
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
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
          query: ''),
      UserPage(
        query: '',
      ),
      ProductPage(
        query: '',
        orderType: orderType,
        categoryName: category != null ? category.name : '',
      ),
      SettingFragment()
    ];
  }

  String getTitle() {
    switch (currentIndex) {
      case 0:
        return '${AppLocalizations.of(context).translate('order')}';
        break;
      case 1:
        return '${AppLocalizations.of(context).translate('group')}';
        break;
      case 2:
        return '${AppLocalizations.of(context).translate('customer')}';
        break;
      case 3:
        return '${AppLocalizations.of(context).translate('product')}';
        break;
      default:
        return '${AppLocalizations.of(context).translate('setting')}';
    }
  }

  getUrl() async {
    this.url = Merchant.fromJson(await SharePreferences().read("merchant")).url;
    shareContent.text =
        '${AppLocalizations.of(context).translate('welcome_visit_my_store')}\n$url';
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
          title:
              Text("${AppLocalizations.of(context).translate('share_link')}"),
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
                      labelText:
                          '${AppLocalizations.of(context).translate('content')}',
                      labelStyle:
                          TextStyle(fontSize: 16, color: Colors.blueGrey),
                      hintText:
                          '${AppLocalizations.of(context).translate('write_share_content')}',
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
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('share')}',
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
        return 'order';
      case 1:
        return 'group';
      case 2:
        return 'customer';
      default:
        return 'product';
    }
  }

  showFilterDialog(mainContext) {
    // flutter defined function
    if (currentIndex != 3) {
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
    } else
      showDialog(
        context: mainContext,
        builder: (BuildContext context) {
          // return alert dialog object
          return ProductFilter(
            category: category,
            orderType: orderType,
            onClick: (status, category, orderType) async {
              await Future.delayed(Duration(milliseconds: 300));
              Navigator.pop(mainContext);
              setState(() {
                this.category = category;
                this.orderType = orderType;
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
