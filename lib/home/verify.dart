import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/backend/library.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Text(
                "Welcome back",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 35, right: 35),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF32385F),
                    borderRadius: BorderRadius.circular(17)),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: 'Enter your password...',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ElevatedButton(
                child: const Text("Continue"),
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
                  bool loggedIn =
                      await Web3().loadWalletJson(_passwordController.text);

                  if (loggedIn) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, "portfolio", (Route<dynamic> route) => false);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: secondaryDarkColor(),
                          title: const Text("Error"),
                          content: const Text("Incorrect password"),
                          actions: [
                            ElevatedButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
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
