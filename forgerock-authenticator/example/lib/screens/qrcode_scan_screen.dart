/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forgerock_authenticator_example/widgets/app_bar.dart';
import 'package:forgerock_authenticator_example/widgets/text_scale.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanScreen extends StatefulWidget {
  const QRCodeScanScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScanScreen> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ForgeRockAppBar(
        actions: const <Widget>[],
        title: AppLocalizations.of(context).qrCodeScanScreenTitle,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _buildQrView(context)
          ),
          Positioned(
            child: Align(
              alignment: FractionalOffset.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextScale(
                  child: Text(
                      AppLocalizations.of(context).qrCodeScanScreenMessage,
                      style: const TextStyle(fontSize: 16, color: Colors.white
                    )
                  )
                )
              )
            )
          ),
          Positioned(
            child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: FractionalOffset.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: IconButton(
                          key: const Key('flash-camera-button'),
                          color: Colors.white,
                          icon: FutureBuilder<dynamic>(
                            future: controller?.getFlashStatus(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              if(snapshot.data != null) {
                                final bool flash = snapshot.data as bool;
                                if(flash) {
                                  return const Icon(Icons.flash_on, size: 38.0);
                                } else {
                                  return const Icon(Icons.flash_off, size: 38.0);
                                }
                              } else {
                                return const Icon(Icons.flash_off, size: 38.0);
                              }
                            },
                            ),
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                        )
                      )
                    )
                  ),
                  Align(
                    alignment: FractionalOffset.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: IconButton(
                          key: const Key('flip-camera-button'),
                          color: Colors.white,
                          icon: const Icon(Icons.flip_camera_ios_outlined, size: 38.0),
                        onPressed: () async {
                          await controller?.flipCamera();
                          setState(() {});
                          },
                        )
                      )
                    )
                  )
                ]),
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // change the scanArea and overlay according device dimensions.
    final double scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (QRViewController ctrl, bool p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((Barcode scanData) {
      // setState(() {
      //   result = scanData;
      // });

      this.controller.stopCamera();
      Navigator.pop(context, scanData.code);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      _showPermissionDeniedResult(context);
    }
  }

  void _showPermissionDeniedResult(BuildContext context) {
    final SnackBar snackBar = SnackBar(
      content: Text(AppLocalizations.of(context).errorCameraAccessNotGranted,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height > 800 ? 18 : 16,
            height: 1.3, color: Colors.white,
            fontWeight: FontWeight.w500
        ),
      ),
      backgroundColor: const Color(0xFF34A853),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}