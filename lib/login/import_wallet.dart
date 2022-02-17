import 'package:flutter/material.dart';

class ImportWallet extends StatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF202442)
        ),

        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Text(
                "Import a Wallet",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top : 50, left: 35, right: 35),
              child: Container(
                //padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
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
        padding: const EdgeInsets.only(top : 40),
        child: ElevatedButton(
          child: const Text("Continue"),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 17),
            padding: EdgeInsets.symmetric(horizontal: width * 0.20, vertical: 15),
            onPrimary: Colors.black,
            primary: const Color(0xFF41CD7D),
            onSurface: Colors.grey,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          ),
          onPressed:() {

          },
        ),
      ),

          ],
        ),
      ),
    );
  }
}
