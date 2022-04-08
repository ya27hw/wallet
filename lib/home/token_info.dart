import 'package:eth_wallet/backend/ethplorer.dart';
import 'package:eth_wallet/home/library.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';

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
    //_tokenPriceHistoryFuture = _getTokenPriceHistoryGrouped();
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
                        widget.tokenInfo.priceUSD * widget.tokenInfo.balance,
                        data["price"] is bool ? 0 : data["price"]["diff"],
                        widget.tokenInfo.balance,
                        data["name"],
                        data["symbol"],
                        data.containsKey("image")
                            ? "https://ethplorer.io/${data["image"]}"
                            : "");
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            const Padding(padding: EdgeInsets.only(top: 20)),
            FutureBuilder<Map<dynamic, dynamic>>(
                future: _tokenPriceHistoryFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    // TODO construct graph
                    Map<dynamic, dynamic> data = snapshot.data!;
                    print(data);
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            Helper().candleChart(0),
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
      "period": "1",
    });

    if (response == null) {
      // Return empty map
      return {};
    }
    return response as Map<dynamic, dynamic>;
  }
}
