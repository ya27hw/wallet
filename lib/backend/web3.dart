import 'package:http/http.dart';

import "package:eth_wallet/util/library.dart" as utils;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'dart:io';
import 'package:hdkey/hdkey.dart';

class Web3 {
  Future<void> loadWallet(String password) async {
    String content = await utils.readWallet();
    Wallet wallet = Wallet.fromJson(content, password);
  }

  Future<void> createWallet(String password) async {
    Random rng = Random.secure();
    EthPrivateKey creds = EthPrivateKey.createRandom(rng);
    Wallet myWallet = Wallet.createNew(creds, password, rng);

    String wJson = myWallet.toJson();
    utils.writeWallet(wJson);
  }

  Future<List<utils.ImportedAddresses>> importWallet(String mnemonic) async {
    final hdwallet = HDKey.fromMnemonic(mnemonic);
    var walletHdpath = "m/44'/60'/0'/0";

    List<utils.ImportedAddresses> accs = [];
    for (var i = 0; i < 10; i++) {
      String path = "$walletHdpath/$i";
      HDKey key = hdwallet.derive(path);
      final privateKeyList = key.privateKey;

      // Check if private key is valid
      if (privateKeyList == null) {
        continue;
      }

      EthPrivateKey privateKey =
          EthPrivateKey.fromHex(bytesToHex(privateKeyList));
      EthereumAddress address = await privateKey.extractAddress();

      utils.ImportedAddresses importedAddresses =
          utils.ImportedAddresses(address.hex, bytesToHex(privateKeyList));

      // Add both address and private key to the list
      accs.add(importedAddresses);
    }
    return accs;
  }

  Future<double> getMainTokenBalance() async {
    //  TODO
    var apiUrl = "https://data-seed-prebsc-1-s1.binance.org:8545/";
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    // EtherAmount balance = await ethClient.getBalance();
    // return balance.getValueInUnit(EtherUnit.ether);

    return 3.0;
  }
}
