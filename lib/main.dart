import 'package:flutter/material.dart';
import 'package:eth_wallet/login/library.dart' as login;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    themeMode: ThemeMode.system,
    theme: ThemeData(brightness: Brightness.light, fontFamily: "Oswald"),
    darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: "Oswald"),
    home: MyHomePage(),
    debugShowCheckedModeBanner: false,
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => login.SplashLogin();
}
