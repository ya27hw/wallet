import 'package:hive/hive.dart';
import 'package:http/http.dart';
import "package:eth_wallet/util/library.dart" as utils;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'package:hdkey/hdkey.dart';
import 'package:bip39/bip39.dart' as bip39;

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

  String returnAddress() {
    return myWallet.privateKey.address.hex;
  }

  bool validateAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
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

  Future<List<utils.ImportedAddresses>> importWallet(String mnemonic) async {
    // Validate mnemonic first
    bool isValid = bip39.validateMnemonic(mnemonic);
    if (!isValid) {
      return [];
    }

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

  Future<double> _getMainTokenBalance() async {
    var apiUrl = myBox.get(myBox.get("defaultNetwork")).rpcURL;
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    EtherAmount balance =
        await ethClient.getBalance(myWallet.privateKey.address);
    final mainBalance = balance.getValueInUnit(EtherUnit.ether);
    // Format to 4 d.p.
    return formatDouble(mainBalance, 4);
  }

  Web3Client _getClient() {
    var apiUrl = myBox.get(myBox.get("defaultNetwork")).rpcURL;
    var httpClient = Client();
    return Web3Client(apiUrl, httpClient);
  }

  DeployedContract _getTokenContract(String contractAddress) {
    String abiCode = myBox.get("tokenABI");
    EthereumAddress contractAddressObj =
        EthereumAddress.fromHex(contractAddress);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, "tokenABI"), contractAddressObj);
  }

  Future<int> _getDecimal(String contractAddress) async {
    Web3Client client = _getClient();
    DeployedContract contract = _getTokenContract(contractAddress);
    final decimalsFunction = contract.function("decimals");

    try {
      final decimals = await client
          .call(contract: contract, function: decimalsFunction, params: []);

      // Convert to int
      return int.parse(decimals.first.toString());
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<String> _getSymbol(String contractAddress) async {
    Web3Client client = _getClient();
    DeployedContract contract = _getTokenContract(contractAddress);
    final symbolFunction = contract.function("symbol");

    try {
      final symbol = await client
          .call(contract: contract, function: symbolFunction, params: []);

      return symbol.first;
    } catch (e) {
      return "";
    }
  }

  Future<dynamic> getSymbolDecimal(String contractAddress) async {
    int decimals = await _getDecimal(contractAddress);
    String symbol = await _getSymbol(contractAddress);
    print("Decimals: $decimals");
    print("Symbol: $symbol");
    return {"decimals": decimals, "symbol": symbol};
  }

  Future<double> getTokenPrice(String tokenAddress) async {
    // TODO get token price
    return 0;
  }

  Future<double> _getNativeTokenPrice() async {
    utils.Network defaultNetwork = myBox.get(myBox.get("defaultNetwork"));
    final Web3Client client = _getClient();

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
      double doubleAmount =
          amount.getValueInUnit(stringToUnit(defaultNetwork.unit));
      return formatDouble(doubleAmount, 2);
    } catch (e) {
      return -1;
    }
  }

  double formatDouble(double value, int decimalPlaces) {
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }

  Future<Map<String, double>> mainBalanceCard() async {
    final mainTokenBalance = await _getMainTokenBalance();
    var nativeTokenPrice = await _getNativeTokenPrice();
    nativeTokenPrice *= mainTokenBalance;

    return {
      "mainTokenBalance": mainTokenBalance,
      "nativeTokenPrice": formatDouble(nativeTokenPrice, 2),
    };
  }

  Future<void> sendTokenTransaction(
      String receivingAddress, double value, bool isNative) async {
    // TODO : Send a transaction through the network.

    utils.Network defaultNetwork =
        myBox.get(myBox.get("defaultNetwork")) as utils.Network;
    print(defaultNetwork.chainID);
    // Convert value in ether to value in wei
    BigInt valueWei = BigInt.from(value * pow(10, 18));
    Web3Client ethClient = _getClient();
    var transaction = Transaction(
      to: EthereumAddress.fromHex(receivingAddress),
      maxGas: 21000,
      value: EtherAmount.inWei(valueWei),
    );

    await ethClient.sendTransaction(myWallet.privateKey, transaction,
        chainId: defaultNetwork.chainID);
  }
}
