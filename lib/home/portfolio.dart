import 'package:eth_wallet/home/receive.dart';
import "package:flutter/material.dart";
import 'package:eth_wallet/util/library.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_wallet/backend/library.dart' as backend;

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  Future<List<Widget>>? _future;

  @override
  void initState() {
    _future = getData();
    super.initState();
  }

  Future<List<Widget>> getData() async {
    // Retrieve Main Token Balance
    // Retrieve other Tokens Balance
    // Return Widget containing both;

    final mainBalance = await backend.Web3().mainBalanceCard();
    double mainTokenBalance = mainBalance["mainTokenBalance"]!;
    double nativeTokenPrice = mainBalance["nativeTokenPrice"]!;

    final mainBalanceCard = Helper()
        .mainBalance(getWidth(context), nativeTokenPrice, 0, mainTokenBalance);

    final tokenBox = Hive.box("tokenBox");
    String defNetwork = backend.Web3().defaultNetwork;
    // Get all tokens of defaultNetwork
    final tokens = tokenBox.get(defNetwork);
    List<Token> allTokens = List.castFrom(tokens);
    // Iterate through keys of allTokens

    if (allTokens.isEmpty) {
      return <Widget>[
        mainBalanceCard,
        const Padding(padding: EdgeInsets.only(top: 50)),
      ];
    }

    List<TokenInfo> tokenInfoList =
        await backend.Web3().getTokenPricesBatch(allTokens);

    final tokenListViewBuilder = ListView.builder(
        shrinkWrap: true,
        itemCount: tokenInfoList.length,
        itemBuilder: (context, p) {
          final temp = tokenInfoList[p];
          final tempToken = temp.token;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            width: getWidth(context),
            child: Helper().balanceCards(
                getWidth(context),
                temp.balance,
                temp.priceUSD,
                temp.balance * temp.priceUSD,
                0,
                tempToken.symbol),
          );
        });

    return [
      mainBalanceCard,
      const Padding(padding: EdgeInsets.only(top: 50)),
      tokenListViewBuilder
    ];
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> dialOpen = ValueNotifier(false);

    return WillPopScope(
      onWillPop: () async {
        if (dialOpen.value) {
          dialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        // Floating Action Button (FAB)
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_arrow,
          openCloseDial: dialOpen,
          backgroundColor: Colors.redAccent,
          overlayColor: primaryDarkColor(),
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 9,
          closeManually: true,
          children: [
            SpeedDialChild(
                child: const Icon(LineIcons.plus),
                label: 'Add Token',
                labelBackgroundColor: secondaryDarkColor(),
                backgroundColor: secondaryDarkColor(),
                onTap: () {
                  Navigator.pushNamed(context, 'addToken');
                  setState(() {
                    dialOpen.value = false;
                  });
                }),
            SpeedDialChild(
                child: const Icon(LineIcons.arrowDown),
                label: 'Receive',
                labelBackgroundColor: secondaryDarkColor(),
                backgroundColor: secondaryDarkColor(),
                onTap: () {
                  setState(() {
                    dialOpen.value = false;
                  });
                  showModalBottomSheet(
                      backgroundColor: primaryDarkColor(),
                      context: context,
                      builder: (context) {
                        return receive();
                      });
                }),
            SpeedDialChild(
                child: const Icon(LineIcons.arrowUp),
                labelBackgroundColor: secondaryDarkColor(),
                backgroundColor: secondaryDarkColor(),
                label: 'Send',
                onTap: () {
                  Navigator.pushNamed(context, 'send');

                  setState(() {
                    dialOpen.value = false;
                  });
                }),
          ],
        ),
        backgroundColor: const Color(0xFF1B1E38),
        // The appbar
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            "My Wallet",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF32385F),
        ),
        drawer: Drawer(
          backgroundColor: primaryDarkColor(),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: secondaryDarkColor(),
                ),
                child: const Text('My Wallet'),
              ),
              ListTile(
                title: Wrap(
                  spacing: 20,
                  children: const [
                    Icon(
                      LineIcons.wallet,
                      size: 20,
                    ),
                    Text(
                      "Wallet",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Wrap(
                  spacing: 20,
                  children: const [
                    Icon(
                      LineIcons.history,
                      size: 20,
                    ),
                    Text(
                      "Activity",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Wrap(
                  spacing: 20,
                  children: const [
                    Icon(
                      Icons.logout,
                      size: 20,
                    ),
                    Text(
                      "Log Out",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
                onTap: () async {
                  await deleteFile("wallet.json");
                  Navigator.pushNamedAndRemoveUntil(
                      context, "splashLogin", (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 35),
            child: FutureBuilder<List<Widget>>(
              future: _future,
              builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!,
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _refreshProducts(BuildContext context) async {
    setState(() {
      _future = getData();
    });
    await _future;
  }
}
