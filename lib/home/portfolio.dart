import "package:flutter/material.dart";
import 'package:eth_wallet/util/library.dart' as widgets;
import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_wallet/backend/library.dart' as backend;

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
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
          overlayColor: widgets.primaryDarkColor(),
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 9,
          closeManually: true,
          children: [
            SpeedDialChild(
                child: const Icon(LineIcons.arrowDown),
                label: 'Receive',
                onTap: () {
                  print('Mail Tapped');
                }),
            SpeedDialChild(
                child: const Icon(LineIcons.arrowUp),
                label: 'Send',
                onTap: () {
                  print('Copy Tapped');
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
          backgroundColor: widgets.primaryDarkColor(),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: widgets.secondaryDarkColor(),
                ),
                child: Text('My Wallet'),
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
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "splashLogin", (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Main Balance Card (MBC)
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: widgets.Helper()
                    .mainBalance(widgets.getWidth(context), 99999.99, -99.99),
              ),
              // Extra space between tokens and MBC
              const Padding(
                padding: EdgeInsets.only(top: 40),
              ),

              Expanded(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, p) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 5),
                          width: widgets.getWidth(context),
                          child: widgets.Helper().balanceCards(
                              widgets.getWidth(context),
                              0.50032,
                              2803.30,
                              1402.55,
                              1.03),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
