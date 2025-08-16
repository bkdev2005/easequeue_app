import 'dart:developer';
import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:screenshot/screenshot.dart';

import '../Component/Confirmation/permissionConfirmation.dart';
import '../apiFunction.dart';
import '../app_state.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DetailAppointmentsWidget extends StatefulWidget {
  const DetailAppointmentsWidget({super.key});

  @override
  State<DetailAppointmentsWidget> createState() =>
      _DetailAppointmentsWidgetState();
}

class _DetailAppointmentsWidgetState extends State<DetailAppointmentsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> appointments = [];
  List<dynamic> status = [
    {'label': '1', 'value': 'Registered'},
    {'label': '2', 'value': 'Completed'},
    {'label': '3', 'value': 'Cancelled'}
  ];
  bool isMainLoading = false;
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String statusLabel = '1';
  int currentPage = 1;
  bool isFetchingMore = false;
  bool isOutLookLoad = false;
  bool hasMoreData = true;
  final int pageSize = 10;

  void loadMoreAppointments({String? search}) {
    if (isFetchingMore || !hasMoreData) return;

    setState(() {
      isFetchingMore = true;
    });

    String url =
        'customer_appointments/${FFAppState().userId}?page=$currentPage&page_size=$pageSize';

    if (statusLabel.isNotEmpty) {
      url += '&status=$statusLabel';
    }

    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }

    fetchData(url, context)?.then((value) {
      if (value != null && value['data'] != null) {
        final newData =
            getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
        log('data: ${newData}');
        setState(() {
          appointments.addAll(newData);
          currentPage++;
          isFetchingMore = false;
          isMainLoading = false;

          if (newData.length < pageSize) {
            hasMoreData = false;
          }
        });
      } else {
        setState(() {
          isFetchingMore = false;
          isMainLoading = false;
          hasMoreData = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isFetchingMore &&
        hasMoreData) {
      loadMoreAppointments();
    }
  }

  @override
  void initState() {
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    _scrollController.addListener(_onScroll);
    setState(() {
      isMainLoading = true;
    });
    loadMoreAppointments();
    super.initState();
  }

  @override
  void dispose() {
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
        appBar: appBarWidget(context, 'Upcoming Appointments'),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Material(
                elevation: 0,
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 4, bottom: 16),
                    child: TextFormField(
                        cursorColor: FlutterFlowTheme.of(context).primary,
                        controller: textController,
                        focusNode: textFieldFocusNode,
                        onChanged: (value) {
                          setState(() {
                            appointments.clear();
                            currentPage = 1;
                            hasMoreData = true;
                          });

                          if (value.length > 3) {
                            loadMoreAppointments(search: value);
                          } else {
                            loadMoreAppointments();
                          }
                        },
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          hintText: 'Search appointment',
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.all(0),
                          filled: true,
                          suffixIcon: textController!.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    textController?.clear();
                                    setState(() {
                                      appointments.clear();
                                      currentPage = 1;
                                      hasMoreData = true;
                                      textFieldFocusNode?.unfocus();
                                    });
                                    loadMoreAppointments();
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    size: 22,
                                  ),
                                )
                              : null,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                        )))),
            Expanded(
                child: Material(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      child: Builder(builder: (context) {
                        final appointmentList = appointments;

                        if (isMainLoading) {
                          return loading(context);
                        }
                        if (!isMainLoading && appointments.isEmpty) {
                          return emptyList();
                        }
                        return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              0,
                              0,
                              20,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: appointmentList.length,
                            itemBuilder: (context, addressListIndex) {
                              final appointmentListItem =
                                  appointmentList[addressListIndex];
                              final businessAddress = '${(getJsonField(appointmentListItem, r'''$.business_address[0].unit_number''')).toString()}, ' +
                                  '${(getJsonField(appointmentListItem, r'''$.business_address[0].building''')).toString()}, ' +
                                  '${(getJsonField(appointmentListItem, r'''$.business_address[0].street_1''')).toString()}, ' +
                                  '${(getJsonField(appointmentListItem, r'''$.business_address[0].country''')).toString()}' +
                                  '-${(getJsonField(appointmentListItem, r'''$.business_address[0].postal_code''')).toString()}';
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    15, 15, 15, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.12)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.green.withOpacity(0.04),
                                        Colors.green.withOpacity(
                                            0.06), // Or any color for the bottom glow
                                        Colors.green.withOpacity(
                                            0.09), // Or any color for the bottom glow
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row( children: [
                                                Text(
                                                appointmentListItem[
                                                        'business_name'] ??
                                                    'N/A',
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
                                                Text(
                                                  (appointmentListItem[
                                                  'queue_name'] != null) ? ' (${appointmentListItem[
                                                  'queue_name']})' :
                                                      '',
                                                  style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  ),
                                                ),
                                            ])
                                            ),
                                            Text(
                                              appointmentListItem[
                                                      'user_status'] ??
                                                  'N/A',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: (appointmentListItem[
                                                                    'user_status'] ==
                                                                'Cancelled')
                                                            ? Colors.red
                                                            : (appointmentListItem[
                                                                        'user_status'] ==
                                                                    'Registered')
                                                                ? Colors
                                                                    .orangeAccent
                                                                : Colors.green,
                                                        fontSize: 12,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 5, 0, 0),
                                          child: Text(
                                            'Token No.: ${appointmentListItem['your_token']}',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 5, 0, 0),
                                          child: Row( children: [
                                            Expanded(child: Text(
                                            businessAddress,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          )),
                                            addressIcon(businessAddress, context)
                                        ])),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 5, 0, 6),
                                          child: Text(
                                            '₹ ${appointmentListItem['total_price']}',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),

                                        Divider(
                                          indent: 0,
                                          endIndent: 0,
                                          height: 1,
                                          color: Colors.green.shade100,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (appointmentListItem[
                                                          'estimated_enqueue_time'] !=
                                                      null &&
                                                  appointmentListItem[
                                                          'estimated_enqueue_time'] !=
                                                      '')
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(0, 5, 0, 0),
                                                  child: Text(
                                                    'Appointment Time:',
                                                    textAlign: TextAlign.end,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          fontSize: 12,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              Padding(
                                                padding:
                                                const EdgeInsetsDirectional
                                                    .fromSTEB(0, 5, 0, 0),
                                                child: Text(
                                                  '${appointmentListItem['estimated_enqueue_time']}',
                                                  textAlign: TextAlign.end,
                                                  style: FlutterFlowTheme.of(
                                                      context)
                                                      .bodyMedium
                                                      .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 5, 0, 0),
                                                child: Text(
                                                  'Service: ${serviceName(appointmentListItem['services'])}',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 5, 0, 0),
                                                child: Text(
                                                  changeFormat(
                                                      appointmentListItem[
                                                          'created_at']),
                                                  textAlign: TextAlign.end,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ]),

                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(spacing: 12, children: [
                                              Expanded(
                                                  child: FFButtonWidget(
                                                      text: 'Cancel',
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return const Center(
                                                                child:
                                                                    ConfirmationWidget(
                                                                  title:
                                                                      'Cancel Appointment',
                                                                  subtitle:
                                                                      'Are your sure want to cancel appointment?',
                                                                ),
                                                              );
                                                            }).then((value) {
                                                          if (value) {
                                                            fetchData(
                                                                    'cancel_appointment/${appointmentListItem['queue_user_id']}',
                                                                    context)
                                                                ?.then((value) {
                                                              log('response: ${value}');
                                                              if (value[
                                                                  'success']) {
                                                                setState(() {
                                                                  isOutLookLoad =
                                                                      true;
                                                                });
                                                                context
                                                                    .pop(true);
                                                              }
                                                            });
                                                          }
                                                        });
                                                      },
                                                      options: const FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          color: Colors.white,
                                                          elevation: 0,
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black)))),
                                              Expanded(
                                                  child: FFButtonWidget(
                                                      text: 'Reschedule',
                                                      onPressed: () async{
                                                        await putData({
                                                          "queue_id": appointmentListItem['queue_id'],
                                                          "queue_date": onlyDate((appointmentListItem['estimated_enqueue_time'])),
                                                          "token_number": appointmentListItem['your_token'].toString(),
                                                          "estimated_enqueue_time": dateFormat(appointmentListItem['estimated_enqueue_time']),
                                                          "estimated_dequeue_time": dateFormat(appointmentListItem['estimated_dequeue_time']),
                                                          "notes": appointmentListItem['notes'],
                                                          "reschedule_count": appointmentListItem['reschedule_count'],
                                                          "joined_queue": appointmentListItem['joined_queue'],
                                                          "is_scheduled": appointmentListItem['is_scheduled'],
                                                          "queue_services": appointmentListItem['services']
                                                        }, "reschedule_queue_entry").then((response){
                                                              log("message: $response");
                                                        });
                                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> AddServicePageWidget(
                                                         businessId: (getJsonField(appointmentListItem, r'''$.business_id''')).toString()
                                                        )));
                                                      },
                                                      options: const FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          color: Colors.white,
                                                          elevation: 0,
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .black))))
                                            ])),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                          Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 10, 0, 0),
                                          child: Text(
                                            (appointmentListItem['is_scheduled'] == true)? '"Time-slot-based appointment booking"' : '"Queue-based appointment booking"',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontSize: 12,
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])),
                                ),
                              );
                            });
                      }),
                    )))
          ],
        ),
      ),
    );
  }

  String dateFormat(String inputDate) {
    // Step 1: Local time (16 August 2025, 03:41 PM)

    // Step 2: Parse it using DateFormat
    DateFormat inputFormat = DateFormat("dd MMMM yyyy hh:mm a");
    DateTime localDateTime = inputFormat.parse(inputDate);

    // Step 3: Convert to UTC
    DateTime utcDateTime = localDateTime.toUtc();

    // Step 4: Format to ISO8601
    String isoUtc = utcDateTime.toIso8601String();

    print("Local: $localDateTime");
    print("UTC ISO: $isoUtc");
    return isoUtc;
  }

  String onlyDate(String inputDate) {
    // Input string

    // Parse string to DateTime
    DateFormat inputFormat = DateFormat("dd MMMM yyyy hh:mm a");
    DateTime dateTime = inputFormat.parse(inputDate);

    // Format only date as yyyy-MM-dd
    String onlyDate = DateFormat("yyyy-MM-dd").format(dateTime);

    print(onlyDate); // 👉 2025-08-16
    return onlyDate;
  }


}

// QUEUE_USER_REGISTERED = 1
// QUEUE_USER_IN_PROGRESS = 2
// QUEUE_USER_COMPLETED = 3
// QUEUE_USER_FAILED = 4
// QUEUE_USER_CANCELLED = 5
// QUEUE_USER_PRIORITY_REQUESTED = 6

// BUSINESS_REGISTERED = 1
// BUSINESS_ACTIVE = 2
// BUSINESS_SUSPENDED = 3
// BUSINESS_INACTIVE = 4
// BUSINESS_TERMINATED = 5
