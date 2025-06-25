import 'dart:developer';

import 'package:eqlite/Component/AddAnotherPerson/AddOtherWidget.dart';
import 'package:eqlite/ServicePage/service_model.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../FixAppointment/fix_Appointment_Widget.dart';
import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddServicePageWidget extends StatefulWidget {
  const AddServicePageWidget(
      {super.key, this.businessDetail, this.date, this.businessId});
  final dynamic businessDetail;
  final String? businessId;
  final dynamic date;
  @override
  State<AddServicePageWidget> createState() => _AddServicePageWidgetState();
}

class _AddServicePageWidgetState extends State<AddServicePageWidget> {
  late AddServicePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic businessDetail;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddServicePageModel());

    log('selectData: ${widget.businessDetail}');

    if (widget.businessDetail == null) {
      setState(() {
        isLoading = true;
      });
      fetchData('business/${widget.businessId}', context)?.then((value) {
        if (value != null) {
          log('business: ${value}');
          setState(() {
            businessDetail = value['data'];
          });
          fetchData(
                  'business/${businessDetail['uuid']}/services?page=1&page_size=20',
                  context)
              ?.then((value) {
            setState(() {
              serviceList =
                  getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
            });
            setState(() {
              isLoading = false;
            });
            log('Service: $value');
          });
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Something went wrong');
        }
        log('Service: $value');
      });
    } else {
      setState(() {
        businessDetail = widget.businessDetail;
      });
    }
    if (widget.businessDetail != null) {
      setState(() {
        isLoading = true;
      });
      fetchData(
              'business/${businessDetail['uuid']}/services?page=1&page_size=20',
              context)
          ?.then((value) {
        setState(() {
          serviceList =
              getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
        });
        if(selectedServiceIndex.isEmpty){
        for(final service in serviceList){
          if(!service['is_disabled']){
            setState(() {
              selectedServiceIndex.add(service['service_id']);
              selectedServiceData.add(service);
            });
            break;
          }
        }
        }
        setState(() {
          isLoading = false;
        });
        log('Service: $value');
      });
    }
  }

  List<dynamic> serviceList = [];
  List<dynamic> selectedServiceIndex = [];
  List<dynamic> selectedServiceData = [];
  bool isLoading = false;
  String appointeeUUID = '';

  @override
  void dispose() {
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: backIcon(context),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                FFButtonWidget(
                  onPressed: () async {
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        builder: (context) {
                          return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: AddAnotherCustomerWidget());
                        }).then((value) {
                      if (value != null) {
                        setState(() {
                          appointeeUUID = value;
                        });
                      }
                    });
                  },
                  text: 'Book Another',
                  options: FFButtonOptions(
                    height: 38,
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(
                  width: 15,
                )
                /*FlutterFlowIconButton(
                  borderRadius: 8,
                  buttonSize: 40,
                  fillColor: FlutterFlowTheme.of(context).primary,
                  icon: FaIcon(
                    FontAwesomeIcons.ellipsisV,
                    color: FlutterFlowTheme.of(context).info,
                    size: 24,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),*/
              ],
            ),
          ],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
            top: true,
            child: Stack(children: [
              if (isLoading)
                Center(
                  child: loading(context),
                ),
              if (!isLoading)
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 20, 20, 0),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(0),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12, 12, 12, 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: (widget.businessDetail[
                                                'profile_picture'] !=
                                                    null)
                                                    ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(30),
                                                    child: Image.network(
                                                  'http://43.204.107.110/shared/${widget.businessDetail['profile_picture']}',
                                                  fit: BoxFit.cover,
                                                ))
                                                    : Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0, 0),
                                                  child: Text(
                                                    getInitials(businessDetail[
                                                            'name'] ??
                                                        ''),
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .tertiary,
                                                          fontSize: 26,
                                                          letterSpacing: 1,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(10, 0, 0, 0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      businessDetail['name'] ??
                                                          '',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            fontSize: 18,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 2, 0, 0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            (businessDetail[
                                                                        'address'] !=
                                                                    null)
                                                                ? businessDetail[
                                                                        'address']
                                                                    ['building']
                                                                : 'N/A',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize: 14,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 6, 0, 0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.timer_sharp,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            size: 18,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        2,
                                                                        0,
                                                                        0,
                                                                        0),
                                                            child: Text(
                                                              '${businessDetail['distance_time'] ?? ''} - ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            businessDetail[
                                                                    'distance'] ??
                                                                '',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          height: 0,
                                          thickness: 1,
                                          color: Color(0xFFC7C7C7),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: () {
                                                  dialNumber(businessDetail[
                                                      'phone_number']);
                                                },
                                                text: 'Call',
                                                options: FFButtonOptions(
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          16, 0, 16, 0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0, 0, 0, 0),
                                                  color: Colors.white,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            'Inter Tight',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  elevation: 0,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  12)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 40,
                                              child: VerticalDivider(
                                                thickness: 1,
                                                color: Color(0xFFC7C7C7),
                                              ),
                                            ),
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: () {
                                                  sendSMS(
                                                      '+91${businessDetail['phone_number']}');
                                                },
                                                text: 'Message',
                                                options: FFButtonOptions(
                                                  height: 40,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(16, 0, 16, 0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0, 0, 0, 0),
                                                  color: Colors.white,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            'Inter Tight',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  elevation: 0,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                   /* Align(
                                      alignment: AlignmentDirectional(1, -1),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF279D33),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(0),
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(8, 3, 5, 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '4.0',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          fontSize: 14,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(2, 0, 0, 0),
                                                child: Icon(
                                                  Icons.star_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Select service',
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
                                  EdgeInsetsDirectional.fromSTEB(20, 5, 20, 0),
                              child: Builder(
                                builder: (context) {
                                  final services =
                                      serviceList.toList(growable: true) ?? [];

                                  if (isLoading) {
                                    return Center(
                                      child: loading(context),
                                    );
                                  }

                                  if (!isLoading && serviceList.isEmpty) {
                                    return Center(
                                      child: emptyList(),
                                    );
                                  }

                                  return GridView.builder(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1,
                                    ),
                                    scrollDirection: Axis.vertical,
                                    itemCount: services.length,
                                    itemBuilder: (context, serviceListIndex) {
                                      final serviceListItem =
                                          services[serviceListIndex];
                                      log('service: $serviceListItem');
                                      final serviceId = serviceListItem['service_id'];
                                      bool isDisable = serviceListItem['is_disabled'];
                                      return Opacity(opacity: (isDisable)? 0.5 : 1, child: GestureDetector(
                                          onTap: () {
                                            if(!isDisable){
                                            setState(() {
                                              if (selectedServiceIndex.contains(serviceId)) {
                                                selectedServiceIndex.remove(serviceId);
                                                selectedServiceData.removeWhere((item) => item['service_id'] == serviceId);
                                              } else {
                                                selectedServiceIndex.add(serviceId);
                                                selectedServiceData.add(serviceListItem);
                                              }
                                            });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: selectedServiceIndex
                                                          .contains(
                                                      serviceId)
                                                      ? 2
                                                      : 1,
                                                  color:
                                                      (selectedServiceIndex
                                                              .contains(
                                                          serviceId))
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .accent3),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width: 35,
                                                    height: 35,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/man-hair.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 9, 0, 0),
                                                    child: Text(
                                                      serviceListItem[
                                                          'service_name'],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            fontSize: 16,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ),
                                                  if (serviceListItem[
                                                          'max_price'] !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 0),
                                                      child: Text(
                                                        '₹ ${serviceListItem['max_price']}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ),

                                                ],
                                              ),
                                            ),
                                          )));
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 20),
                      child: FFButtonWidget(
                          onPressed: () {
                            String date;
                            if (widget.date == null) {
                              // Fallback to today's date
                              final now = DateTime.now();
                              date = DateFormat('yyyy-MM-dd').format(now);
                            } else {
                              final selectDateJson = jsonDecode(widget.date);
                              date =
                                  '${selectDateJson['year']}-${getMonthNumber(selectDateJson['month'])}-${selectDateJson['date'].toString().padLeft(2, '0')}';
                            }
                            log('date select: $date');
                            if (selectedServiceData.isNotEmpty) {
                              log('services: $selectedServiceData');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FixAppointmentWidget(
                                            services: selectedServiceData,
                                            date: date,
                                            uuid: (appointeeUUID != '')
                                                ? appointeeUUID
                                                : FFAppState().userId,
                                          )));
                            } else {
                              Fluttertoast.showToast(msg: 'Select service');
                            }
                          },
                          text: 'Next',
                          options: buttonStyle(context)),
                    ),
                  ],
                ),
            ])),
      ),
    );
  }
}
