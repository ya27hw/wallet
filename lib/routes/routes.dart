import 'package:eth_wallet/main.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/login/library.dart' as login;

const String splashLogin = "splashLogin";
const String importWallet = "importWallet";

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case splashLogin:
      return MaterialPageRoute(builder: (context) => const login.SplashLogin());

    case importWallet:
      return MaterialPageRoute(
          builder: (context) => const login.ImportWallet());

    default:
      throw ("Error no route");
  }
}
