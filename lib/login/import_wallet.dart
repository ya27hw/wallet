import 'package:flutter/material.dart';
import 'package:eth_wallet/util/library.dart' as utils;
import 'package:eth_wallet/backend/library.dart' as be;

class ImportWallet extends StatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  final TextEditingController _seedPhraseController = TextEditingController();
  late int _seedLength;
  late Color _seedWordColor;
  late bool _continueDisabled;
  late bool _isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seedLength = 0;
    _continueDisabled = false;
    _seedWordColor = Colors.red;
    _isLoading = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _seedPhraseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF1B1E38)),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Text(
                "Import a Wallet",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 35, right: 35),
              child: Container(
                //padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
                  onChanged: (String value) {
                    setState(() {
                      _seedLength =
                          _seedPhraseController.text.trim().split(" ").length;
                      if (_seedLength != 12) {
                        _seedWordColor = Colors.red;
                        _continueDisabled = false;
                      } else {
                        _seedWordColor = Colors.white;
                        _continueDisabled = true;
                      }
                    });
                  },
                  controller: _seedPhraseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: 'Input your 12-word phrase here...',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                "$_seedLength/12",
                style: TextStyle(color: _seedWordColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              // CONTINUE Button
              child: ElevatedButton(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      )
                    : const Text("Continue"),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 17),
                  padding: EdgeInsets.symmetric(
                      horizontal: utils.getWidth(context) * 0.20, vertical: 15),
                  onPrimary: Colors.black,
                  primary: const Color(0xFF41CD7D),
                  onSurface: Colors.grey,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                ),
                onPressed: !_continueDisabled
                    ? null
                    : () async {
                        var accountList = await be.Web3()
                            .importWallet(_seedPhraseController.text);

                        if (accountList.isEmpty) {
                          // Display error msg
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Invalid Seed Phrase",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, "importWalletTwo",
                              arguments: {"accountList": accountList});
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
