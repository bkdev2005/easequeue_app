import 'dart:async';
import 'dart:developer';
import 'package:eqlite/Component/Congratulate/congratulation_widget.dart';
import 'package:eqlite/function.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Component/AppointmentType/appointment_type_widget.dart';
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
      required this.uuid});
  final List<dynamic> services;
  final String date;
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
  WebSocketService? _webSocketService;
  String? _token; // Token to be passed
  dynamic selectQueue;
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
          'ws://65.2.83.191/api/v1/ws/$url/${widget.date}',
          headers: {'Authorization': 'Bearer $token'});
      print("Connected to WebSocket at $url");

      // Listen to incoming messages
      _webSocket?.listen(
        (message) {
          _messageStreamController?.add(message);
          messageList = getJsonField(jsonDecode(message), r'''$.data''');
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
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: backIcon(context),
            actions: [],
            centerTitle: false,
            elevation: 0,
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
                          elevation: 2,
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
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
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
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(10, 0, 0, 0),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Waiting time',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 0),
                                                      child: Text(
                                                        data != null
                                                            ? (data['formatted_wait_time'] !=
                                                                    null)
                                                                ? data['formatted_wait_time']
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
                                            ),
                                            SizedBox(
                                              height: 90,
                                              child: VerticalDivider(
                                                thickness: 1,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
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
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
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
                                            ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(15, 20, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Counter/Employee',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children:
                                      List.generate(queueList.length, (index) {
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
                                            (index == queueList.length - 1)
                                                ? 10
                                                : 0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectQueue = queue;
                                              selectedQueueId =
                                                  queue['queue_id'];
                                              serviceSelectQueue =
                                                  queue['services'];
                                            });
                                            connect(queue['queue_id']);
                                          },
                                          child: Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 8, 15, 8),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
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
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10, 0, 0, 0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            queue[
                                                                'employee_name'],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize:
                                                                      queue['is_counter']
                                                                          ? 16
                                                                          : 18,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          if (queue[
                                                              'is_counter'])
                                                            Text(
                                                              'Counter: ${queue['queue_name']}',
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
                                                                    fontSize:
                                                                        16,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                  }),
                                ),
                              ))),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Column(children: [
                            Column(
                                mainAxisSize: MainAxisSize.max,
                                children: List.generate(
                                    serviceSelectQueue.length, (index) {
                                  final queueData = serviceSelectQueue[index];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 10, 20, 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                queueData[
                                                    'business_service_name'],
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 16,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                              if (queueData['fee_type'] != null)
                                                Text(
                                                  ':- '
                                                  '${queueData['fee_type']}',
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
                                                )
                                            ]),
                                        Text(
                                          (queueData['service_fee'] != null)
                                              ? '₹ ${queueData['service_fee']}/-'
                                              : '-/- ',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 18,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                            Divider(
                              thickness: 1,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(20, 5, 25, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Price:',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    (totalPrice(serviceSelectQueue) != '')
                                        ? '₹ ${totalPrice(serviceSelectQueue)}/-'
                                        : '-/-',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      final services = [];
                      for (final x in serviceSelectQueue) {
                        for (final s in widget.services) {
                          log('service s: $s');
                          log('service x: $x');
                          if (x['service_id'] == s['service_id']) {
                            setState(() {
                              services.add(s['queue_service_uuids']
                                  .toString()
                                  .replaceAll('[', '')
                                  .replaceAll(']', ''));
                            });
                          }
                        }
                      }
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: AppointmentTypeWidget(
                                  userId: widget.uuid,
                                  queueId: selectedQueueId!,
                                  queueDate: widget.date,
                                  queueServices: services,
                                ));
                          });


                    },
                    text: 'Fix Appointment',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 70,
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter Tight',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  String totalPrice(List<dynamic> dataList) {
    double total = 0;

    for (final d in dataList) {
      if (d['service_fee'] != null) {
        setState(() {
          total += (d['service_fee']);
        });
        log('price: $total');
      } else {
        return '';
      }
    }
    return total.toString();
  }
}
