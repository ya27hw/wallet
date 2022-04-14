import 'package:eth_wallet/backend/ethplorer.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TokenInfoPage extends StatefulWidget {
  final TokenInfo tokenInfo;

  const TokenInfoPage({Key? key, required this.tokenInfo}) : super(key: key);

  @override
  State<TokenInfoPage> createState() => _TokenInfoPageState();
}

class _TokenInfoPageState extends State<TokenInfoPage> {
  Future<Map<dynamic, dynamic>>? _tokenInfoFuture;
  Future<Map<dynamic, dynamic>>? _tokenPriceHistoryFuture;

  @override
  void initState() {
    super.initState();
    _tokenInfoFuture = _getTokenInfo();
    _tokenPriceHistoryFuture = _getTokenPriceHistoryGrouped();
  }

  @override
  Widget build(BuildContext context) {
    Token tempToken = widget.tokenInfo.token;
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            FutureBuilder<Map<dynamic, dynamic>>(
                future: _tokenInfoFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    Map<dynamic, dynamic> data = snapshot.data!;
                    return Helper().tokenDescriptionCard(
                      getWidth(context),
                      data["price"] is bool
                          ? widget.tokenInfo.priceUSD
                          : data["price"]["rate"],
                      data["price"] is bool ? 0 : data["price"]["diff"],
                      widget.tokenInfo.balance,
                      data["name"],
                      data["symbol"],
                      data.containsKey("image")
                          ? "https://ethplorer.io/${data["image"]}"
                          : "",
                      data.containsKey("description")
                          ? data["description"]
                          : null,
                      data.containsKey("website") ? data["website"] : null,
                      data.containsKey("reddit") ? data["reddit"] : null,
                      data.containsKey("twitter") ? data["twitter"] : null,
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            const Padding(padding: EdgeInsets.only(top: 20)),
            FutureBuilder<Map>(
                future: _tokenPriceHistoryFuture,
                builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                  if (snapshot.hasData) {
                    try {
                      Map data = snapshot.data!;
                      var priceData = data["history"]["prices"];
                      if (priceData is bool) {
                        // Data is empty
                        return Container();
                      } else {
                        priceData = priceData as List;
                      }

                      num minimum = double.infinity;
                      List<TokenChartData> chartData = [];
                      for (var i = 0; i < priceData.length; i++) {
                        num open = priceData[i]["open"];
                        num close = priceData[i]["close"];
                        num high = priceData[i]["high"];
                        num low = priceData[i]["low"];
                        num minValue = [open, close, high, low].reduce(min);
                        if (minValue < minimum) {
                          minimum = minValue;
                        }
                        TokenChartData temp = TokenChartData(
                          ts: priceData[i]["ts"],
                          date: priceData[i]["date"],
                          hour: priceData[i]["hour"],
                          open: open,
                          close: close,
                          high: high,
                          low: low,
                          volume: priceData[i]["volume"],
                          volumeConverted: priceData[i]["volumeConverted"],
                          cap: priceData[i]["cap"],
                          average: priceData[i]["average"],
                        );
                        chartData.add(temp);
                      }
                      return Helper().candleChart(
                          chartData, minimum.floor(), getWidth(context));
                    } catch (e) {
                      print(e);
                      return Container();
                    }
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  } else {
                    return Container();
                  }
                }),
            const Padding(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }

  Future<Map<dynamic, dynamic>> _getTokenInfo() async {
    dynamic response = await Ethplorer()
        .getFromAPI("getTokenInfo", widget.tokenInfo.token.address);
    // Loop through map keys
    if (response == null) {
      // Return empty map
      return {};
    }
    return response as Map<dynamic, dynamic>;
  }

  Future<Map<dynamic, dynamic>> _getTokenPriceHistoryGrouped() async {
    dynamic response = await Ethplorer().getFromAPI(
        "getTokenPriceHistoryGrouped", widget.tokenInfo.token.address, {
      "period": "10",
    });

    if (response == null) {
      // Return empty map
      return {};
    }
    return response as Map<dynamic, dynamic>;
  }
}
