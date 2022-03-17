import "package:flutter/material.dart";
import 'package:eth_wallet/util/library.dart' as widgets;

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E38),
      // appBar: AppBar(
      //   title: const Center(child: Text("My Wallet", style: TextStyle(color: Colors.white),)),
      //   backgroundColor: const Color(0xFF32385F),
      //   automaticallyImplyLeading: false,
      // ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: widgets.Helper()
                  .mainBalance(widgets.getWidth(context), 99999.99, -99.99),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: widgets.Helper()
                  .balanceCards(widgets.getWidth(context), 0.50032, 2803.30, 1402.55, 1.03),
            ),
          ],
        ),
      ),
    );
  }
}
