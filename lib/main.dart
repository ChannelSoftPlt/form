import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my/page/home.dart';
import 'package:my/page/loading.dart';
import 'package:my/page/login.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/translation/appLanguage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling haha');
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          locale: model.appLocal,
          supportedLocales: [
            Locale('en', ''),
            Locale('zh', ''),
            Locale('ms', ''),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.orange,
          ),
          routes: {
            '/': (context) => LoadingPage(),
            '/home': (context) => HomePage(),
            '/login': (context) => LoginPage()
          },
        );
      }),
    );
  }
}
