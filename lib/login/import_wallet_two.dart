import 'package:flutter/material.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:eth_wallet/backend/library.dart' as be;

class ImportWalletTwo extends StatefulWidget {
  const ImportWalletTwo({Key? key, required this.accountList})
      : super(key: key);

  final dynamic accountList;

  @override
  State<ImportWalletTwo> createState() => _ImportWalletTwoState();
}

class _ImportWalletTwoState extends State<ImportWalletTwo> {
  var _isLoading = false;
  String dropdownValue = "";
  bool _runOnce = false;
  Map addyMap = Map();

  @override
  Widget build(BuildContext context) {
    final addressList =
        widget.accountList["accountList"] as List<ImportedAddresses>;
    if (!_runOnce) {
      for (ImportedAddresses addyTable in addressList) {
        addyMap[displayAddress(addyTable.address)] = addyTable.privateKey;
      }
      _runOnce = true;
    }
    return Scaffold(
        backgroundColor: primaryDarkColor(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  "Choose a Wallet",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButton(
                underline: Container(
                  decoration:
                      const BoxDecoration(borderRadius: BorderRadius.zero),
                ),
                dropdownColor: secondaryDarkColor(),
                value: dropdownValue.isEmpty
                    ? displayAddress(addressList[0].address)
                    : dropdownValue,
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value.toString();
                  });
                },
                items: addressList
                    .map<DropdownMenuItem<String>>((ImportedAddresses itemOne) {
                  return DropdownMenuItem<String>(
                      value: displayAddress(itemOne.address),
                      child: Text(displayAddress(itemOne.address)));
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Continue"),
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
                  // Display a loading screen until the wallet is created
                  setState(() {
                    _isLoading = true;
                  });
                  String chosenAddress = dropdownValue.isEmpty
                      ? displayAddress(addressList[0].address)
                      : dropdownValue;

                  String chosenPrivKey = addyMap[chosenAddress];

                  await be.Web3().loadWallet(chosenPrivKey);

                  Navigator.pushNamedAndRemoveUntil(
                      context, "portfolio", (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        )

        );
  }
}
