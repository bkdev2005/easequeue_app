import 'dart:async';
import 'dart:developer';
import 'package:eqlite/Component/Congratulate/congratulation_widget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sliding_action_button/sliding_action_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Component/AppointmentType/appointment_type_widget.dart';
import '../Component/Congratulate/confirm_ui_widget.dart';
import '../apiFunction.dart';
import '../websocket.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'fix_appointment_model.dart';
export 'fix_appointment_model.dart';

class FixAppointmentWidget extends StatefulWidget {
  const FixAppointmentWidget(
      {super.key,
      required this.services,
      required this.date,
      required this.businessName,
      required this.formatDate,
      required this.uuid});
  final List<dynamic> services;
  final String date;
  final String businessName;
  final String formatDate;
  final String uuid;
  @override
  State<FixAppointmentWidget> createState() => _FixAppointmentWidgetState();
}

class _FixAppointmentWidgetState extends State<FixAppointmentWidget> {
  late FixAppointmentModel _model;
  WebSocket? _webSocket;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> queueList = [];
  dynamic messageList;
  String? selectedQueueId;
  String url = 'running_queues/?';
  StreamController<dynamic>? _messageStreamController;
  // final webSocketClient = WebSocketClient();
  WebSocketChannel? webSocketChannel;
  int selectedLunchTimeIndex = -1;
  WebSocketService? _webSocketService;
  String? _token; // Token to be passed
  int selectedGuests = 0;
  bool isLoading = false;
  dynamic selectQueue;
  List<String> times = [
    "12:00 PM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM"
  ];
  List<dynamic> serviceSelectQueue = [];

  void addIdInUrl(List<String> serviceUUID) {
    for (int index = 0; index < serviceUUID.length; index++) {
      if (index == 0) {
        setState(() {
          url += 'queue_service_ids=${serviceUUID[index]}';
        });
      } else {
        setState(() {
          url += '&queue_service_ids=${serviceUUID[index]}';
        });
      }
    }
  }

  Future<void> connect(String url) async {
    String token = FFAppState().token;
    log('token: $token');
    log('queueId: ${queueList[0]['queue_id']}');
    log('date: ${widget.date}');
    try {
      _webSocket = await WebSocket.connect(
          'ws://43.204.107.110/api/v1/ws/$url/${widget.date}',
          headers: {'Authorization': 'Bearer $token'});
      print("Connected to WebSocket at $url");

      // Listen to incoming messages
      _webSocket?.listen(
        (message) {
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

  @override
  void initState() {
    super.initState();
    List<String> allQueueServiceUuids =
        getAllQueueServiceUuids(widget.services);
    addIdInUrl(allQueueServiceUuids);
    fetchData(url, context)?.then((value) {
      log('queue: ${getJsonField(value!, r'''$.data[:]''', true)}');
      setState(() {
        queueList =
            getJsonField(value!, r'''$.data[:]''', true)?.toList() ?? [];
      });
      log('value: $value');
      _messageStreamController = StreamController<dynamic>();
      connect(queueList[0]['queue_id']);
      setState(() {
        selectQueue = queueList[0];
        selectedQueueId = queueList[0]['queue_id'];
        serviceSelectQueue = queueList[0]['services'];
      });
    });
    _model = createModel(context, () => FixAppointmentModel());
  }

  @override
  void dispose() {
    _model.dispose();
    // webSocketClient.close();
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
          appBar: AppBar(
            backgroundColor: Color(0xFF37625A),
            automaticallyImplyLeading: false,
            leading: backIcon(context),
            actions: [
              Text(
                widget.formatDate,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).secondaryBackground),
              ),
              const SizedBox(
                width: 20,
              )
            ],
            centerTitle: false,
            elevation: 2,
          ),
          body: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3a615f),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              child: StreamBuilder(
                                  stream: _messageStreamController?.stream,
                                  builder: (context, snapshot) {
                                    final snap = snapshot.data;
                                    dynamic data;
                                    if (snap != null) {
                                      data = getJsonField(
                                          jsonDecode(snap), r'''$.data''');
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.all(
                                                  0),
                                          child: Text(
                                            'Current serving number',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 2, 0, 15),
                                          child: Text(
                                            data != null
                                                ? data['current_token'] ?? '00'
                                                : '00',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 40,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Divider(
                                          height: 0,
                                          thickness: 1,
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(10, 0, 0, 0),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Appointment time',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            fontSize: 14,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 0, 0, 0),
                                                      child: Text(
                                                        data != null
                                                            ? (data['formatted_wait_time'] !=
                                                                    null)
                                                                ? (messageList['estimated_appointment_time']
                                                                            .toString()
                                                                            .length >
                                                                        5)
                                                                    ? messageList[
                                                                            'estimated_appointment_time']
                                                                        .toString()
                                                                        .substring(
                                                                            11)
                                                                    : messageList[
                                                                            'estimated_appointment_time']
                                                                        .toString()
                                                                : '0'
                                                            : '00',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize: 30,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                      ),
                                                    ),
                                                  ]),
                                            )),
                                            SizedBox(
                                              height: 90,
                                              child: VerticalDivider(
                                                thickness: 1,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                              ),
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 10, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    'Your position will be',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 14,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 0, 0, 0),
                                                    child: Text(
                                                      data != null
                                                          ? (data['position'] !=
                                                                  null)
                                                              ? data['position']
                                                                  .toString()
                                                              : '0'
                                                          : '0',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            fontSize: 30,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                      ],
                                    );
                                  })),
                        )
                      ],
                    ),
                  ],
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text("Number of Person(s)",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                    )),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children:
                                                      List.generate(7, (index) {
                                                    int guestCount = index;
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() =>
                                                            selectedGuests =
                                                                guestCount);
                                                        context.pop();
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: selectedGuests ==
                                                                      guestCount
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary
                                                                  : Colors.grey[
                                                                      400]!),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: selectedGuests ==
                                                                  guestCount
                                                              ? Colors.teal
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.white,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            Text('$guestCount'),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.person_add,
                                    color:
                                        FlutterFlowTheme.of(context).primary),
                                label: Text("Add Person",
                                    style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primary)),
                              )),
                              Expanded(
                                  child: TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            child: Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "Book with slot",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Inter',
                                                                ))
                                                          ]),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Wrap(
                                                              spacing: 10,
                                                              runSpacing: 10,
                                                              children:
                                                                  List.generate(
                                                                      times
                                                                          .length,
                                                                      (index) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    setState(() =>
                                                                        selectedLunchTimeIndex =
                                                                            index);
                                                                    context
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 80,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          width: selectedLunchTimeIndex == index
                                                                              ? 2
                                                                              : 1,
                                                                          color: selectedLunchTimeIndex == index
                                                                              ? FlutterFlowTheme.of(context).primary
                                                                              : Colors.grey[400]!),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          times[
                                                                              index],
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ])));
                                      });
                                },
                                icon: Icon(Icons.access_time,
                                    color:
                                        FlutterFlowTheme.of(context).primary),
                                label: Text("Select Time Slot",
                                    style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primary)),
                              )),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(15, 6, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Counter/Employee',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: List.generate(queueList.length, (index) {
                            final queue = queueList[index];
                            if (queueList.isEmpty) {
                              return Center(
                                child: emptyList(),
                              );
                            }

                            return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    15,
                                    10,
                                    15,
                                    (index == queueList.length - 1) ? 10 : 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectQueue = queue;
                                      selectedQueueId = queue['queue_id'];
                                      serviceSelectQueue = queue['services'];
                                    });
                                    connect(queue['queue_id']);
                                  },
                                  child: Container(
                                    height: 74,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        width: (selectedQueueId !=
                                                queue['queue_id'])
                                            ? 1
                                            : 2,
                                        color: (selectedQueueId !=
                                                queue['queue_id'])
                                            ? Colors.grey[300]!
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 15, 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.network(
                                              'https://picsum.photos/seed/273/600',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(10, 0, 0, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    queue['employee_name'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 18,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  Text(
                                                    '${queue['queue_name']}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 12,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            (selectedQueueId !=
                                                    queue['queue_id'])
                                                ? Icons
                                                    .radio_button_off_outlined
                                                : Icons
                                                    .radio_button_checked_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                          }),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade100),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 15, 0, 0),
                              child: Column(children: [
                                Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            15, 0, 15, 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${(double.parse(totalPrice(serviceSelectQueue, 'avg_service_time')) / 60).toString().replaceAll('.0', '')} Mins/Person',
                                          style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                            '${serviceSelectQueue.length} Service',
                                            style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    )),
                                Divider(
                                  indent: 0,
                                  endIndent: 0,
                                  height: 1,
                                  color: Colors.green.shade50,
                                ),
                                Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                        serviceSelectQueue.length, (index) {
                                      final queueData =
                                          serviceSelectQueue[index];
                                      return Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 8, 0, 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        queueData[
                                                            'business_service_name'],
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                      ),
                                                      if (queueData[
                                                              'fee_type'] !=
                                                          null)
                                                        Text(
                                                          '${queueData['fee_type']}',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                fontSize: 10,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                        )
                                                    ])),
                                            if (queueData['fee_type'] ==
                                                'Hourly Fee')
                                              Material(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.white,
                                                  elevation: 2,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(
                                                            color: Colors
                                                                .black38)),
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            GestureDetector(
                                                                onTap: () {},
                                                                child: const SizedBox(
                                                                    width: 24,
                                                                    child: Center(
                                                                        child: Text(
                                                                      '-',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20),
                                                                    )))),
                                                            const Text('1 h',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                            GestureDetector(
                                                                onTap: () {},
                                                                child: const SizedBox(
                                                                    width: 24,
                                                                    child: Center(
                                                                        child: Text(
                                                                      '+',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    )))),
                                                          ],
                                                        )),
                                                  )),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                                child: Text(
                                              (queueData['service_fee'] != null)
                                                  ? '₹ ${queueData['service_fee']}/-'
                                                  : '-/- ',
                                              textAlign: TextAlign.end,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  if (serviceSelectQueue
                                                          .length >
                                                      1) {
                                                    setState(() {
                                                      serviceSelectQueue
                                                          .removeAt(index);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      serviceSelectQueue
                                                          .removeAt(index);
                                                    });
                                                    context.pop();
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons
                                                      .remove_circle_outline_rounded,
                                                  color: Colors.red[200],
                                                  size: 22,
                                                ))
                                          ],
                                        ),
                                      );
                                    })),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: GestureDetector(
                                            onTap: () {
                                              context.pop();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.black26)),
                                              child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    '+ Add more service',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )),
                                            )),
                                      )
                                    ]),
                              ]),
                            ),
                          )),
                      if (selectQueue != null)
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 15, bottom: 0),
                            child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.green.withOpacity(0.08),
                                      Colors.green.withOpacity(
                                          0.08), // Or any color for the bottom glow
                                      Colors.green.withOpacity(
                                          0.12), // Or any color for the bottom glow
                                    ],
                                  ),
                                  // border: Border.all(color: Colors.black26),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              'Bill Details',
                                              style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          indent: 0,
                                          endIndent: 0,
                                          height: 1,
                                          color: Colors.grey[100],
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        // detail('Business name',
                                        //     widget.businessName),
                                        // detail('Counter',
                                        //     selectQueue['queue_name'] ?? ''),
                                        // detail('Staff name',
                                        //     selectQueue['employee_name'] ?? ''),
                                        detail('Per Person Fees',
                                            '₹${totalPrice(serviceSelectQueue, 'service_fee')}'),
                                        detail('Total Person',
                                            '${(selectedGuests + 1)}'),

                                        // detail(
                                        //     'Services',
                                        //     getJsonField(serviceSelectQueue,
                                        //             r'''$..business_service_name''')
                                        //         .toString()
                                        //         .replaceAll('[', '')
                                        //         .replaceAll(']', '')),
                                        // detail('Date', widget.date),
                                        // if (messageList != null)
                                        //   detail(
                                        //       'Time',
                                        //       (messageList['estimated_appointment_time']
                                        //                   .toString()
                                        //                   .length >
                                        //               5)
                                        //           ? messageList[
                                        //                   'estimated_appointment_time']
                                        //               .toString()
                                        //               .substring(11)
                                        //           : messageList[
                                        //                   'estimated_appointment_time']
                                        //               .toString()),
                                        // detail('Total time',
                                        //     '${((selectedGuests != 0) ? double.parse(totalPrice(serviceSelectQueue, 'avg_service_time')) * (selectedGuests + 1) / 60 : double.parse(totalPrice(serviceSelectQueue, 'avg_service_time')) / 60).toString().replaceAll('.0', '')} Mins'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          indent: 0,
                                          endIndent: 0,
                                          height: 1,
                                          color: Colors.green.shade100,
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total Fee',
                                                  style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  (totalPrice(serviceSelectQueue,
                                                              'service_fee') !=
                                                          '')
                                                      ? '₹ ${(selectedGuests != 0) ? (double.parse(totalPrice(serviceSelectQueue, 'service_fee'))) * (selectedGuests + 1) : (totalPrice(serviceSelectQueue, 'service_fee'))}/-'
                                                      : '-/-',
                                                  style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            )),
                                      ],
                                    )))),
                      Padding(
                          padding: EdgeInsets.fromLTRB(15, 12, 15, 20),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14)),
                              child: const  Padding(
                                padding: EdgeInsets.all(14),
                                child: Row(children: [
                                Expanded(child:  Text(
                                    'Note: Appointment time is approximate and may vary slightly',
                                    style: TextStyle(fontSize: 14),
                                  )
                                )])),
                              )),
                    ],
                  ),
                )),
                const SizedBox(
                  height: 15,
                ),
                Material(
                    borderRadius: BorderRadius.circular(30),
                    elevation: 2,
                    child: CircleSlideToActionButton(
                      width: (isLoading)
                          ? 55
                          : MediaQuery.of(context).size.width - 40,
                      parentBoxRadiusValue: 27,
                      circleSlidingButtonSize: 55,
                      leftEdgeSpacing: 0,
                      rightEdgeSpacing: 0,
                      initialSlidingActionLabel: (totalPrice(
                                  serviceSelectQueue, 'service_fee') !=
                              '')
                          ? 'Slide to Fix Appointment | ₹${(selectedGuests != 0) ? (double.parse(totalPrice(serviceSelectQueue, 'service_fee'))) * (selectedGuests + 1) : (totalPrice(serviceSelectQueue, 'service_fee'))}'
                          : 'Slide to Fix Appointment',
                      initialSlidingActionLabelTextStyle:
                          const TextStyle(fontSize: 16, color: Colors.white),
                      finalSlidingActionLabel: '',
                      circleSlidingButtonIcon: (!isLoading)
                          ? Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28,
                            )
                          : Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: FlutterFlowTheme.of(context).primary,
                              )),
                      parentBoxBackgroundColor:
                          FlutterFlowTheme.of(context).primary,
                      parentBoxDisableBackgroundColor: Colors.grey,
                      circleSlidingButtonBackgroundColor: Colors.white,
                      isEnable: true,
                      onSlideActionCompleted: () async {
                        setState(() {
                          isLoading = true;
                        });
                        final services = [];
                        for (final x in serviceSelectQueue) {
                          for (final s in widget.services) {
                            log('service s: $s');
                            log('service x: $x');
                            if (x['service_id'] == s['service_id']) {
                              services.add(s['queue_service_uuids']
                                  .toString()
                                  .replaceAll('[', '')
                                  .replaceAll(']', ''));
                            }
                          }
                        }

                        final apiCall = await sendData({
                          "user_id": widget.uuid,
                          "priority": false,
                          "queue_id": selectedQueueId!,
                          "queue_date": widget.date,
                          "token_number": "string",
                          "turn_time": 0,
                          "queue_services": services,
                        }, 'queue_user')
                            .then((value) {
                          log('response: $value');
                          if (value != null) {
                            setState(() {
                              isLoading = false;
                            });
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfirmUiWidget(
                                          response: value,
                                        )));
                          }
                        });

                        setState(() {
                          isLoading = false;
                        });
                      },
                      onSlideActionCanceled: () {
                        print("Sliding action cancelled");
                        setState(() {
                          isLoading = false;
                        });
                      },
                    )),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          )),
    );
  }

  Widget detail(label, value) {
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ));
  }

  bool? showPremiumAppointmentDialog(BuildContext context,
      {required String userName,
      required String businessName,
      required String date,
      required String time,
      required String staffName,
      required String serviceName,
      required String userId,
      required String queueId,
      required String queueDate,
      required List<dynamic> queueServices}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 60, left: 20, right: 20, bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Appointment Confirmation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Hi $userName 👋\nYou're booking with",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        businessName,
                        style: TextStyle(
                          fontSize: 16,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details
                      _infoTile(
                          Icons.calendar_today_rounded, 'Date', widget.date),
                      _infoTile(Icons.access_time_rounded, 'Time', time),
                      _infoTile(Icons.cut_rounded, 'Service', serviceName),
                      _infoTile(Icons.person_rounded, 'Staff', staffName),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Note: Time is approximate and may vary slightly.",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 45,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      FlutterFlowTheme.of(context).primary,
                                  side: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FFButtonWidget(
                                text: 'Confirm',
                                onPressed: () async {},
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 45,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, 0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  elevation: 2,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                )))
                      ],
                    )),
              ]),

              // Avatar / Icon
              Positioned(
                top: -40,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  child: Text(
                    businessName.isNotEmpty ? businessName[0] : 'B',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {});
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String totalPrice(List<dynamic> dataList, parameter) {
    double total = 0;

    for (final d in dataList) {
      if (d[parameter] != null) {
        total += (d[parameter]);
        log('price: $total');
      } else {
        return '';
      }
    }

    // Convert to int if no decimal part, else keep it as double.
    if (total == total.toInt()) {
      return total.toInt().toString();
    } else {
      return total.toString();
    }
  }
}
