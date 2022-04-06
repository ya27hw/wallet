import 'package:eth_wallet/home/receive.dart';
import "package:flutter/material.dart";
import 'package:eth_wallet/util/library.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_wallet/backend/library.dart' as backend;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    // monitor network fetch
    return await Future.delayed(const Duration(milliseconds: 2000));
  }

  Future<void> getData() async {
    // Retrieve Main Token Balance
    // Retrieve other Tokens Balance
    // Basically it

    final tokenBox = Hive.box("tokenBox");
    String defNetwork = backend.Web3().defaultNetwork;
    // Get all tokens of defaultNetwork
    final allTokens = tokenBox.get("defNetwork");
    List<Token> tokens = [];

    // Iterate through keys of allTokens
    for (var key in allTokens.keys) {
      Token temp = allTokens[key] as Token;
      tokens.add(temp);
    }

    List<TokenInfo> tokenInfoList = await backend.Web3().getTokenPricesBatch(tokens);
  }

  Widget mainColumn() {
    return Column(
      children: <Widget>[
        // Main Balance Card (MBC)
        Padding(
            padding: const EdgeInsets.only(top: 35),
            child: FutureBuilder<Map<String, double>>(
              future: backend.Web3().mainBalanceCard(),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, double>> snapshot) {
                Widget data;
                if (snapshot.hasData) {
                  double mainTokenBalance = snapshot.data!["mainTokenBalance"]!;
                  double nativeTokenPrice = snapshot.data!["nativeTokenPrice"]!;

                  data = Helper().mainBalance(getWidth(context),
                      (nativeTokenPrice), 9.99, mainTokenBalance);
                } else if (snapshot.hasError) {
                  data = const Text("Error");
                } else {
                  data = const Text('Awaiting result...');
                }
                return data;
              },
            )),
        // Extra space between tokens and MBC
        const Padding(
          padding: EdgeInsets.only(top: 40),
        ),
        FutureBuilder<double>(
          future: backend.Web3()
              .getTokenPrice("0x1f9840a85d5af5bf1d1762f925bdaddc4201f984", 12),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            Widget data;
            if (snapshot.hasData) {
              double tokenPrice = snapshot.data!;
              data = Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                width: getWidth(context),
                child: Helper().balanceCards(
                    getWidth(context), 1, 9, snapshot.data!, 8, "UNI"),
              );
            } else if (snapshot.hasError) {
              data = const Text("Error");
            } else {
              data = const Text('Awaiting result...');
            }
            return data;
          },
        ),

        // Expanded(
        //     child: ListView.builder(
        //         shrinkWrap: true,
        //         itemCount: 6,
        //         itemBuilder: (context, p) {
        //           return Container(
        //             padding: const EdgeInsets.symmetric(
        //                 horizontal: 25, vertical: 5),
        //             width: getWidth(context),
        //             child: Helper()
        //                 .balanceCards(getWidth(context), 0, 0, 0, 0),
        //           );
        //         })),
      ],
    );
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
        body: LiquidPullToRefresh(
          onRefresh: _onRefresh,
          child: SafeArea(child: mainColumn()),
        ),
      ),
    );
  }
}
