import 'dart:ffi';

import 'package:eth_wallet/backend/library.dart';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:im_stepper/stepper.dart';
import 'package:line_icons/line_icons.dart';

class Swap extends StatefulWidget {
  const Swap({Key? key}) : super(key: key);

  @override
  State<Swap> createState() => _SwapState();
}

class _SwapState extends State<Swap> {
  String defNetwork = Web3().defaultNetwork;
  String dropDownValue = "";
  String dropDownValue2 = "";

  int decimals = 0;
  int decimals2 = 0;
  String symbol = "";
  String symbol2 = "";
  final _valueController = TextEditingController();

  int activeStep = 0;
  int upperBound = 2;

  String operationMode = "ETH";
  final tokenBox = Hive.box("tokenBox");

  @override
  void initState() {
    super.initState();
    final t = tokenBox.get(defNetwork);
    if (t != null) {
      dropDownValue = t[0].address;
      dropDownValue2 = t[0].address;
      decimals = t[0].decimals;
      decimals2 = t[0].decimals;
      symbol = t[0].symbol;
      symbol2 = t[0].symbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    var tokenList = tokenBox.get(defNetwork) ?? <Token>[];
    List<Token> castedTokenList = List.castFrom(tokenList);

    Widget nextButton() {
      return ElevatedButton(
        child: activeStep == upperBound - 1
            ? const Text(
                'Send',
              )
            : const Text(
                'Next',
              ),
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 17),
          fixedSize: const Size(140, 40),
          onPrimary: Colors.black,
          primary: const Color(0xFF41CD7D),
          onSurface: Colors.grey,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
        onPressed: () async {
          // pop screen
          if (activeStep < upperBound - 1) {
            setState(() {
              activeStep++;
            });
          } else if (activeStep == upperBound - 1) {
            // send transaction

            if (operationMode == "ETH") {
              // Send from ETH to Token
              await Web3().swapTokens(
                Token(symbol2, dropDownValue2, decimals2),
                double.parse(_valueController.text),
              );
            } else {
              if (dropDownValue == dropDownValue2) {
                // SnackBar to show error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "You can't swap between the same token",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Send from Token to Token
              await Web3().swapTokens(
                Token(symbol2, dropDownValue2, decimals2),
                double.parse(_valueController.text),
                Token(symbol, dropDownValue, decimals),
              );
            }

            // pop screen
            Navigator.pop(context);
          }
        },
      );
    }

    Widget previousButton() {
      return ElevatedButton(
        child: const Text("Previous"),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(140, 40),
          textStyle: const TextStyle(fontSize: 17),
          //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          onPrimary: Colors.black,
          primary: const Color(0xFF41CD7D),
          onSurface: Colors.grey,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
        onPressed: activeStep > 0
            ? () async {
                // pop screen
                if (activeStep > 0) {
                  setState(() {
                    activeStep--;
                  });
                }
              }
            : null,
      );
    }

    Widget getBody() {
      switch (activeStep) {
        case 0:
          return Padding(
            padding: EdgeInsets.only(
                top: getHeight(context) * 0.08, left: 35, right: 35),
            child: Column(
              children: [
                ListTile(
                  title: const Text("ETH"),
                  leading: Radio(
                    value: 'ETH',
                    groupValue: operationMode,
                    onChanged: (value) {
                      setState(() {
                        operationMode = value.toString();
                      });
                    },
                  ),
                ),
                dropDownValue == ""
                    ? Container()
                    : ListTile(
                        title: const Text("Other Tokens"),
                        leading: Radio(
                          value: 'OT',
                          groupValue: operationMode,
                          onChanged: (value) {
                            setState(() {
                              operationMode = value.toString();
                            });
                          },
                        ),
                      ),
                operationMode == "ETH"
                    ? Container()
                    : dropDownValue == ""
                        ? Container()
                        : DropdownButton(
                            underline: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.zero),
                            ),
                            dropdownColor: secondaryDarkColor(),
                            items: castedTokenList
                                .map<DropdownMenuItem<String>>((Token itemOne) {
                              return DropdownMenuItem<String>(
                                  value: itemOne.address,
                                  child: Text(itemOne.symbol));
                            }).toList(),
                            value: dropDownValue.isEmpty
                                ? castedTokenList[0].address
                                : dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value.toString();
                                Token temp = castedTokenList.firstWhere(
                                    (Token item) => item.address == value);
                                decimals = temp.decimals;
                                symbol = temp.symbol;
                              });
                            },
                          ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF32385F),
                      borderRadius: BorderRadius.circular(17)),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _valueController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                      hintText: 'Input amount to transfer...',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(LineIcons.arrowDown),
                const SizedBox(height: 20),
                DropdownButton(
                  underline: Container(
                    decoration:
                        const BoxDecoration(borderRadius: BorderRadius.zero),
                  ),
                  dropdownColor: secondaryDarkColor(),
                  items: castedTokenList
                      .map<DropdownMenuItem<String>>((Token itemOne) {
                    return DropdownMenuItem<String>(
                        value: itemOne.address, child: Text(itemOne.symbol));
                  }).toList(),
                  value: dropDownValue2.isEmpty
                      ? castedTokenList[0].address
                      : dropDownValue2,
                  onChanged: (value) {
                    setState(() {
                      dropDownValue2 = value.toString();
                      Token temp = castedTokenList
                          .firstWhere((Token item) => item.address == value);
                      decimals2 = temp.decimals;
                      symbol2 = temp.symbol;
                    });
                  },
                ),
              ],
            ),
          );

        case 1:
          symbol = operationMode == "ETH" ? "ETH" : symbol;
          return Padding(
            padding: EdgeInsets.only(top: getHeight(context) * 0.09),
            child: Column(children: <Widget>[
              const SizedBox(
                width: double.infinity,
                child: Text("Transaction details:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                        color: Colors.white)),
              ),
              const SizedBox(height: 20),
              FutureBuilder<double>(
                  future: Web3().getEstimatedBalanceOut(
                    double.parse(_valueController.text),
                    0.1,
                    Token(symbol, dropDownValue, decimals),
                    Token(symbol2, dropDownValue2, decimals2),
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          "Converting ${_valueController.text} $symbol to ${formatDouble(snapshot.data!, 5)} $symbol2",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              textBaseline: TextBaseline.alphabetic,
                              color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Text(
                          "Converting ${_valueController.text} $symbol to $symbol2",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              textBaseline: TextBaseline.alphabetic,
                              color: Colors.white));
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
              const SizedBox(height: 10),
            ]),
          );

        default:
          return const Text("Not a valid step!");
      }
    }

    return Scaffold(
      backgroundColor: primaryDarkColor(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: secondaryDarkColor(),
        centerTitle: true,
        title: const Text(
          'Swap',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: castedTokenList.isEmpty
          ? const Center(child: Text("Add tokens to get started!"))
          : Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DotStepper(
                      tappingEnabled: false,
                      activeStep: activeStep,
                      dotCount: upperBound,
                      dotRadius: 10,
                      shape: Shape.circle,
                      spacing: 20,
                      indicator: Indicator.shift,
                      fixedDotDecoration: const FixedDotDecoration(
                        color: Colors.grey,
                      ),
                      indicatorDecoration: const IndicatorDecoration(
                        // style: PaintingStyle.stroke,
                        // strokeWidth: 8,
                        color: Colors.greenAccent,
                      ),
                      lineConnectorDecoration: const LineConnectorDecoration(
                        color: Colors.red,
                        strokeWidth: 0,
                      ),
                      onDotTapped: (tappedDotIndex) {
                        setState(() {
                          activeStep = tappedDotIndex;
                        });
                      },
                    ),
                  ),
                ),
                getBody(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [previousButton(), nextButton()],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
