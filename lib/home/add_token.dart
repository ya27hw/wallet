import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import "package:eth_wallet/backend/library.dart" as be;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddToken extends StatefulWidget {
  const AddToken({Key? key}) : super(key: key);

  @override
  State<AddToken> createState() => _AddTokenState();
}

class _AddTokenState extends State<AddToken> {
  final _contractAddressController = TextEditingController();
  final _symbolController = TextEditingController();
  final _decimalsController = TextEditingController();

  @override
  void dispose() {
    _contractAddressController.dispose();
    _symbolController.dispose();
    _decimalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenBox = Hive.box("tokenBox");
    String defaultNetwork = be.Web3().defaultNetwork;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: true,
          backgroundColor: secondaryDarkColor(),
          title: const Text(
            'Add Token',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: primaryDarkColor(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50, left: 35, right: 35),
              child: Text(
                "Contract Address",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
              child: Container(
                //padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
                  onChanged: (String value) async {
                    // Validate address
                    bool isValidAddress = be.Web3().validateAddress(value);
                    if (isValidAddress) {
                      var decimalSymbol =
                          await be.Web3().getSymbolDecimal(value);
                      setState(() {
                        // Set Symbol field and Decimal field to the retrieved values
                        _decimalsController.text =
                            decimalSymbol["decimals"].toString();
                        _symbolController.text = decimalSymbol["symbol"];
                      });
                    }
                  },
                  controller: _contractAddressController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: '0x...',
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 50, left: 35, right: 35),
              child: Text(
                "Symbol",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
              child: Container(
                //padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
                  onChanged: (String value) {
                    setState(() {});
                  },
                  controller: _symbolController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: 'ETH',
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 50, left: 35, right: 35),
              child: Text(
                "Decimals",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
              child: Container(
                //padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
                  onChanged: (String value) {
                    setState(() {});
                  },
                  controller: _decimalsController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: '18',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: ElevatedButton(
                  child: const Text("Import"),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 17),
                    padding: EdgeInsets.symmetric(
                        horizontal: getWidth(context) * 0.20, vertical: 15),
                    onPrimary: Colors.black,
                    primary: const Color(0xFF41CD7D),
                    onSurface: Colors.grey,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                  ),
                  onPressed: () async {
                    // pop screen
                    Token tempToken = Token(
                        _contractAddressController.text,
                        _symbolController.text,
                        int.parse(_decimalsController.text));

                    List<Token> tokens =
                        tokenBox.get(defaultNetwork) ?? <Token>[];
                    tokens.add(tempToken);
                    tokenBox.put(defaultNetwork, tokens);

                    // Check if token is already in the list
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
