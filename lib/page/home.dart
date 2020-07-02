

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/order/order.dart';
import 'package:my/fragment/order/searchPage.dart';
import 'package:my/fragment/setting/settingFragment.dart';
import 'package:my/page/login.dart';

class HomePage extends StatefulWidget {
  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<HomePage> {
  List<Widget> _children = [OrderPage(), LoginPage(), SettingFragment()];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          getTitle(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 25),
        )
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset('drawable/logo.jpg', height: 5,),
        ),
        actions: <Widget>[
          Visibility(
            visible: currentIndex == 0,
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
          )
        ],
      ),
      body: _children[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orangeAccent,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Order'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            title: Text('Others'),
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

  String getTitle() {
    switch (currentIndex) {
      case 0:
        return 'Order';
        break;
      case 1:
        return 'Others';
        break;
      default:
        return 'Setting';
    }
  }

  openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(),
      ),
    );
  }
}
