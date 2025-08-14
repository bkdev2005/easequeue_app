import 'dart:async';
import 'dart:developer';
import 'package:eqlite/Component/Congratulate/congratulation_widget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sliding_action_button/sliding_action_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Component/AddAnotherPerson/AddOtherWidget.dart';
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
  String? selectedTimeSlot;
  WebSocketService? _webSocketService;
  String appointeeUUID = '';
  String appointeeName = '';
  String? appointmentTime;
  String? _token; // Token to be passed
  int selectedGuests = 0;
  bool isLoading = false;
  dynamic selectQueue;
  List<dynamic> times = [];
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

  Future<void> availableSlots() async {
    final slotsData = await fetchData(
        'available_slots?employee_id=${selectQueue['employee_id'][0]}&queue_id=$selectedQueueId&search_date=${widget.date}',
        context);
    if (slotsData != null) {
      if (slotsData['data'].toString() != '[]') {
        final data = slotsData['data']['slots_formatted'].toList() ?? [];
        log('Data: $data');
        setState(() {
          times = data;
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
            appointmentTime =
                (messageList['estimated_appointment_time'].toString().length >
                        8)
                    ? messageList['estimated_appointment_time']
                        .toString()
                        .substring(15)
                    : messageList['estimated_appointment_time'].toString();
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
    appointeeUUID = widget.uuid;
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
      availableSlots();
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.businessName,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        fontSize: 18,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  widget.formatDate,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: FlutterFlowTheme.of(context).secondaryBackground),
                ),
              ],
            ),
            actions: [
              if (selectedTimeSlot != null)
                IconButton(
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        selectedTimeSlot = null;
                        selectedLunchTimeIndex = -1;
                      });
                      Fluttertoast.showToast(msg: 'Time slot reset');
                    },
                    icon: const Icon(Icons.refresh_rounded)),
              toggleButton()
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
                                              const EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Current serving number',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 14,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 2, 0, 15),
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
                                                            .fromSTEB(
                                                            10, 0, 0, 0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (times.isNotEmpty) {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return slotTime();
                                                              });
                                                        }
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Estimated time',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          fontSize:
                                                                              14,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  if (times
                                                                      .isNotEmpty)
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                  if (times
                                                                      .isNotEmpty)
                                                                    const Icon(
                                                                      Icons
                                                                          .edit_calendar_rounded,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 16,
                                                                    )
                                                                ]),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                (selectedTimeSlot !=
                                                                        null)
                                                                    ? selectedTimeSlot ??
                                                                        ''
                                                                    : data !=
                                                                            null
                                                                        ? (data['formatted_wait_time'] !=
                                                                                null)
                                                                            ? (messageList['estimated_appointment_time'].toString().length > 8)
                                                                                ? messageList['estimated_appointment_time'].toString().substring(15)
                                                                                : messageList['estimated_appointment_time'].toString()
                                                                            : '0'
                                                                        : '00',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      fontSize:
                                                                          30,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                              ),
                                                            ),
                                                          ]),
                                                    ))),
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
                                                      (selectedTimeSlot != null)
                                                          ? '-/-'
                                                          : data != null
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
                      /*Padding(
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
                                                const Text(
                                                    "Number of Person(s)",
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
                          )),*/

                      if (appointeeUUID != widget.uuid)
                        Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(children: [
                                    Icon(
                                      Icons.task_alt_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                        child: Text(
                                      'Appointment will be add as guest user $appointeeName',
                                      style: const TextStyle(fontSize: 14),
                                    ))
                                  ])),
                            )),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 16, 0, 0),
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
                                            /*if (queueData['fee_type'] ==
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
                                                  )),*/
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
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.12)),
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
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      children: [
                                        // const Row(
                                        //   children: [
                                        //     Text(
                                        //       'Bill Details',
                                        //       style: TextStyle(
                                        //           fontFamily: 'Inter',
                                        //           fontSize: 16,
                                        //           fontWeight: FontWeight.w500),
                                        //     ),
                                        //   ],
                                        // ),
                                        // const SizedBox(
                                        //   height: 10,
                                        // ),
                                        // Divider(
                                        //   indent: 0,
                                        //   endIndent: 0,
                                        //   height: 1,
                                        //   color: Colors.grey[100],
                                        // ),
                                        // const SizedBox(
                                        //   height: 2,
                                        // ),
                                        // detail('Business name',
                                        //     widget.businessName),
                                        // detail('Counter',
                                        //     selectQueue['queue_name'] ?? ''),
                                        // detail('Staff name',
                                        //     selectQueue['employee_name'] ?? ''),
                                        // detail('Per Person Fees',
                                        //     '₹${totalPrice(serviceSelectQueue, 'service_fee')}'),
                                        // detail('Total Person',
                                        //     '${(selectedGuests + 1)}'),

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
                                        // const SizedBox(
                                        //   height: 10,
                                        // ),
                                        // Divider(
                                        //   indent: 0,
                                        //   endIndent: 0,
                                        //   height: 1,
                                        //   color: Colors.green.shade100,
                                        // ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total Service Fees',
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
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.12)),
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14)),
                            child: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Row(children: [
                                  Expanded(
                                      child: Text(
                                    'Note: Appointment time is approximate and may vary slightly',
                                    style: TextStyle(fontSize: 14),
                                  ))
                                ])),
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
                        if (isLoading == false) {
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
                            "user_id": appointeeUUID,
                            "priority": false,
                            "queue_id": selectedQueueId!,
                            "queue_date": widget.date,
                            "token_number": "string",
                            "turn_time": 0,
                            "queue_services": services,
                            "estimated_enqueue_time": convertToIsoUtc(
                                widget.date,
                                (selectedTimeSlot != null)
                                    ? selectedTimeSlot!
                                    : appointmentTime!),
                            "notes": "string",
                            "cancellation_reason": "string",
                            "reschedule_count": 0,
                            "joined_queue":
                                (selectedTimeSlot != null) ? false : true,
                            "is_scheduled":
                                (selectedTimeSlot != null) ? true : false
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
                        }
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

  Widget slotTime() {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Book with slot",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close_rounded),
                            ))
                      ])),
              const SizedBox(
                height: 7,
              ),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(times.length, (index) {
                        final timeData = times[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLunchTimeIndex = index;
                              selectedTimeSlot = timeData['start'];
                            });
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width:
                                      selectedLunchTimeIndex == index ? 2 : 1,
                                  color: selectedLunchTimeIndex == index
                                      ? FlutterFlowTheme.of(context).primary
                                      : Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '${timeData['start']}',
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        );
                      }),
                    ),
                  ))
            ],
          ),
        ));
  }

  bool _isIncognito = false;
  Widget toggleButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Switch(
        value: _isIncognito,
        activeColor: Colors.teal,
        inactiveTrackColor: Colors.white,
        trackOutlineWidth: WidgetStateProperty.resolveWith((Set states) {
          if (states.contains(WidgetState.disabled)) {
            return 0.1;
          }
          return null; // Use the default width.
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((Set states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.teal.withOpacity(.48);
          }
          return Colors.transparent; // Use the default color.
        }),
        inactiveThumbImage: const AssetImage(
          'assets/images/user.png',
        ),
        activeThumbImage: const AssetImage(
          'assets/images/user.png',
        ),
        activeTrackColor: Colors.black54,
        onChanged: (value) async {
          if (value == true) {
            debugPrint('Guest Mode: $_isIncognito');
            await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: false,
                builder: (context) {
                  return Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: const AddAnotherCustomerWidget());
                }).then((response) {
              if (response != null) {
                final uuid = response['uuid'];
                final name = response['full_name'];
                setState(() {
                  _isIncognito = true;
                  appointeeUUID = uuid;
                  appointeeName = name;
                });
              }
            });
          } else {
            setState(() {
              _isIncognito = false;
              appointeeUUID = widget.uuid;
              appointeeName = '';
            });
          }
        },
      ),
    );
  }
}
