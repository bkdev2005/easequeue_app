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

  @override
  void initState() {
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
        child: SafeArea(child: Material(
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RepaintBoundary(
                        key: globalKey,
                        child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.asset(
                                              'assets/images/congrat.png',
                                              width: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 20, 0, 0),
                                        child: Text(
                                          'Your Appointment Booked Successfully!',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 18,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 10, 0, 15),
                                        child: Text(
                                          'We have sent your booking information to your email address.',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(2, 0, 2, 0),
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    2, 0, 2, 0),
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    2, 0, 2, 0),
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 20, 0, 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Token Number :',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 18,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    widget.response[
                                                            'token_number'] ??
                                                        '00',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Color(0xFF929292),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 0, 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Business :',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 18,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    widget.response['business']
                                                            ['name'] ??
                                                        '',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Color(0xFF929292),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Queue :',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 18,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Text(
                                                  widget.response['queue_id']
                                                          ['name'] ??
                                                      '',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Color(0xFF929292),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Service :',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 18,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Text(
                                                  serviceName(getJsonField(
                                                      widget.response,
                                                      r'''$.queue_user_services[:]''',
                                                      true)),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Color(0xFF9C9C9C),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Date & Time :',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 18,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Text(
                                                  widget.response['queue_date'],
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])))),
                    Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(0, 25, 8, 0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 30,
                                  fillColor: FlutterFlowTheme.of(context).primary,
                                  icon: Icon(Icons.share_rounded, color: Colors.white, size: 36,),
                                  onPressed: () async {
                                    log('call ');
                                    await decodeBase64ToFile().then((onValue){
                                      navigateTo(context, HomePageWidget());
                                    });
                                  },

                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 25, 8, 0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 30,
                                  fillColor: FlutterFlowTheme.of(context).primary,
                                  icon: Icon(Icons.download_rounded, color: Colors.white, size: 36,),
                                  onPressed: () async {
                                    log('call ');
                                    await decodeBase64ToFile().then((_){
                                      navigateTo(context, HomePageWidget());
                                    });
                                  },

                                ),
                              ),
                               Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(8, 25, 0, 0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 30,
                                  fillColor: FlutterFlowTheme.of(context).primary,
                                  icon: Icon(Icons.home_rounded, color: Colors.white, size: 36,),
                                  onPressed: () async {
                                    if (FFAppState().fistTimeUser) {
                                      final response =
                                          await fetchData('user/me', context)
                                              ?.then((value) {
                                        if (value != null) {
                                          // FFAppState().token = getJsonField(value, r'''$.data.access_token''');
                                        }
                                      });
                                    }
                                    navigateTo(context, HomePageWidget());
                                  },

                                ),
                              ),
                            ]))
                  ],
                ),
              ),
            )));
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
    final Directory directory = await getApplicationDocumentsDirectory(); // or use getDownloadsDirectory() on desktop
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
