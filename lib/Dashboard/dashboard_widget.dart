import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:eqlite/BusinessPage/businessWidget.dart';
import 'package:eqlite/Component/AppointmentTime/AppointmentTimeWidget.dart';
import 'package:eqlite/DetailAppointment/detail_Appointment_Widget.dart';
import 'package:eqlite/GlobalSearch/globalSearch_Widget.dart';
import 'package:eqlite/Profile/Profile_widget.dart';
import 'package:eqlite/ScannerQr/Scanner_widget.dart';
import 'package:eqlite/Setting/Setting.dart';
import 'package:eqlite/function.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../Component/Confirmation/exitConfirmation.dart';
import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dashboard_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  List<dynamic> appointments = [];
  bool isMainLoading = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  WebSocket? _webSocket;
  StreamController<dynamic>? _messageStreamController;
  dynamic messageList;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    fetchData('categories/all', context)?.then((value) => setState(() {
          categoriesList =
              getJsonField(value!, r'''$.data[:]''', true)?.toList() ?? [];
        }));

    callAppointments();

  }

  void callAppointments(){
    fetchData(
        'customer_appointments/${FFAppState().userId}?start_date=${todayDate()}&status=1',
        context)
        ?.then((value) async {
      if (value != null) {
        if (value['data'] != null) {
          log('response: ${value['data']}');
          final data =
              getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
          setState(() {
            appointments = data;
            isMainLoading = false;
          });

          log('Appointments Customer: $appointments');
          await connect();
        } else {
          setState(() {
            isMainLoading = false;
          });
        }
      } else {
        setState(() {
          isMainLoading = false;
        });
      }
      log('value: $value');
    }).then((value) {

    });
  }

  Future<void> connect() async {
    String token = FFAppState().token;
    log('token: $token');
    try {
      _webSocket = await WebSocket.connect(
          'ws://15.206.84.199/api/v1/ws/${appointments[0]['queue_id']}/${todayDate()}',
          headers: {'Authorization': 'Bearer $token'});

      // Listen to incoming messages
      _webSocket?.listen(
        (message) {
          log('message data: $message');
          _messageStreamController?.add(message);
          setState(() {
            messageList = getJsonField(jsonDecode(message), r'''$.data''');
          });


          log('message: ${getJsonField(jsonDecode(message), r'''$.data''')}');
          log("Received: $message");
        },
        onError: (error) {
          print("WebSocket error: $error");
        },
        onDone: () {
          print("WebSocket connection closed");
        },
      );
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
    }
  }

  List<dynamic> categoriesList = [];

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final double maxScrollExtent = 100; // Adjust as per your requirement
    final double opacity = (_scrollOffset / maxScrollExtent).clamp(0.0, 1.0);

    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (context) {
                return Center(child: ExitWidget());
              }).then((value) {
            if (value) {
              return value;
            } else {
              return false;
            }
          });
          return false;
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: false,
            bottom: false,
            child: NestedScrollView(
              controller: _scrollController,
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  snap: false,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  automaticallyImplyLeading: false,
                  title: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 1.0 -
                                  opacity, // Hide text as scroll progresses
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileWidget(
                                                            backButton: true)))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              'http://15.206.84.199/shared/${FFAppState().user['profile_picture']}',
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 32,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                ); // Show fallback image
                                              },
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 0, 0, 0),
                                        child: GestureDetector(
                                          onTap: () {
                                            navigateTo(
                                                context,
                                                ProfileWidget(
                                                    backButton: true));
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                FFAppState()
                                                        .user['full_name'] ??
                                                    'Your Name',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 2, 0, 0),
                                                child: Text(
                                                  '+91-${FFAppState().user['phone_number'] ?? '8230xxxxx'}',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8,
                                    buttonSize: 40,
                                    fillColor:
                                        FlutterFlowTheme.of(context).primary,
                                    icon: Icon(Icons.qr_code_scanner_rounded,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 24),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScannerQr()));
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8,
                                    buttonSize: 40,
                                    fillColor:
                                        FlutterFlowTheme.of(context).primary,
                                    icon: FaIcon(
                                      FontAwesomeIcons.ellipsisV,
                                      color: FlutterFlowTheme.of(context).info,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SettingWidget()));
                                    },
                                  ),
                                ],
                              ),
                            )
                          ])),
                  actions: [],
                  centerTitle: false,
                  elevation: 0,
                )
              ],
              body: Builder(
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Material(
                            color: Colors.transparent,
                            elevation: 5,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    FlutterFlowTheme.of(context).primary
                                  ],
                                  stops: [0, 1],
                                  begin: AlignmentDirectional(0, -1),
                                  end: AlignmentDirectional(0, 1),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20, 5, 0, 0),
                                            child: Opacity(
                                              opacity: 1.0 -
                                                  opacity, // Hide text as scroll progresses
                                              child: Text(
                                                'What service do you need? 🤔',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            )),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20, 15, 20, 0),
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GlobalSearchWidget()));
                                          },
                                          readOnly: true,
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0.0,
                                                    ),
                                            hintText: 'Search anything',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            contentPadding: EdgeInsets.all(0),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                            ),
                                            suffixIcon: _model.textController!
                                                    .text.isNotEmpty
                                                ? InkWell(
                                                    onTap: () async {
                                                      _model.textController
                                                          ?.clear();
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.clear,
                                                      size: 22,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                              ),
                                          maxLines: null,
                                          minLines: 1,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Material(
                                  elevation: 2,
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16)),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/GOLDEN (2).gif'),
                                              fit: BoxFit.cover),
                                          borderRadius: const BorderRadius.only(
                                              bottomRight: Radius.circular(16),
                                              bottomLeft: Radius.circular(16))),
                                      height: 150,)),
                              Padding( padding: EdgeInsets.fromLTRB(0, 15, 0, 0), child:
                              Material(

                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(children: [
                                        if (appointments.isNotEmpty &&
                                            messageList != null)
                                          StreamBuilder(
                                              stream: _messageStreamController
                                                  ?.stream,
                                              builder: (context, snapshot) {
                                                final snap = snapshot.data;
                                                dynamic data;
                                                if (snap != null) {
                                                  setState(() {
                                                    data = getJsonField(
                                                        jsonDecode(snap),
                                                        r'''$.data''');
                                                  });
                                                }
                                                return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DetailAppointmentsWidget())).then((value) {
                                                        callAppointments();
                                                      });
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                    16),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                    16)),
                                                            color: FlutterFlowTheme.of(context).primaryBackground
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              20,
                                                              20,
                                                              20,
                                                              15),
                                                          child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize
                                                                .max,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(8),
                                                                    child: Image
                                                                        .network(
                                                                      'https://picsum.photos/seed/577/600',
                                                                      width: 60,
                                                                      height:
                                                                      60,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                      child:
                                                                      Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            appointments[0]['business_name'] ??
                                                                                'N/A',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Inter',
                                                                              fontSize: 16,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                            Text(
                                                                              '${(getJsonField(appointments[0], r'''$.business_address[0].unit_number''')).toString()}, ' + '${(getJsonField(appointments[0], r'''$.business_address[0].building''')).toString()}, ' + '${(getJsonField(appointments[0], r'''$.business_address[0].street_1''')).toString()}, ' + '${(getJsonField(appointments[0], r'''$.business_address[0].country''')).toString()}' + '-${(getJsonField(appointments[0], r'''$.business_address[0].postal_code''')).toString()}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 14,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0,
                                                                                3,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                            Text(
                                                                              '🕐 21 min - 8.0km',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 12,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // GestureDetector(
                                                                  //   onTap: (){},
                                                                  //   child: const Row( children: [
                                                                  //     Icon(Icons.info_outlined, size: 16,),
                                                                  //     Padding(padding: EdgeInsets.only(left: 2),child: Text('INFO'))]
                                                                  // ))
                                                                ],
                                                              ),
                                                              Divider(
                                                                thickness: 1,
                                                                height: 20,
                                                                color: Color(
                                                                    0xB2BABABA),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    15,
                                                                    0,
                                                                    15,
                                                                    0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                        child:
                                                                        Column(
                                                                          mainAxisSize:
                                                                          MainAxisSize.max,
                                                                          children: [
                                                                            Text(
                                                                              '${messageList['current_token'] ?? '0'}',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 20,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'Current token',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 12,
                                                                                color: Color(0xFFADADAD),
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                      50,
                                                                      child:
                                                                      VerticalDivider(
                                                                        thickness:
                                                                        1,
                                                                        color: Color(
                                                                            0xB2D0D0D0),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                        child:
                                                                        Column(
                                                                          mainAxisSize:
                                                                          MainAxisSize.max,
                                                                          children: [
                                                                            Text(
                                                                              '${messageList['waiting_count'] ?? ''}',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 20,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'Waiting count',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 12,
                                                                                color: Color(0xFFADADAD),
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                      50,
                                                                      child:
                                                                      VerticalDivider(
                                                                        thickness:
                                                                        1,
                                                                        color: Color(
                                                                            0xB2D0D0D0),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            5,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                        Column(
                                                                          mainAxisSize:
                                                                          MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              '${messageList['estimated_appointment_time'] ?? ''}',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 20,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'Waiting time',
                                                                              textAlign: TextAlign.center,
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 12,
                                                                                color: Color(0xFFADADAD),
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )));
                                              })
                                      ]))),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF696969),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          5, 0, 5, 0),
                                      child: Text(
                                        'EXPLORE',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Color(0xFF696969),
                                              fontSize: 16,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF696969),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      5, 20, 5, 10),
                                  child: Wrap(
                                      runSpacing: 10,
                                      spacing: 10,
                                      children: List.generate(
                                        categoriesList.length,
                                        (categoryListIndex) {
                                          final categoryListItem =
                                              categoriesList[categoryListIndex];
                                          return GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BusinessPageWidget(
                                                              categoryId:
                                                                  categoryListItem[
                                                                      'uuid'],
                                                            ))).then((value) {
                                                  callAppointments();
                                                });
                                              },
                                              child: Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3) -
                                                      20,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade400,
                                                        blurRadius: 2.2,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            12, 15, 12, 10),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Card(
                                                          clipBehavior: Clip
                                                              .antiAliasWithSaveLayer,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          elevation: 2,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/scissor-and-comb.png',
                                                                width: 45,
                                                                height: 45,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(0,
                                                                      10, 0, 0),
                                                          child: Text(
                                                            categoryListItem[
                                                                    'name'] ??
                                                                '',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )));
                                        },
                                      ))),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 200, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF696969),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          5, 0, 5, 0),
                                      child: Text(
                                        'New Feature Coming Soon',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Color(0xFF696969),
                                              fontSize: 16,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF696969),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                  ),
                                  child: Image.asset(
                                    'assets/images/Live_your.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }
}
