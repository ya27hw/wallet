import 'package:eth_wallet/backend/library.dart';
import 'package:eth_wallet/util/constants.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: secondaryDarkColor(),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(children: [
        // const SizedBox(height: 20),
        Card(
          color: secondaryDarkColor(),
          child: ListTile(
            title: Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, 'createWallet',
                  arguments: {"privKey": Web3().privateKey});
            },
          ),
        ),
        Card(
          color: secondaryDarkColor(),
          child: ListTile(
            title: Text('Swap Network'),
            onTap: () {
              // Display dialog to choose network
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        backgroundColor: secondaryDarkColor(),
                        title: const Text("Choose Network"),
                        content: Wrap(
                          children: [
                            RadioListTile(
                              title: Text("Mainnet"),
                              value: 'mainnet',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {
                                  loadNetwork(value.toString());
                                });
                              },
                            ),
                            RadioListTile(
                              title: Text("Ropsten"),
                              value: 'ropsten',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {
                                  loadNetwork(value.toString());
                                });
                              },
                            ),
                            RadioListTile(
                              title: Text("Binance Smart Chain"),
                              value: 'bsc20',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            RadioListTile(
                              title: Text("Binance Smart Chain Test"),
                              value: 'bsc20-test',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {
                                  loadNetwork(value.toString());
                                });
                              },
                            ),
                            RadioListTile(
                              title: Text("Fantom"),
                              value: 'fantom',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            RadioListTile(
                              title: Text("Polygon"),
                              value: 'matic',
                              groupValue: 'network',
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ));
                  });

              //Box myBox = Hive.box("myBox");
            },
          ),
        ),
        //const SizedBox(height: 10),
        Card(
          color: secondaryDarkColor(),
          child: ListTile(
            title: const Text('Export Private Key'),
            onTap: () {
              // Show export private key dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: secondaryDarkColor(),
                    title: const Text('Export Private Key'),
                    content: GestureDetector(
                      onTap: () {
                        // Copy private key to clipboard
                        Clipboard.setData(ClipboardData(
                          text: Web3().privateKey,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Private key copied to clipboard',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: secondaryDarkColor(),
                        ));
                      },
                      child: Text(
                        "Tap to copy key.\n\n${Web3().privateKey}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
