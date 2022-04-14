import "package:flutter/material.dart";
import 'package:hive/hive.dart';
part 'classes.g.dart';

class BalanceIndicator {
  late String symbol;
  late Color color;
}

class ImportedAddresses {
  final String address;
  final String privateKey;

  ImportedAddresses(this.address, this.privateKey);
}

class TokenInfo {
  final double balance;
  final double priceUSD;
  final Token token;

  TokenInfo(this.balance, this.priceUSD, this.token);
}

class TokenChartData {
  final num? ts;
  final String? date;
  final num? hour;
  final num? open;
  final num? close;
  final num? high;
  final num? low;
  final num? volume;
  final num? volumeConverted;
  final num? cap;
  final num? average;

  TokenChartData(
      {this.ts,
      this.date,
      this.hour,
      this.open,
      this.close,
      this.high,
      this.low,
      this.volume,
      this.volumeConverted,
      this.cap,
      this.average});
}

@HiveType(typeId: 0)
class Network extends HiveObject {
  @HiveField(0)
  final String unit;
  @HiveField(1)
  final String rpcURL;
  @HiveField(2)
  final String stableCoinAddress;
  @HiveField(3)
  final String nativeTokenAddress;
  @HiveField(4)
  final String swapRouterAddress;
  @HiveField(5)
  final String networkName;
  @HiveField(6)
  final int chainID;
  Network(
      this.unit,
      this.rpcURL,
      this.stableCoinAddress,
      this.nativeTokenAddress,
      this.swapRouterAddress,
      this.networkName,
      this.chainID);
}

@HiveType(typeId: 1)
class Token extends HiveObject {
  @HiveField(0)
  final String symbol;
  @HiveField(1)
  final String address;
  @HiveField(2)
  final int decimals;

  Token(this.symbol, this.address, this.decimals);
}

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  send,
  @HiveField(1)
  receive,
  @HiveField(2)
  swap
}

@HiveType(typeId: 2)
class TransactionData extends HiveObject {
  @HiveField(0)
  final String hash;
  @HiveField(1)
  final TransactionType transactionType;
  @HiveField(2)
  final int epoch;
  @HiveField(3)
  final String from;
  @HiveField(4)
  final String to;
  @HiveField(5)
  final double value;
  @HiveField(6)
  final String sentTokenSymbol;

  TransactionData(this.hash, this.transactionType, this.epoch, this.from,
      this.to, this.value, this.sentTokenSymbol);
}
