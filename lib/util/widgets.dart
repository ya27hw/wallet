import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import "dart:core";

import 'package:url_launcher/url_launcher.dart';

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

  Widget transactionCard(TransactionData t) {
    return Card(
      elevation: 5,
      color: secondaryDarkColor(),
      child: ListTile(
        leading: t.transactionType == TransactionType.send
            ? const Icon(
                LineIcons.arrowCircleUp,
                size: 35,
              )
            : const Icon(
                LineIcons.alternateExchange,
                size: 35,
              ),
        title: Text("Sent ${t.value} ${t.sentTokenSymbol}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${t.transactionType == TransactionType.send ? "To" : "From"} ${displayAddress(t.to)}"),
            Text(
              DateFormat.yMMMMd()
                  .add_jm()
                  .format(DateTime.fromMillisecondsSinceEpoch(t.epoch)),
            )
          ],
        ),
        trailing: IconButton(
          icon: const Icon(LineIcons.infoCircle),
          onPressed: () async {
            await launch("https://ropsten.etherscan.io/tx/${t.hash}");
          },
        ),
      ),
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

  Widget tokenDescriptionCard(num w, num balance, num change,
      num tokenBalance, String tokenName, String symbol, String imageUrl,
      [String? description, String? website, String? reddit, String? twitter]) {
    BalanceIndicator mbi = BalanceIndicator();

    if (change > 0) {
      mbi.color = const Color(0xFF41CD7D);
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
              children: [
                imageUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 25,
                      )
                    : const Icon(
                        LineIcons.ethereum,
                        size: 50,
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "$tokenName ($symbol)",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "\$${formatDouble(balance, 2)}",
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
            description != null
                ? Container(
                    padding: const EdgeInsets.only(top: 13),
                    child: Text(
                      description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : Container(),
            const Padding(padding: EdgeInsets.only(top: 20)),
            snsButtonRow(website, reddit, twitter),
          ],
        ),
      ),
    );
  }

  Widget snsButtonRow([String? website, String? twitter, String? reddit]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        website != null
            ? RawMaterialButton(
                onPressed: () {
                  // Open link in browser
                  launch(website);
                },
                elevation: 2.0,
                fillColor: primaryDarkColor(),
                child: const Icon(
                  LineIcons.globe,
                  size: 25.0,
                ),
                padding: const EdgeInsets.all(15),
                shape: const CircleBorder(),
              )
            : Container(),
        reddit != null
            ? RawMaterialButton(
                onPressed: () {
                  // Open link in browser
                  launch("https://www.reddit.com/r/$reddit");
                },
                elevation: 2.0,
                fillColor: primaryDarkColor(),
                child: const Icon(
                  LineIcons.redditAlien,
                  size: 25.0,
                ),
                padding: const EdgeInsets.all(15),
                shape: const CircleBorder(),
              )
            : Container(),
        twitter != null
            ? RawMaterialButton(
                onPressed: () {
                  // Open link in browser
                  launch("https://twitter.com/$twitter");
                },
                elevation: 2.0,
                fillColor: primaryDarkColor(),
                child: const Icon(
                  LineIcons.twitter,
                  size: 25.0,
                ),
                padding: const EdgeInsets.all(15),
                shape: const CircleBorder(),
              )
            : Container(),
      ],
    );
  }

  // This is used to display the card which contains the main balance
  Widget mainBalance(double w, double balance, double change,
      double tokenBalance, String symbol) {
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
                  "Wallet Balance",
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
            child: Text(
              "$tokenBalance $symbol",
              style: const TextStyle(fontSize: 19, color: Colors.white70),
            ),
          )
        ],
      ),
    ));
  }

  Widget candleChart(List<TokenChartData> data, num minimum, double w) {
    return Center(
        child: Container(
      width: w - 50,
      decoration: const BoxDecoration(
          color: Color(0xFF32385F),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
      child: SfCartesianChart(
        trackballBehavior: TrackballBehavior(
            enable: true, activationMode: ActivationMode.singleTap),
        crosshairBehavior: CrosshairBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
        ),
        series: <CandleSeries>[
          CandleSeries<TokenChartData, DateTime>(
            dataSource: data,
            xValueMapper: (TokenChartData sales, _) =>
                DateTime.parse(sales.date!),
            lowValueMapper: (TokenChartData sales, _) => sales.low,
            highValueMapper: (TokenChartData sales, _) => sales.high,
            openValueMapper: (TokenChartData sales, _) => sales.open,
            closeValueMapper: (TokenChartData sales, _) => sales.close,
          ),
        ],
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          // enablePanning: true,
          // enableSelectionZooming: true,
          // enableDoubleTapZooming: true,
        ),
        primaryYAxis: NumericAxis(
          minimum: minimum.toDouble(),
          rangePadding: ChartRangePadding.additional,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat.MMMd(),
            majorGridLines: const MajorGridLines(width: 0)),
      ),
    ));
  }

  // this is used to display the card which contains a tokens balance
  Widget balanceCards(double w, double balance, double currencyMarketPrice,
      double balanceFiat, double change, String tokenSymbol) {
    return Container(
      foregroundDecoration: const RotatedCornerDecoration(
        color: Color(0xFF41CD7D),
        geometry: BadgeGeometry(
            width: 45,
            height: 45,
            cornerRadius: 10,
            alignment: BadgeAlignment.bottomRight),
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
              title: Text('$balance $tokenSymbol'),
              subtitle: Text('\$$balanceFiat'),
            ),
          ],
        ),
      ),
    );
  }
}
