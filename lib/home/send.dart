import 'dart:io';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:im_stepper/stepper.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:eth_wallet/backend/library.dart';

class Send extends StatefulWidget {
  const Send({Key? key}) : super(key: key);

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  final _receiveAddressController = TextEditingController();
  final _valueController = TextEditingController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  String dropDownValue = "";
  String operationMode = "ETH";
  int decimals = 0;
  String symbol = "";

  final tokenBox = Hive.box("tokenBox");
  final defNetwork = Web3().defaultNetwork;

  int activeStep = 0;
  int upperBound = 3;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      // controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    final t = tokenBox.get(defNetwork);
    if (t != null) {
      dropDownValue = t[0].address;
      decimals = t[0].decimals;
      symbol = t[0].symbol;
    }
    print(dropDownValue);
  }

  @override
  void dispose() {
    _receiveAddressController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Widget getBody() {
    switch (activeStep) {
      case 0:
        // Select address here...
        return Padding(
          padding: EdgeInsets.only(
              top: getHeight(context) * 0.08, left: 35, right: 35),
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF32385F),
                borderRadius: BorderRadius.circular(17)),
            child: TextField(
              controller: _receiveAddressController,
              maxLines: 1,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                    ),
                    onPressed: () async {
                      String barcodeScanRes =
                          await FlutterBarcodeScanner.scanBarcode(
                              "green", "Back", true, ScanMode.QR);
                      _receiveAddressController.text = barcodeScanRes;
                    }),
                contentPadding: const EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: '0x...',
              ),
            ),
          ),
        );

      case 1:
        var tokenList = tokenBox.get(defNetwork) ?? <Token>[];
        List<Token> castedTokenList = List.castFrom(tokenList);

        // Select token and value here...
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
            ],
          ),
        );

      case 2:
        symbol = operationMode == "ETH" ? "ETH" : symbol;
        return FutureBuilder(
          future: Web3().getGasFees(),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasData) {
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
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                        "To: ${displayAddress(_receiveAddressController.text)}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            textBaseline: TextBaseline.alphabetic,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Text("Amount: ${_valueController.text} $symbol",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            textBaseline: TextBaseline.alphabetic,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                        "Gas Fees: ${formatDouble(snapshot.data!, 3)} GWEI",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            textBaseline: TextBaseline.alphabetic,
                            color: Colors.white)),
                  ),
                ]),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(top: getHeight(context) * 0.09),
                child: Column(children: const [CircularProgressIndicator()]),
              );
            }
          },
        );

      default:
        return const Text("Error");
    }
  }

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
        fixedSize: const Size(140, 60),
        onPrimary: Colors.black,
        primary: const Color(0xFF41CD7D),
        onSurface: Colors.grey,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      onPressed: () async {
        // pop screen
        if (activeStep < upperBound - 1) {
          setState(() {
            activeStep++;
          });
        } else if (activeStep == upperBound - 1) {
          // send transaction

          try {
            if (operationMode == "ETH") {
              await Web3().sendTokenTransaction(
                _receiveAddressController.text,
                double.parse(_valueController.text),
              );
            } else {
              await Web3().sendTokenTransaction(_receiveAddressController.text,
                  double.parse(_valueController.text), dropDownValue, decimals);
            }
          } catch (e) {
            // Get error msg
            String errorMsg = e.toString();
            Navigator.pop(context);

            if (errorMsg.contains("insufficient funds")) {
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Insufficient funds"),
                      content: const Text(
                          "You don't have enough funds to send this transaction"),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('Ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            } else {
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Error"),
                      content:
                          const Text("Something went wrong, please try again"),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('Ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            }
          }

          // pop screen
        }
      },
    );
  }

  Widget previousButton() {
    return ElevatedButton(
      child: const Text("Previous"),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(140, 60),
        textStyle: const TextStyle(fontSize: 17),
        //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        onPrimary: Colors.black,
        primary: const Color(0xFF41CD7D),
        onSurface: Colors.grey,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: secondaryDarkColor(),
        title: const Text(
          'Send Token',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
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
            padding: const EdgeInsets.only(bottom: 50),
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
