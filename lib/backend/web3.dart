import 'package:hive/hive.dart';
import 'package:http/http.dart';
import "package:eth_wallet/util/library.dart" as utils;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'package:hdkey/hdkey.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../util/library.dart';

var _myWallet;
Box _myBox = Hive.box("myBox");

class Web3 {
  Web3([Box? box]);
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

  EtherUnit decimalToUnit(int decimal) {
    switch (decimal) {
      case 0:
        return EtherUnit.wei;
      case 3:
        return EtherUnit.kwei;
      case 6:
        return EtherUnit.mwei;
      case 9:
        return EtherUnit.gwei;
      case 12:
        return EtherUnit.szabo;
      case 15:
        return EtherUnit.finney;
      case 18:
        return EtherUnit.ether;
      default:
        return EtherUnit.ether;
    }
  }

  String get defaultNetwork => _myBox.get("defaultNetwork");

  String returnAddress() {
    return _myWallet.privateKey.address.hex;
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
      _myWallet = Wallet.fromJson(content, password);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> createWallet(String password) async {
    Random rng = Random.secure();
    EthPrivateKey creds = EthPrivateKey.createRandom(rng);
    _initWallet(creds, password, rng);
  }

  Future<void> loadWallet(String privateKey, String password) async {
    EthPrivateKey creds = EthPrivateKey.fromHex(privateKey);
    _initWallet(creds, password);
  }

  void _initWallet(EthPrivateKey creds, String password, [Random? rng]) async {
    rng ??= Random.secure();
    _myWallet = Wallet.createNew(creds, password, rng);
    String wJson = _myWallet.toJson();
    utils.writeWallet(wJson);
  }

  Future<List<utils.ImportedAddresses>> importWallet(String mnemonic) async {
    // Validate mnemonic first
    bool isValid = bip39.validateMnemonic(mnemonic);
    if (!isValid) {
      return [];
    }
    List<utils.ImportedAddresses> accs = [];

    final hdwallet = HDKey.fromMnemonic(mnemonic);
    var walletHdpath = "m/44'/60'/0'/0";

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

  String get privateKey {
    var myKey = _myWallet.privateKey as EthPrivateKey;
    String privKeyString = bytesToHex(myKey.privateKey);
    // If contains 0x, remove it
    if (privKeyString.startsWith("00")) {
      return privKeyString.substring(2);
    } else {
      return privKeyString;
    }
  }

  Future<double> _getMainTokenBalance() async {
    var apiUrl = _myBox.get(_myBox.get("defaultNetwork")).rpcURL;
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    EtherAmount balance =
        await ethClient.getBalance(_myWallet.privateKey.address);
    final mainBalance = balance.getValueInUnit(EtherUnit.ether);
    // Format to 4 d.p.
    return formatDouble(mainBalance, 4);
  }

  Web3Client _getClient() {
    var apiUrl = _myBox.get(_myBox.get("defaultNetwork")).rpcURL;
    var httpClient = Client();
    return Web3Client(apiUrl, httpClient);
  }

  DeployedContract _getTokenContract(String tokenAddress) {
    String abiCode = _myBox.get("tokenABI");
    EthereumAddress contractAddressObj = EthereumAddress.fromHex(tokenAddress);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, "tokenABI"), contractAddressObj);
  }

  DeployedContract _getSwapContract() {
    String abiCode = _myBox.get("swapABI");
    utils.Network network = _myBox.get(_myBox.get("defaultNetwork"));
    EthereumAddress swapRouterContract =
        EthereumAddress.fromHex(network.swapRouterAddress);
    return DeployedContract(
        ContractAbi.fromJson(abiCode, "swapABI"), swapRouterContract);
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
      print(e);
      return "";
    }
  }

  Future<dynamic> getSymbolDecimal(String contractAddress) async {
    int decimals = await _getDecimal(contractAddress);
    String symbol = await _getSymbol(contractAddress);
    return {"decimals": decimals, "symbol": symbol};
  }

  Future<double> getTokenPrice(String tokenAddress, int decimals,
      [DeployedContract? tokenContract, DeployedContract? swapContract]) async {
    final client = _getClient();
    Network network = _myBox.get(_myBox.get("defaultNetwork"));
    if (tokenAddress.toLowerCase() == network.stableCoinAddress.toLowerCase()) {
      return 1.0;
    }

    swapContract = swapContract ?? _getSwapContract();

    final getAmountsOutFunction = swapContract.function("getAmountsOut");

    final oneETH = EtherAmount.fromUnitAndValue(EtherUnit.ether, 1);
    try {
      final balance = await client.call(
          contract: swapContract,
          function: getAmountsOutFunction,
          params: [
            oneETH.getInWei,
            [
              EthereumAddress.fromHex(tokenAddress),
              EthereumAddress.fromHex(network.stableCoinAddress)
            ]
          ]);
      final amount = EtherAmount.inWei(balance.first[1]);
      double price = amount.getValueInUnit(stringToUnit(network.unit));
      return price;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<double> getGasFees() async {
    final client = _getClient();
    final gasPriceInEther = await client.getGasPrice();
    return gasPriceInEther.getValueInUnit(stringToUnit("gwei"));
  }

  Future<double> _tokenBalanceOf(String tokenAddress, int decimals) async {
    final tokenContract = _getTokenContract(tokenAddress);
    final client = _getClient();
    final balanceOfFunction = tokenContract.function("balanceOf");

    try {
      final balance = await client.call(
          contract: tokenContract,
          function: balanceOfFunction,
          params: [_myWallet.privateKey.address]);
      final amount = EtherAmount.inWei(balance.first);
      double tokenBalance = amount.getInWei.toDouble() / pow(10, decimals);

      // Format to 4 d.p.
      return tokenBalance;
    } catch (e) {
      print(e);
      return -1;
    }
  }

  Future<List<utils.TokenInfo>> getTokenPricesBatch(List<Token> tokens) async {
    List<utils.TokenInfo> tokenInfoList = [];
    for (Token token in tokens) {
      double tokenPrice = await getTokenPrice(token.address, token.decimals);
      double tokenBalance =
          await _tokenBalanceOf(token.address, token.decimals);
      utils.TokenInfo tempInfo =
          utils.TokenInfo(tokenBalance, tokenPrice, token);
      tokenInfoList.add(tempInfo);
      print(
          "Token: ${token.symbol}\nPrice: $tokenPrice\nBalance: $tokenBalance");
    }
    return tokenInfoList;
  }

  Future<double> _getNativeTokenPrice() async {
    utils.Network defaultNetwork = _myBox.get(_myBox.get("defaultNetwork"));
    final Web3Client client = _getClient();

    final EthereumAddress stableCoinAddress =
        EthereumAddress.fromHex(defaultNetwork.stableCoinAddress);
    final EthereumAddress nativeTokenAddress =
        EthereumAddress.fromHex(defaultNetwork.nativeTokenAddress);
    final EthereumAddress swapRouter =
        EthereumAddress.fromHex(defaultNetwork.swapRouterAddress);

    try {
      String swapABI = _myBox.get("swapABI");
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
      //print(etherPrice);
      final amount = EtherAmount.inWei(etherPrice.first[1]);
      double doubleAmount =
          amount.getValueInUnit(stringToUnit(defaultNetwork.unit));
      return formatDouble(doubleAmount, 2);
    } catch (e) {
      print(e);
      return -1;
    }
  }

  Future<Map<String, double>> mainBalanceCard() async {
    final mainTokenBalance = await _getMainTokenBalance();
    double nativeTokenPrice = await _getNativeTokenPrice();
    print("Native Token Price: $nativeTokenPrice");

    nativeTokenPrice *= mainTokenBalance;

    return {
      "mainTokenBalance": mainTokenBalance,
      "nativeTokenPrice": formatDouble(nativeTokenPrice, 2),
    };
  }

  Future<double> getEstimatedBalanceOut(
      double amount, double slippage, Token from, Token to) async {
    utils.Network network = _myBox.get(defaultNetwork) as utils.Network;
    Web3Client client = _getClient();

    final tokenInAmount = BigInt.from(amount * pow(10, from.decimals));
    final swapContract = utils.Swap(
        address: EthereumAddress.fromHex(network.swapRouterAddress),
        client: client,
        chainId: network.chainID);
    final tokenOutAmount = await swapContract.getAmountsOut(tokenInAmount, [
      EthereumAddress.fromHex(from.address),
      EthereumAddress.fromHex(to.address)
    ]);
    final tokenOutMinAmount =
        tokenOutAmount[1] - (tokenOutAmount[1] * BigInt.from(0.1));

    return tokenOutMinAmount.toDouble() / pow(10, to.decimals);
  }

  Future<void> swapTokens(Token to, double amount, [Token? from]) async {
    // NOTES
    // BSC20-Test WBNB --> Anything WORKS
    // Ropsten USDC --> WETH WORKS
    utils.Network network = _myBox.get(defaultNetwork) as utils.Network;

    Web3Client client = _getClient();

    final toContract = utils.TokenG(
        address: EthereumAddress.fromHex(to.address),
        client: client,
        chainId: network.chainID);
    final swapContract = utils.Swap(
        address: EthereumAddress.fromHex(network.swapRouterAddress),
        client: client,
        chainId: network.chainID);
    if (from != null) {
      final tokenInAmount = BigInt.from(amount * pow(10, from.decimals));

      final tokenOutAmount = await swapContract.getAmountsOut(tokenInAmount, [
        EthereumAddress.fromHex(from.address),
        EthereumAddress.fromHex(to.address)
      ]);
      final tokenOutMinAmount =
          tokenOutAmount[1] - (tokenOutAmount[1] * BigInt.from(0.1));

      final approveTokenIn = await toContract.approve(
          EthereumAddress.fromHex(network.swapRouterAddress), tokenInAmount,
          credentials: _myWallet.privateKey);
      print("Approve Token: $approveTokenIn");
      print("transferring $tokenInAmount (${from.symbol}) -- ${from.address}");
      print("receiving $tokenOutMinAmount (${to.symbol}) -- ${to.address}");

      final swapTx = await swapContract.swapTokensForExactTokens(
          tokenInAmount,
          tokenOutMinAmount,
          [
            EthereumAddress.fromHex(from.address),
            EthereumAddress.fromHex(to.address)
          ],
          _myWallet.privateKey.address,
          BigInt.from(DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000),
          credentials: _myWallet.privateKey,
          transaction: Transaction());

      addToActivity(utils.TransactionData(
          swapTx,
          utils.TransactionType.swap,
          DateTime.now().millisecondsSinceEpoch,
          _myWallet.privateKey.address.hex,
          to.address,
          amount,
          from.symbol));
    } else {
      Token from = utils.Token("ETH", network.nativeTokenAddress, 6);
      final tokenInAmount = BigInt.from(amount * pow(10, from.decimals));
      final tokenInMinAmount =
          tokenInAmount - (tokenInAmount * BigInt.from(0.1));

      final tokenOutAmount = await swapContract.getAmountsOut(tokenInAmount, [
        EthereumAddress.fromHex(from.address),
        EthereumAddress.fromHex(to.address)
      ]);
      final tokenOutMinAmount =
          tokenOutAmount[1] - (tokenOutAmount[1] * BigInt.from(0.1));
      // final swapTx = await swapContract.swapETHForExactTokens(
      //     amount,
      //     [
      //       EthereumAddress.fromHex(from.address),
      //       EthereumAddress.fromHex(to.address)
      //     ],
      //     _myWallet.privateKey.address,
      //     BigInt.from(DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000),
      //     credentials: _myWallet.privateKey,
      //     transaction: Transaction(gasPrice: gasPrice));
    }
  }

  Future<void> sendTokenTransaction(String receivingAddress, double value,
      [String? tokenContractAddress, num? decimals]) async {
    utils.Network defaultNetwork =
        _myBox.get(_myBox.get("defaultNetwork")) as utils.Network;
    Web3Client ethClient = _getClient();

    if (tokenContractAddress == null || decimals == null) {
      // Send transaction with native token
      // Convert value in ether to value in wei
      BigInt valueWei = BigInt.from(value * pow(10, 18));
      var transaction = Transaction(
        to: EthereumAddress.fromHex(receivingAddress),
        value: EtherAmount.inWei(valueWei),
      );
      final hash = await ethClient.sendTransaction(
          _myWallet.privateKey, transaction,
          chainId: defaultNetwork.chainID);
      addToActivity(utils.TransactionData(
          hash,
          utils.TransactionType.send,
          DateTime.now().millisecondsSinceEpoch,
          _myWallet.privateKey.address.hex,
          receivingAddress,
          value,
          "ETH"));
    } else {
      final tokenContract = utils.TokenG(
          address: EthereumAddress.fromHex(tokenContractAddress),
          client: ethClient);

      final hash = await tokenContract.transfer(
        EthereumAddress.fromHex(receivingAddress),
        BigInt.from(value * pow(10, decimals)),
        credentials: _myWallet.privateKey,
      );

      String symbol = await tokenContract.symbol();

      addToActivity(utils.TransactionData(
          hash,
          utils.TransactionType.send,
          DateTime.now().millisecondsSinceEpoch,
          _myWallet.privateKey.address.hex,
          receivingAddress,
          value,
          symbol));
    }
  }

  void addToActivity(utils.TransactionData transaction) {
    final activityBox = Hive.box("activityBox");
    activityBox.add(transaction);
  }
}
