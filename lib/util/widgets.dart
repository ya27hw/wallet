import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class Helper {
  Widget Button(double width, String msg,
      [BuildContext? ctx, String? routeName]) {
    return ElevatedButton(
      child: Text(msg),
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 17),
        padding: EdgeInsets.symmetric(horizontal: width * 0.20, vertical: 15),
        onPrimary: Colors.black,
        primary: const Color(0xFF41CD7D),
        onSurface: Colors.grey,
        // side: BorderSide(color: Colors.black, width: 1),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      onPressed: () {
        if (ctx != null && routeName != null) {
          Navigator.pushNamed(ctx, routeName);
        }
      },
    );
  }

  Future showADialog(BuildContext context, String title, String content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // This is used to display the card which contains the main balance
  Widget mainBalance(double w, double balance, double change) {
    BalanceIndicator mbi = BalanceIndicator();

    if (change > 0) {
      mbi.color = Colors.greenAccent;
      mbi.symbol = "+";
    } else if (change < 0) {
      mbi.color = Colors.redAccent;
      mbi.symbol = "-";
    } else {
      mbi.color = Colors.grey;
      mbi.symbol = "";
    }

    return Center(
        child: Container(
      width: w - 50,
      decoration: const BoxDecoration(
          color: Color(0xFF32385F),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(
                LineIcons.wallet,
                size: 50,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Wallet Balance (USD)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "\$$balance",
                  style: const TextStyle(fontSize: 40),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      color: mbi.color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  child: Text("${mbi.symbol}$change%"),
                )
              ]),
          Container(
            padding: const EdgeInsets.only(top: 13),
            child: const Text(
              "8.2348 ETH",
              style: TextStyle(fontSize: 19, color: Colors.white70),
            ),
          )
        ],
      ),
    ));
  }

  // this is used to display the card which contains a tokens balance
  Widget balanceCards(double w, double balance, double currencyMarketPrice,
      double balanceFiat, double change) {
    return Container(
      foregroundDecoration: const RotatedCornerDecoration(
        color: Colors.greenAccent,
        geometry: BadgeGeometry(width: 45, height: 45, cornerRadius: 10, alignment: BadgeAlignment.bottomRight),
      ),
      decoration: BoxDecoration(
          color: secondaryDarkColor(),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      width: w - 50,
      child: Card(

        elevation: 5,
        color: secondaryDarkColor(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(
                LineIcons.ethereum,
                size: 40,
              ),
              title: Text('$balance ETH'),
              subtitle: Text('\$$balanceFiat'),
            ),
          ],
        ),
      ),
    );
  }
}
