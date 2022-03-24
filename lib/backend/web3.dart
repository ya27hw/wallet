import 'package:eth_wallet/main.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import "package:eth_wallet/util/library.dart" as utils;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'dart:io';
import 'package:hdkey/hdkey.dart';

var myWallet;
Box myBox = Hive.box("myBox");

class Web3 {
  EtherUnit stringToUnit(String unit) {
    switch (unit) {
      case "wei":
        return EtherUnit.wei;
      case "kwei":
        return EtherUnit.kwei;
      case "mwei":
        return EtherUnit.mwei;
      case "gwei":
        return EtherUnit.gwei;
      case "szabo":
        return EtherUnit.szabo;
      case "finney":
        return EtherUnit.finney;
      case "ether":
        return EtherUnit.ether;
      default:
        return EtherUnit.ether;
    }
  }

  Future<bool> loadWalletJson(String password) async {
    String content = await utils.readWallet();
    try {
      myWallet = Wallet.fromJson(content, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> createWallet(String password) async {
    Random rng = Random.secure();
    EthPrivateKey creds = EthPrivateKey.createRandom(rng);
    _initWallet(creds, password, rng);
  }

  Future<void> loadWallet(String privateKey) async {
    EthPrivateKey creds = EthPrivateKey.fromHex(privateKey);
    _initWallet(creds, "password");
  }

  void _initWallet(EthPrivateKey creds, String password, [Random? rng]) async {
    rng ??= Random.secure();
    myWallet = Wallet.createNew(creds, password, rng);

    String wJson = myWallet.toJson();
    utils.writeWallet(wJson);
  }

  void _saveKeys() {}

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
    var apiUrl = myBox.get(myBox.get("defaultNetwork")).rpcURL;
    print(apiUrl);
    print("GAY GAY GAY GAY");
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    EtherAmount balance =
        await ethClient.getBalance(myWallet.privateKey.address);
    return balance.getValueInUnit(EtherUnit.ether);
  }

  Future<double> getTokenPrice(String tokenAddress) async {
    // TODO get token price
    String apiUrl = myBox.get(myBox.get("defaultNetwork")).rpcURL;
    // var httpClient = Client();
    // var ethClient = Web3Client(apiUrl, httpClient);
    // ethClient
    return 0;
  }

  Future<double> _getNativeTokenPrice() async {
    utils.Network defaultNetwork = myBox.get(myBox.get("defaultNetwork"));
    final client = Web3Client(defaultNetwork.rpcURL, Client());

    final EthereumAddress stableCoinAddress =
        EthereumAddress.fromHex(defaultNetwork.stableCoinAddress);
    final EthereumAddress nativeTokenAddress =
        EthereumAddress.fromHex(defaultNetwork.nativeTokenAddress);
    final EthereumAddress swapRouter =
        EthereumAddress.fromHex(defaultNetwork.swapRouterAddress);

    try {
      String swapABI = myBox.get("swapABI");
      final swapContract = DeployedContract(
          ContractAbi.fromJson(swapABI, "UniswapV2Router02"), swapRouter);
      final getAmountsOutFunction = swapContract.function('getAmountsOut');
      final oneETH = EtherAmount.fromUnitAndValue(EtherUnit.ether, 1);
      final etherPrice = await client.call(
          contract: swapContract,
          function: getAmountsOutFunction,
          params: [
            oneETH.getInWei,
            [nativeTokenAddress, stableCoinAddress]
          ]);

      final amount = EtherAmount.inWei(etherPrice.first[1]);
      return amount.getValueInUnit(stringToUnit(defaultNetwork.unit));
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, double>> mainBalanceCard() async {

    final mainTokenBalance = await getMainTokenBalance();
    final nativeTokenPrice =  await _getNativeTokenPrice();

    return {
      "mainTokenBalance": mainTokenBalance,
      "nativeTokenPrice": nativeTokenPrice,
    };
  }
}
