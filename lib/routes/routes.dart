import 'package:eth_wallet/main.dart';
import 'package:eth_wallet/util/classes.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/login/library.dart' as login;
import 'package:eth_wallet/home/library.dart' as home;

const String splashLogin = "splashLogin";
const String importWallet = "importWallet";
const String importWalletTwo = "importWalletTwo";
const String createWallet = "createWallet";
const String portfolio = "portfolio";

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case splashLogin:
      return MaterialPageRoute(builder: (context) => const login.SplashLogin());

    case importWallet:
      return MaterialPageRoute(
          builder: (context) => const login.ImportWallet());
    case importWalletTwo:
      return MaterialPageRoute(
          builder: (context) => login.ImportWalletTwo(
                accountList: settings.arguments,
              ));

    case createWallet:
      return MaterialPageRoute(
          builder: (context) => const login.CreateWallet());

    case portfolio:
      return MaterialPageRoute(builder: (context) => const home.Portfolio());

    default:
      throw ("Error no route");
  }
}
