import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
//     as mlkit;
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';

class ScannerQr extends StatefulWidget {
  const ScannerQr({super.key, this.lat, this.long});
  final String? lat;
  final String? long;

  @override
  State<ScannerQr> createState() => _ScannerQrState();
}

class _ScannerQrState extends State<ScannerQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

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
            backgroundColor: Colors.black,
            appBar: appBarWidget(context, 'Scan Qr'),
            body: SafeArea(
              child: Column(children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: QRView(
                              key: qrKey,
                              onQRViewCreated: _onQRViewCreated,
                              overlay: QrScannerOverlayShape(
                                borderColor: Colors.white,
                                borderRadius: 10,
                                borderLength: 30,
                                borderWidth: 10,
                                cutOutSize: 300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: InkWell(
                          onTap: _scanFromGallery,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upload from gallery',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ]),
            )));
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    dynamic data;
    controller.scannedDataStream.listen((scanData) {
      if (result == null) {
        setState(() {
          result = scanData;
        });
        log('code ${result?.code}');
        if (result?.code != null) {
          fetchData('business/${result?.code}', context)?.then((value) {
            if (value != null) {
              log('value: ${value}');
              setState(() {
                data = value['data'];
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddServicePageWidget(
                            lat: widget.lat,
                            long: widget.long,
                          ))).then((value) {
                setState(() {
                  result = null;
                });
                controller.resumeCamera();
              });
            }
          });
        }
      } else {
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

  void _toggleFlash() async {
    await controller?.toggleFlash();
    final status = await controller?.getFlashStatus();
    setState(() {
      isFlashOn = status ?? false;
    });
  }

  Future<void> _handleScannedCode(String? code) async {
    if (code != null) {
      log('Scanned code: $code');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddServicePageWidget(
                    businessId: code,
                    lat: widget.lat,
                    long: widget.long,
                  )));
      // Your logic here, e.g., API call or navigation
    }
  }

  Future<void> scanQrFromImage(String filePath) async {
    // 1. Load image file
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      print("❌ Could not decode image");
      return;
    }

    // 2. Convert image pixels to Int32List (ARGB)
    final rgba = image.getBytes(); // Uint8List [R, G, B, A, R, G, B, A, ...]
    final pixels = Int32List(image.width * image.height);

    for (int i = 0, j = 0; i < rgba.length; i += 4, j++) {
      int r = rgba[i];
      int g = rgba[i + 1];
      int b = rgba[i + 2];
      int a = rgba[i + 3];
      // Pack into ARGB 32-bit int
      pixels[j] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    // 3. Pass Int32List to ZXing
    final source = RGBLuminanceSource(image.width, image.height, pixels);
    final bitmap = BinaryBitmap(HybridBinarizer(source));
    final reader = QRCodeReader();

    try {
      final result = reader.decode(bitmap);
      _handleScannedCode(result.text);
      print("✅ QR Code Found: ${result.text}");
    } catch (e) {
      print("❌ No QR Code detected: $e");
    }
  }

  Future<void> _scanFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    scanQrFromImage(image.path);
  //   final mlkit.InputImage inputImage =
  //       mlkit.InputImage.fromFilePath(image.path);
  //   final barcodeScanner = mlkit.BarcodeScanner();
  //
  //   try {
  //     final List<mlkit.Barcode> barcodes =
  //         await barcodeScanner.processImage(inputImage);
  //     if (barcodes.isNotEmpty) {
  //       final barcode = barcodes.first;
  //       _handleScannedCode(barcode.rawValue);
  //     } else {
  //       Fluttertoast.showToast(msg: 'No qr code found in image');
  //     }
  //   } catch (e) {
  //     log('Error scanning image: $e');
  //   } finally {
  //     barcodeScanner.close();
  //   }
  }
}
