import 'dart:io';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
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
  void dispose() {
    _receiveAddressController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Widget getBody() {
    switch (activeStep) {
      case 0:
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
        return Padding(
          padding: EdgeInsets.only(
              top: getHeight(context) * 0.08, left: 35, right: 35),
          child: Container(
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
        );

      case 2:
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
              child: Text("To: ${_receiveAddressController.text}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      textBaseline: TextBaseline.alphabetic,
                      color: Colors.white)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Text("Amount: ${_valueController.text} COINSYMBOL",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      textBaseline: TextBaseline.alphabetic,
                      color: Colors.white)),
            ),
          ]),
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
          await Web3().sendTokenTransaction(
            _receiveAddressController.text,
            double.parse(_valueController.text),
          );
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
