import 'package:flutter/material.dart';
import "package:eth_wallet/util/library.dart" as utils;
import 'package:eth_wallet/backend/library.dart' as be;

class CreateWallet extends StatefulWidget {
  const CreateWallet({Key? key}) : super(key: key);

  @override
  _CreateWalletState createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  final TextEditingController _passwordController = TextEditingController();
  bool _continueDisabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF1B1E38)),
            child: Column(children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  "Create Wallet",
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
                        // Set _continueDisabled to true if the password is more than 8 characters, has at least one number, and one uppercase letter
                        _continueDisabled = value.length >= 8 &&
                            utils.hasNumber(value) &&
                            utils.hasUpperCase(value);
                      });
                    },
                    controller: _passwordController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                      hintText: 'Enter a password',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text(
                        "Your password must contain:"
                        "\n\n• One uppercase letter."
                        "\n\n• One number"
                        "\n\n• Minimum of eight letters.",
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                // CONTINUE Button
                child: ElevatedButton(
                  child: _isLoading
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : const Text("Continue"),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 17),
                    padding: EdgeInsets.symmetric(
                        horizontal: utils.getWidth(context) * 0.20,
                        vertical: 15),
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
                          // Display a loading screen until the wallet is created
                          setState(() {
                            _isLoading = true;
                          });

                          // wait for 5 seconds
                          await Future.delayed(
                              const Duration(milliseconds: 500));

                          await be.Web3()
                              .createWallet(_passwordController.text);

                          // Move onto TODO page
                          await Navigator.pushNamedAndRemoveUntil(context,
                              "portfolio", (Route<dynamic> route) => false);
                        },
                ),
              ),
            ])));
  }
}
