import 'dart:io';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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

  List<Step> getSteps() => [
        Step(title: const Text("To"), content: Container()),
        Step(title: const Text("Amount"), content: Container()),
        Step(title: const Text("Confirm"), content: Container()),
      ];

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

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //     });
  //     print(result?.format.name);
  //     print(result?.format.formatName);
  //   });
  // }

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
      body: Stepper(
        type: StepperType.horizontal,
        steps: getSteps(),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: primaryDarkColor(),
  //     appBar: AppBar(
  //       centerTitle: true,
  //       automaticallyImplyLeading: true,
  //       backgroundColor: secondaryDarkColor(),
  //       title: const Text(
  //         'Send Token',
  //         style: TextStyle(color: Colors.white),
  //       ),
  //     ),
  //     body: Stack(
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           child: Padding(
  //             padding: EdgeInsets.only(top : getHeight(context) * 0.04),
  //             child: Text(
  //               "To Address:",
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 18),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding:  EdgeInsets.only(top: getHeight(context) * 0.08, left: 35, right: 35),
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 color: const Color(0xFF32385F),
  //                 borderRadius: BorderRadius.circular(17)),
  //             child: TextField(
  //               controller: _receiveAddressController,
  //               maxLines: 1,
  //               decoration: InputDecoration(
  //                 suffixIcon: IconButton(
  //                     icon: const Icon(
  //                       Icons.qr_code_scanner_rounded,
  //                     ),
  //                     onPressed: () async {
  //                       String barcodeScanRes =
  //                           await FlutterBarcodeScanner.scanBarcode(
  //                               "green", "Back", true, ScanMode.QR);
  //                       _receiveAddressController.text = barcodeScanRes;
  //                     }),
  //                 contentPadding: const EdgeInsets.all(10),
  //                 border: InputBorder.none,
  //                 hintText: '0x...',
  //               ),
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.bottomCenter,
  //           child: Padding(
  //             padding: const EdgeInsets.only(bottom: 50),
  //             child: ElevatedButton(
  //               child: const Text("Next"),
  //               style: ElevatedButton.styleFrom(
  //                 textStyle: const TextStyle(fontSize: 17),
  //                 padding: EdgeInsets.symmetric(
  //                     horizontal: getWidth(context) * 0.20, vertical: 15),
  //                 onPrimary: Colors.black,
  //                 primary: const Color(0xFF41CD7D),
  //                 onSurface: Colors.grey,
  //                 elevation: 5,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(17)),
  //               ),
  //               onPressed: () async {
  //                 // TODO

  //                 // pop screen
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ),
  //         ),

  //         // const Padding(
  //         //   padding: EdgeInsets.only(top: 50, left: 35, right: 35),
  //         //   child: Text(
  //         //     "Choose Token and Amount:",
  //         //     style: TextStyle(fontSize: 18),
  //         //   ),
  //         // ),
  //         // Padding(
  //         //   padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
  //         //   child: Container(
  //         //     padding: EdgeInsets.only(bottom: 10),
  //         //     decoration: BoxDecoration(
  //         //         color: const Color(0xFF32385F),
  //         //         borderRadius: BorderRadius.circular(17)),
  //         //     child: TextField(
  //         //
  //         //       controller: _valueController,
  //         //       maxLines: 1,
  //         //       decoration: InputDecoration(
  //         //         prefixIcon: Text("ETH"),
  //         //         contentPadding: const EdgeInsets.all(15),
  //         //         border: InputBorder.none,
  //         //         hintText: 'Token Amount',
  //         //       ),
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}
