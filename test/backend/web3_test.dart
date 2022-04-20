import 'package:eth_wallet/backend/library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  final web = Web3();
  const String privKey =
      "73d01860b636d37a0b6bc140cfc8517a9d2282c9671e3c4d61fd4dc33015ce49";

  test('Create a valid wallet, and a private key.', () async {
    await web.createWallet("password");
    await web.loadWalletJson("password");
    // Make sure a private key is generated.
    expect(web.privateKey, isNotNull);
  });

  test("Load a wallet with a private key", () async {
    await web.loadWallet(privKey, "password");
    expect(web.privateKey, privKey);
  });
  test("Load a wallet with a private key", () async {
  });
}
