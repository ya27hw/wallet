import 'package:flutter/material.dart';
import 'dart:ui';

class SplashLogin extends StatefulWidget {
  const SplashLogin({Key? key}) : super(key: key);

  @override
  _SplashLoginState createState() => _SplashLoginState();
}

class _SplashLoginState extends State<SplashLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Splash Login'),
      ),
      body: Text("I love this app!"),
    );
  }
}
