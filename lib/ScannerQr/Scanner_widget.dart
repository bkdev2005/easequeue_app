import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';

class ScannerQr extends StatefulWidget {
  const ScannerQr({super.key});

  @override
  State<ScannerQr> createState() => _ScannerQrState();
}

class _ScannerQrState extends State<ScannerQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          appBar: appBarWidget(context, 'Scan Qr'),
          body: SafeArea( child: Column( children: [
            Expanded(child: Column(
              children: [
                Expanded(child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                      borderColor: Colors.white,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300),
                ))

              ],
            )

            )]),
          ),
        ));
  }
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    dynamic data;
    controller.scannedDataStream.listen((scanData) {
      if(result == null){
        setState(() {
          result = scanData;
        });
        log('code ${result?.code}');
        if(result?.code != null){
          fetchData('business/${result?.code}', context)?.then((value) {
            if(value != null){
              log('value: ${value}');
              setState(() {
                data = value['data'];
              });
              Navigator.push(context, MaterialPageRoute(builder: (context)=> AddServicePageWidget(businessDetail: data, date: todayDate,))).then((value) { setState((){
                result = null;
              });
              controller.resumeCamera();
              });
            }
          });

        }
      }else{
        controller.pauseCamera();
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }



}