import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/flutter_flow/flutter_flow_icon_button.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import '../../function.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CongratulationWidget extends StatefulWidget {
  const CongratulationWidget({super.key, this.response});
  final dynamic response;
  @override
  State<CongratulationWidget> createState() => _CongratulationWidgetState();
}

class _CongratulationWidgetState extends State<CongratulationWidget> {
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey globalKey = GlobalKey();
  String businessAddress = '';
  @override
  void initState() {
    businessAddress =
        '${getJsonField(widget.response, r'''$.business.address.unit_number''') != '' ? '${getJsonField(widget.response, r'''$.business.address.unit_number''')}, ' : ''}'
        '${getJsonField(widget.response, r'''$.business.address.building''')}, '
        '${getJsonField(widget.response, r'''$.business.address.street_1''')}, '
        '${getJsonField(widget.response, r'''$.business.address.country''')}-'
        '${getJsonField(widget.response, r'''$.business.address.postal_code''')}';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          navigateTo(context, HomePageWidget());
          return true;
        },
        child: SafeArea(
            child: Material(
              color: FlutterFlowTheme.of(context).primaryBackground,
          child: Column( children: [
            Expanded(child: SingleChildScrollView( child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RepaintBoundary(
                    key: globalKey,
                    child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/images/congrat.png',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.8,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 20, 0, 0),
                                    child: Text(
                                      'Booking confirmed',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            fontSize: 22,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors
                                                .transparent, // Or any color for the bottom glow
                                            Colors.green.withOpacity(
                                                0.12), // Or any color for the bottom glow
                                          ],
                                        ),
                                        border: Border.all(
                                            color: Colors.green.shade100),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Padding(
                                          padding: EdgeInsets.all(17),
                                          child: Column(spacing: 10, children: [
                                            appointmentDetail(
                                                'Business name',
                                                widget.response['business']
                                                        ['name'] ??
                                                    ''),
                                            appointmentDetail(
                                                'Token number',
                                                widget.response[
                                                        'token_number'] ??
                                                    '00'),
                                            appointmentDetail(
                                                'Counter',
                                                widget.response['queue_id']
                                                        ['name'] ??
                                                    ''),
                                            appointmentDetail(
                                                'Services',
                                                serviceName(getJsonField(
                                                    widget.response,
                                                    r'''$.queue_user_services[:]''',
                                                    true))),
                                            appointmentDetail(
                                                'Date & Time',
                                                widget.response[
                                                        'estimated_enqueue_time'] ??
                                                    ''),
                                            appointmentDetail(
                                                'Address', businessAddress,
                                                icon: Icons.directions_rounded),
                                          ]))),
                                ])))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.green.withOpacity(0.12)
                        ),
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Cancellation available',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                      ]),
                                  SizedBox(height: 2),
                                  Text(
                                    'You may cancel your appointment before your turn.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              ],
            ),
          )),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                        EdgeInsetsDirectional.fromSTEB(0, 10, 8, 0),
                        child: FlutterFlowIconButton(
                          borderRadius: 30,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () async {
                            log('call ');
                            await decodeBase64ToFile().then((onValue) {
                              navigateTo(context, HomePageWidget());
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsetsDirectional.fromSTEB(8, 10, 8, 0),
                        child: FlutterFlowIconButton(
                          borderRadius: 30,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () async {
                            log('call ');
                            await decodeBase64ToFile().then((_) {
                              navigateTo(context, HomePageWidget());
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsetsDirectional.fromSTEB(8, 10, 0, 0),
                        child: FlutterFlowIconButton(
                          borderRadius: 30,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () async {
                            if (FFAppState().fistTimeUser) {
                              final response =
                              await fetchData('user/me', context)
                                  ?.then((value) {
                                if (value != null) {}
                              });
                            }
                            navigateTo(context, HomePageWidget());
                          },
                        ),
                      ),
                    ]))
       ]) )));
  }

  Widget appointmentDetail(String label, String value, {IconData? icon}) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.black54,
                      fontSize: 12,
                      letterSpacing: 0.0,
                    ),
              ),
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          )),
          if (icon != null)
            InkWell(
                onTap: () {
                  openGoogleMapSearch(businessAddress);
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      icon,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22,
                    ),
                  ),
                )),
        ]);
  }

  String serviceName(List<dynamic> services) {
    // Use a list to collect the service names
    List<String> names = [];
    // Iterate over each service in the list
    for (final serv in services) {
      // Access the 'name' field inside 'service_id' and add it to the names list
      names.add((serv['queue_service_id']['service_id']['name']));
    }
    // Join the list of names with a comma and return the result
    return names.join(', ');
  }

  Future<void> decodeBase64ToFile() async {
    try {
      RenderRepaintBoundary boundry =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundry.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? pngBytes = byteData?.buffer.asUint8List();
      final savedPath = await saveImage(pngBytes!, 'saved_image.png');
      // debugPrint('Image saved to: $savedPath');

      // ImageGallerySaver.saveImage(
      //   pngBytes!,
      //   quality: 100,
      //   name: "easequeue_screenshot", // or any name
      // );
      return shareImage(pngBytes!, 'image/png', 'shared_image.png');
    } catch (e) {
      log('Error decoding Base64 and saving file: $e');
    }
  }

  Future<String> saveImage(Uint8List imageBytes, String fileName) async {
    // Get directory to store the image
    final Directory directory =
        await getApplicationDocumentsDirectory(); // or use getDownloadsDirectory() on desktop
    final String path = '${directory.path}/$fileName';

    final File imageFile = File(path);
    await imageFile.writeAsBytes(imageBytes);
    return path;
  }

  Future<void> shareImage(
      Uint8List imageBytes, String mimeType, String fileName) {
    final ByteData byteData =
        ByteData.sublistView(imageBytes.buffer.asByteData());

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    tempFile.writeAsBytesSync(Uint8List.view(byteData.buffer));

    return Share.shareFiles([tempFile.path], text: '', mimeTypes: [mimeType]);
  }
}
