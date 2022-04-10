import 'package:eth_wallet/backend/library.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';

class Swap extends StatefulWidget {
  const Swap({Key? key}) : super(key: key);

  @override
  State<Swap> createState() => _SwapState();
}

class _SwapState extends State<Swap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      appBar: AppBar(
        backgroundColor: secondaryDarkColor(),
        centerTitle: true,
        title: Text(
          'Swap',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            //await Web3().swapTokens();
          },
          child: Text('Swap'),
        ),
      ),
    );
  }
}
