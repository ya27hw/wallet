import 'dart:io';
import 'package:restart_app/restart_app.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

bool hasNumber(String value) {
  return value.contains(RegExp(r'[0-9]'));
}

double formatDouble(num value, int decimalPlaces) {
  return double.parse(value.toStringAsFixed(decimalPlaces));
}

bool hasUpperCase(String value) {
  return value.contains(RegExp(r'[A-Z]'));
}

String displayAddress(String address) {
  // Take first 8 characters and last 8 characters

  return address.length > 10
      ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
      : address;
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<void> deleteFile(String fileName) async {
  final path = await localPath;
  final file = File('$path/$fileName');

  if (await file.exists()) {
    await file.delete();
  }
}

Future<bool> checkIfFileExists(String fileName) async {
  final path = await localPath;
  final file = File('$path/$fileName');

  return file.exists();
}

Future<File> localFile(String fileName) async {
  final path = await localPath;
  return File('$path/$fileName.json');
}

Future<File> writeWallet(String wallet) async {
  final file = await localFile("wallet");

  // Write the file
  return file.writeAsString(wallet);
}

Future<String> readWallet() async {
  try {
    final file = await localFile("wallet");

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "";
  }
}

void loadNetwork(String network) {
  Box myBox = Hive.box("myBox");
  myBox.put("defaultNetwork", network);
  // Check if app is not on iOS
  if (!Platform.isIOS) {
    Restart.restartApp();
  }
}
