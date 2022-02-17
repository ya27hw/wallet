import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eth_wallet/login/library.dart' as login;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      //brightness: Brightness.dark,
      colorScheme: ThemeData().colorScheme.copyWith(primary: Color(0xFF41CD7D), brightness: Brightness.dark)
    ),

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
