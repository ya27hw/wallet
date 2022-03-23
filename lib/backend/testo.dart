import 'package:eth_wallet/util/constants.dart';
import 'package:flutter/services.dart';

Future<int> testJS(int f, int s) async {
  String blockJS = await rootBundle.loadString("assets/j.js");
  final res = getJSRunTime().evaluate(blockJS + """add($f, $s) """);
  final strRes = res.stringResult;

  return int.parse(strRes);
}
