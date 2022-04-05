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
