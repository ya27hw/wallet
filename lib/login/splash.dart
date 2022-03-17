import 'package:eth_wallet/util/library.dart' as utils;
import 'package:flutter/material.dart';

class SplashLogin extends StatefulWidget {
  const SplashLogin({Key? key}) : super(key: key);

  @override
  _SplashLoginState createState() => _SplashLoginState();
}

class _SplashLoginState extends State<SplashLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF1B1E38)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: utils.getHeight(context) * 0.17),
            child: const Text(
              "Crypto Wallet",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: utils.getHeight(context) * 0.1),
            child: const Text(
              "Begin your crypto journey today.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: utils.getHeight(context) * 0.3),
              child: utils.Helper().Button(utils.getWidth(context),
                  "Import a Wallet", context, "importWallet")),
          Container(
              padding: const EdgeInsets.only(top: 30),
              child: utils.Helper().Button(utils.getWidth(context),
                  "Create a Wallet", context, "createWallet")),
          Container(
              padding: const EdgeInsets.only(top: 30),
              child: utils.Helper().Button(utils.getWidth(context),
                  "Portfolio (dev)", context, "portfolio")),
        ],
      ),
    ));
  }
}
