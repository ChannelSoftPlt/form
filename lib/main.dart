import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my/page/home.dart';
import 'package:my/page/loading.dart';
import 'package:my/page/login.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.orange,
      ),
      routes: {
        '/': (context) => LoadingPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage()
      },
    ));
