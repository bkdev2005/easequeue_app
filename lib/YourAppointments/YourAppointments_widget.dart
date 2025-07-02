import 'dart:developer';
import 'package:eqlite/flutter_flow/nav/nav.dart';

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

class YourAppointmentsWidget extends StatefulWidget {
  const YourAppointmentsWidget({super.key});

  @override
  State<YourAppointmentsWidget> createState() => _YourAppointmentsWidgetState();
}

class _YourAppointmentsWidgetState extends State<YourAppointmentsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> appointments = [];
  bool isMainLoading = false;

  @override
  void initState() {
    setState(() {
      isMainLoading = true;
    });
    fetchData('customer_appointments/${FFAppState().userId}', context)
        ?.then((value) {
      if (value != null) {
        if (value['data'] != null) {
          log('response: ${value['data']}');
          final data =
              getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
          setState(() {
            appointments = data;
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
    });
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
        appBar: appBarWidget(context, 'Appointments'),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  final appointmentList = appointments;

                  if (isMainLoading) {
                    return loading(context);
                  }
                  if (!isMainLoading && appointments.isEmpty) {
                    return emptyList();
                  }
                  return ListView.builder(
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
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                          child: Material(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointmentListItem[
                                                  'business_name'] ??
                                              'N/A',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        appointmentListItem[
                                        'user_status'] ??
                                            'N/A',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Inter',
                                          color: (appointmentListItem[
                                          'user_status'] == 'Cancelled')? Colors.red : (appointmentListItem[
                                          'user_status'] == 'Registered')? Colors.orangeAccent : Colors.green,
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 5, 0, 0),
                                    child: Text(
                                      '${(getJsonField(appointmentListItem, r'''$.business_address[0].unit_number''')).toString()}, ' +
                                          '${(getJsonField(appointmentListItem, r'''$.business_address[0].building''')).toString()}, ' +
                                          '${(getJsonField(appointmentListItem, r'''$.business_address[0].street_1''')).toString()}, ' +
                                          '${(getJsonField(appointmentListItem, r'''$.business_address[0].country''')).toString()}' +
                                          '-${(getJsonField(appointmentListItem, r'''$.business_address[0].postal_code''')).toString()}',
                                      // newFormatAddress(getJsonField(appointmentListItem, r'''$.business_address[0]''', true)),
                                      // 'N/A',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 5, 0, 0),
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
                                  const Divider(
                                    thickness: 1,
                                  ),

                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if(appointmentListItem['enqueue_datetime'] != null && appointmentListItem['enqueue_datetime'] != '')
                                          Padding(
                                            padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0, 5, 0, 0),
                                            child: Text(
                                              'Appointment Time: ${appointmentListItem['enqueue_datetime']}',
                                              textAlign: TextAlign.end,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),

                                        if(appointmentListItem['duration'] != null && appointmentListItem['duration'] != '')
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                0, 5, 0, 0),
                                            child: Text(
                                              'Duration: ${appointmentListItem['duration']}',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),
                                      ]),

                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0, 5, 0, 0),
                                          child: Text(
                                            'Service: ${serviceName(appointmentListItem['services'])}',
                                            style: FlutterFlowTheme.of(context)
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
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 5, 0, 0),
                                          child: Text(
                                            changeFormat(appointmentListItem['created_at']),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ])
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
              )
            ],
          ),
        ),
      ),
    );
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
