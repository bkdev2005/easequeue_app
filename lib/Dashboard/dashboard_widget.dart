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
import 'package:screenshot/screenshot.dart';

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
  List<dynamic> messageList = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? latitude;
  final Map<String, dynamic> messageMap = {};
  final Map<String, WebSocket> _webSocketMap = {};
  String? longitude;

  void trackLocation() {
    getLocation().then((value) {
      log('location: ${value?[1]}, ${value?[2]}');
      latitude = value?[1].toString();
      longitude = value?[2].toString();
    });
  }

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
    trackLocation();

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    fetchData('categories/all', context)?.then((value) => setState(() {
          categoriesList =
              getJsonField(value!, r'''$.data[:]''', true)?.toList() ?? [];
        }));

    log('token: ${FFAppState().token}');

    callAppointments();
  }

  void callAppointments() {
    log('Calling Appointments');
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
          log('length: ${appointments.length}');
          for (final appointment in appointments) {
            final queueId = appointment['queue_id'];
            if (queueId != null && queueId != '') {
              connect(queueId); // Don't await; connect all simultaneously
            }
          }

          setState(() {
            isMainLoading = false;
          });
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
      log('Called Appointments');
    }).then((value) {});
  }

  Future<void> connect(String queueId) async {
    log('Calling Queue: $queueId websocket');
    try {
      final socket = await WebSocket.connect(
        'ws://15.207.20.38/api/v1/ws/$queueId/${todayDate()}',
        headers: {'Authorization': 'Bearer ${FFAppState().token}'},
      );

      _webSocketMap[queueId] = socket;

      socket.listen(
        (message) {
          log('message data: $message');
          _messageStreamController?.add(message);

          final msgData = getJsonField(jsonDecode(message), r'''$.data''');
          log('message data: $msgData');

          setState(() {
            messageMap[queueId] = msgData;
            messageList.add(msgData);
          });

          log("Received: $message");
        },
        onError: (error) {
          print("WebSocket error for $queueId: $error");
        },
        onDone: () {
          print("WebSocket closed for $queueId");
        },
      );
    } catch (e) {
      print("Failed to connect WebSocket for $queueId: $e");
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
                                              'http://15.207.20.38/shared/${FFAppState().user['profile_picture']}',
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
                                          maxLines: 1,
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
                                            fit: BoxFit.contain),
                                        borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(16))),
                                    height: 150,
                                  )),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Stack(
                                  children: [
                                    if (appointments.isNotEmpty)
                                      StreamBuilder(
                                        stream:
                                            _messageStreamController?.stream,
                                        builder: (context, snapshot) {
                                          final snap = snapshot.data;
                                          log('data stream: ${snapshot.data}');
                                          dynamic data;
                                          if (snap != null) {
                                            data = getJsonField(jsonDecode(snap), r'''$.data''');
                                          }
                                          

                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 200,
                                                child: PageView.builder(
                                                  controller: _pageController,
                                                  itemCount:
                                                      appointments.length,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      _currentPage = index;
                                                    });
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    final appointmentDetail =
                                                        appointments[index];
                                                    final queueId =
                                                        appointmentDetail[
                                                            'queue_id'];
                                                    final message =
                                                        messageMap[queueId] ??
                                                            {};
                                                    return Padding(
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        child: Material(
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            elevation: 2,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            DetailAppointmentsWidget(),
                                                                  ),
                                                                ).then((value) {
                                                                  callAppointments();
                                                                });
                                                              },
                                                              child: Container(
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          10,
                                                                          20,
                                                                          10,
                                                                          15),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                                padding: EdgeInsets.only(top: 3),
                                                                                child: Container(
                                                                                    width: 45,
                                                                                    height: 45,
                                                                                    decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          color: Colors.black26,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(5)),
                                                                                    child: (appointmentDetail['profile_picture'] != null)
                                                                                        ? Image.network(
                                                                                            'http://15.207.20.38/shared/${appointmentDetail['profile_picture']}',
                                                                                            fit: BoxFit.contain,
                                                                                          )
                                                                                        : Padding(padding: EdgeInsets.all(8), child: Image.asset('assets/images/images.png')))),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.only(start: 10),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      appointmentDetail['business_name'] ?? 'N/A',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium?.override(
                                                                                                fontFamily: 'Inter',
                                                                                                fontSize: 16,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ) ??
                                                                                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    ),
                                                                                    Text(
                                                                                      '${((getJsonField(appointmentDetail, r'''$.business_address[0].unit_number''')).toString() != '') ? (getJsonField(appointmentDetail, r'''$.business_address[0].unit_number''')).toString() + ', ' : ''}${(getJsonField(appointmentDetail, r'''$.business_address[0].building''')).toString()}, ${(getJsonField(appointmentDetail, r'''$.business_address[0].street_1''')).toString()}, ${(getJsonField(appointmentDetail, r'''$.business_address[0].country''')).toString()}-${(getJsonField(appointmentDetail, r'''$.business_address[0].postal_code''')).toString()}',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium?.override(
                                                                                                fontFamily: 'Inter',
                                                                                                fontSize: 14,
                                                                                              ) ??
                                                                                          TextStyle(fontSize: 14),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const Divider(
                                                                          thickness:
                                                                              1,
                                                                          color:
                                                                              Color(0xB2BABABA)),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                15),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            _buildInfoColumn('Your token',
                                                                                '${message['current_token'] ?? '0'}'),
                                                                            _buildDivider(),
                                                                            _buildInfoColumn('Waiting count',
                                                                                '${message['waiting_count'] ?? ''}'),
                                                                            _buildDivider(),
                                                                            _buildInfoColumn('Waiting time',
                                                                                '${message['estimated_appointment_time'].toString()}'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )));
                                                  },
                                                ),
                                              ),
                                              // Dot indicator
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(
                                                      appointments.length,
                                                      (index) {
                                                    return Container(
                                                      width: 8,
                                                      height: 8,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: _currentPage ==
                                                                index
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                            : Colors
                                                                .grey.shade300,
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      )
                                  ],
                                ),
                              ),
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
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                    ),
                                                  ),
                                                ).then((value) {
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
                                    fit: BoxFit.fill,
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

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium?.override(
                    fontFamily: 'Inter',
                    fontSize: 20,
                  ) ??
              TextStyle(fontSize: 20),
        ),
        Text(
          title,
          style: FlutterFlowTheme.of(context).bodyMedium?.override(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: const Color(0xFFADADAD),
                  ) ??
              TextStyle(fontSize: 12, color: Color(0xFFADADAD)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const SizedBox(
      height: 50,
      child: VerticalDivider(
        thickness: 1,
        color: Color(0xB2D0D0D0),
      ),
    );
  }
}
