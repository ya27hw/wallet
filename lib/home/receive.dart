import "package:flutter/material.dart";
import 'package:eth_wallet/util/library.dart';
import 'package:line_icons/line_icons.dart';
import 'package:eth_wallet/backend/library.dart' as backend;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget receive() {
  String address = backend.Web3().returnAddress();

  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Receive',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: secondaryDarkColor(), width: 1)),
            child: QrImage(
              data: address,
              version: QrVersions.auto,
              size: 250,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            )),
        const SizedBox(height: 20),
        InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: address));
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: secondaryDarkColor(),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayAddress(address),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 5,
                    ),
                    IconButton(
                        onPressed: () async {
// Prompt user to share address
                          await Share.share(address, subject: 'Address');
                        },
                        icon: const Icon(LineIcons.share))
                  ],
                )))
      ],
    ),
  );
}
