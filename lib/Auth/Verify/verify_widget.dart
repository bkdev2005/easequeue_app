import 'dart:async';
import 'dart:developer';
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/Profile/Profile_widget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../apiFunction.dart';
import '../../app_state.dart';
import '../../function.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'verify_model.dart';
export 'verify_model.dart';

class VerifyWidget extends StatefulWidget {
  const VerifyWidget({super.key, required this.phone, required this.otp});
  final String phone;
  final String otp;
  @override
  State<VerifyWidget> createState() => _VerifyWidgetState();
}

class _VerifyWidgetState extends State<VerifyWidget> {
  late VerifyModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const int initialTime = 5 * 60; // 5 minutes in seconds
  int timeLeft = initialTime;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          if (timeLeft < 1) {
            t.cancel();
            isRunning = false;
          } else {
            timeLeft--;
          }
        });
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void pauseTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = initialTime;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    _model = createModel(context, () => VerifyModel());
    _model.pinCodeController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    timer?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.max,
                children: [],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify with OTP',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                        child: Text(
                          'Enter the OTP you received to',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF828282),
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                        child: Text(
                          '+91-${widget.phone}',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: Colors.black54,
                                    fontSize: 15,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 20, 20, 0),
                        child: PinCodeTextField(
                          autoDisposeControllers: false,
                          appContext: context,
                          length: 6,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Inter',
                                    color: Colors.black,
                                    letterSpacing: 0.0,
                                  ),
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          enableActiveFill: false,
                          autoFocus: true,
                          enablePinAutofill: false,
                          errorTextSpace: 16,
                          showCursor: true,
                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                          obscureText: false,
                          hintCharacter: '-',
                          keyboardType: TextInputType.number,
                          pinTheme: PinTheme(
                            fieldHeight: 44,
                            fieldWidth: 44,
                            borderWidth: 2,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            shape: PinCodeFieldShape.box,
                            activeColor: FlutterFlowTheme.of(context).primary,
                            inactiveColor: Color(0xFFE6E6E6),
                            selectedColor: FlutterFlowTheme.of(context).primary,
                          ),
                          controller: _model.pinCodeController,
                          onChanged: (_) {},
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _model.pinCodeControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      //   child: Text(
                      //     'By continue to next step you are accepting Terms & Conditions and Privacy Policy !',
                      //     style:
                      //     FlutterFlowTheme.of(context).bodyMedium.override(
                      //       fontFamily: 'Inter',
                      //       color: Color(0xFF828282),
                      //       fontSize: 12,
                      //       letterSpacing: 0.0,
                      //       fontWeight: FontWeight.normal,
                      //       lineHeight: 1.5,
                      //     ),
                      //   ),
                      // ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: (isRunning)
                              ? Text(
                                  'Resend OTP In ${formatTime(timeLeft)}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                      ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final response = await preAuthApi({
                                      "phone_number": widget.phone,
                                      "device_info": jsonDecode(
                                          FFAppState().deviceInfo)['platform']
                                    }, 'send_otp')
                                        .then((value) {
                                      Fluttertoast.showToast(
                                          msg: 'OTP sent successfully');
                                      startTimer();
                                    });
                                  },
                                  child: Text(
                                    'Resend OTP',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                        ),
                                  )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                child: FFButtonWidget(
                  onPressed: () async {
                    if (_model.pinCodeController!.text.isNotEmpty) {
                      final response = await preAuthApi({
                        "country_code": "+91",
                        "phone_number": widget.phone.toString(),
                        "otp": _model.pinCodeController.text.toString(),
                        "is_customer": true
                      }, 'verify_otp')
                          .then((value) {
                        if (value != null) {
                          log('value: $value');
                          if (value['data'] != null) {
                            final data = value['data'];
                            setState(() {
                              FFAppState().phone = widget.phone.toString();
                              FFAppState().token =
                                  getJsonField(data, r'''$.access_token''');
                              FFAppState().user =
                                  getJsonField(data, r'''$.user''');
                            });

                            fetchData('user/me', context)?.then((value) async {
                              if (value != null) {
                                log('data: $value');
                                if (value['data'] != null) {
                                  final data = value['data'];
                                  setState(() {
                                    FFAppState().user = data;
                                    FFAppState().userId = data['uuid'];
                                  });
                                }

                                if (checkNull(FFAppState().user['full_name']) ==
                                    true) {
                                  final storeToken = await sendData({},
                                          'store-token/?user_id=${FFAppState().user['uuid']}&token=${FFAppState().fcmToken}')
                                      .then((response) {
                                    log('response: $response');
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePageWidget()));
                                } else {
                                  navigateTo(context,
                                      const ProfileWidget(backButton: false));
                                }
                              }
                            });
                          }
                        }
                      });
                    }
                  },
                  text: 'Save',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55,
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
