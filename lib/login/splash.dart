import 'package:eth_wallet/util/library.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              "Ethereum Wallet",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: utils.getHeight(context) * 0.04),
            child: const Text(
              "Begin your crypto journey today.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: SvgPicture.asset(
              "assets/media/coin_wallet.svg",
              height: 150,
              width: 150,
              color: const Color(0xFF41CD7D),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: utils.getHeight(context) * 0.15),
              child: utils.Helper().Button(utils.getWidth(context),
                  "Import a Wallet", context, "importWallet")),
          Container(
              padding: const EdgeInsets.only(top: 30),
              child: utils.Helper().Button(utils.getWidth(context),
                  "Create a Wallet", context, "createWallet")),
        ],
      ),
    ));
  }
}
