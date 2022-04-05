import 'dart:io';
import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Send extends StatefulWidget {
  const Send({Key? key}) : super(key: key);

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  final _receiveAddressController = TextEditingController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50, left: 35, right: 35),
            child: Text(
              "To Address:",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
            child: Container(
              //padding: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: const Color(0xFF32385F),
                  borderRadius: BorderRadius.circular(17)),
              child: TextField(
                onChanged: (String value) {
                  setState(() {});
                },
                controller: _receiveAddressController,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                      ),
                      onPressed: () => QRView(
                          cameraFacing: CameraFacing.back,
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          )),
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: '0x...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
