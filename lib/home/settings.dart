import 'package:eth_wallet/util/constants.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: secondaryDarkColor(),
        title: const Text('Settings'
        , style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        ),
      ),
      body: const Center(
        child: Text('Settings'),
      ),
    
    );
  }
}
