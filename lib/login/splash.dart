import 'package:eth_wallet/login/import_wallet.dart';
import 'package:eth_wallet/util/library.dart' as widgets;
import 'package:flutter/material.dart';

class SplashLogin extends StatefulWidget {
  const SplashLogin({Key? key}) : super(key: key);

  @override
  _SplashLoginState createState() => _SplashLoginState();
}

class _SplashLoginState extends State<SplashLogin> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF202442)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: height * 0.17),
            child: const Text(
              "Crypto Wallet",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.1),
            child: const Text(
              "Begin your crypto journey today.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: height * 0.3),
              child: widgets.Helper().Button(width, "Import a Wallet", context, MaterialPageRoute(builder: (context) => const ImportWallet()))
          ),
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: widgets.Helper().Button(width, "Create a Wallet")
          ),

        ],
      ),
    ));
  }
}
