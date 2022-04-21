import 'dart:convert';
import 'package:eth_wallet/util/classes.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

Box box = Hive.box("myBox");

Future<void> initDB() async {
  loadNetworks();
  loadTokenABI();
  loadSwapABI();
  box.put("defaultNetwork", "mainnet");
}

Future<void> loadTokenABI() async {
  String tokenABIContent =
      await rootBundle.loadString("assets/db/tokenABI.json");
  box.put("tokenABI", tokenABIContent);
}

Future<void> loadSwapABI() async {
  String swapABIContent = await rootBundle.loadString("assets/db/swapABI.json");
  box.put("swapABI", swapABIContent);
}

Future<void> loadNetworks() async {
  final String networksResponse =
      await rootBundle.loadString('assets/db/networks.json');
  final dynamic data = json.decode(networksResponse);
  Map tokenNetworks = data['tokenNetworks'];

  // Loop thru keys and values
  for (var key in tokenNetworks.keys) {
    Network network = Network(
      tokenNetworks[key]['unitFormat'],
      tokenNetworks[key]['api'],
      tokenNetworks[key]["stableCoin"],
      tokenNetworks[key]["contract"],
      tokenNetworks[key]["router"],
      key,
      tokenNetworks[key]['chainID'],
    );
    box.put(key, network);
  }
}
