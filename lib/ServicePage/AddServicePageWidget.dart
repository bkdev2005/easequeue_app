import 'dart:developer';

import 'package:eqlite/Component/AddAnotherPerson/AddOtherWidget.dart';
import 'package:eqlite/ServicePage/service_model.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';

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
  String businessAddress = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddServicePageModel());

    log('selectData: ${widget.businessDetail}');
    businessAddress =
        '${((getJsonField(widget.businessDetail, r'''$.address.unit_number''')).toString() != '') ? (getJsonField(widget.businessDetail, r'''$.address.unit_number''')).toString() + ', ' : ''}${(getJsonField(widget.businessDetail, r'''$.address.building''')).toString()}, ${(getJsonField(widget.businessDetail, r'''$.address.street_1''')).toString()}, ${(getJsonField(widget.businessDetail, r'''$.address.country''')).toString()}-${(getJsonField(widget.businessDetail, r'''$.address.postal_code''')).toString()}';
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
        if (selectedServiceIndex.isEmpty) {
          for (final service in serviceList) {
            if (!service['is_disabled']) {
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
    
    fetchData('reviews/summary?business_id=${widget.businessDetail['uuid']}', context)?.then((response){
      log('response: $response');
      setState(() {
        ratingData = response['data'];
      });
    });
  }

  dynamic ratingData;
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
                FlutterFlowIconButton(
                  borderRadius: 40,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.favorite_border,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
                  onPressed: () async{
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
                ),
                FlutterFlowIconButton(
                  borderRadius: 40,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
                  onPressed: () async{
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
                ),
                FlutterFlowIconButton(
                  borderRadius: 40,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.share_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
                  onPressed: () async{
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
                ),
                const SizedBox(width: 15,)
              ],
            ),
          ],
          centerTitle: false,
          elevation: 0,
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
                        child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(22),
                                    bottomRight: Radius.circular(22),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                  ),
                                  color: FlutterFlowTheme.of(context).primary),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    18, 60, 18, 20),
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
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child:
                                        Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    14, 12, 12, 12),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                 Row(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                   Expanded(child:  Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            businessDetail[
                                                                    'name'] ??
                                                                '',
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize: 22,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 2, 5, 0),
                                                            child:  Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                               Expanded(child: Text(
                                                                  (businessDetail['address'] !=
                                                                          null)
                                                                      ? '${businessDetail['distance_time'] ?? ''} - ' +
                                                                          businessDetail[
                                                                              'distance'] +
                                                                          ' • ' +
                                                                          businessDetail['address']
                                                                              [
                                                                              'street_1'] +
                                                                          ', ' +
                                                                          businessDetail['address']
                                                                              [
                                                                              'city']
                                                                      : 'N/A',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        fontSize:
                                                                            14,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                               )),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    0, 3, 0, 0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  'Service available in ₹100 to ₹500',
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      color: Colors
                                                                          .black45),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                    SizedBox(width: 6,),
                                                    Column(children: [
                                                      Container(
                                                        decoration: const BoxDecoration(
                                                          color: Color(0xFF279D33),
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft:
                                                            Radius.circular(10),
                                                            bottomRight:
                                                            Radius.circular(0),
                                                            topLeft: Radius.circular(0),
                                                            topRight: Radius.circular(8),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8, 4, 5, 4),
                                                          child: Row(
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                (ratingData['average_rating'] == 0.0)? 'New' : ratingData['average_rating'],
                                                                style: FlutterFlowTheme
                                                                    .of(context)
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
                                                                padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    2, 0, 0, 0),
                                                                child: Icon(
                                                                  (((ratingData!= null)? ratingData['average_rating']: 0)> 0)? Icons.star_sharp : Icons.star_border_rounded,
                                                                  color: FlutterFlowTheme
                                                                      .of(context)
                                                                      .primaryBackground,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                       Text(
                                                        '${ratingData['total_ratings']} ratings',
                                                        style: const TextStyle(
                                                            color: Colors.black45,
                                                            fontFamily: 'Inter',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500),
                                                      )
                                                    ]),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 8, 0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Open ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              'till 11:30 PM',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black45,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              size: 16,
                                                              color: Colors
                                                                  .black45,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          openGoogleMapSearch(
                                                            businessAddress
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Icon(
                                                              Icons
                                                                  .directions_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        )),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          dialNumber(
                                                              businessDetail[
                                                                  'phone_number']);
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Icon(
                                                              Icons
                                                                  .wifi_calling_3_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            )),



                                  ),
                                ),
                              )),
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
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
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

                                return Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                        runSpacing: 10,
                                        spacing: 10,
                                        children: List.generate(
                                          services.length,
                                          (categoryListIndex) {
                                            final serviceListItem =
                                                services[categoryListIndex];
                                            final serviceId =
                                                serviceListItem['service_id'];
                                            bool isDisable =
                                                serviceListItem['is_disabled'];
                                            return Opacity(
                                                opacity: (isDisable) ? 0.5 : 1,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      if (!isDisable) {
                                                        setState(() {
                                                          if (selectedServiceIndex
                                                              .contains(
                                                                  serviceId)) {
                                                            selectedServiceIndex
                                                                .remove(
                                                                    serviceId);
                                                            selectedServiceData
                                                                .removeWhere((item) =>
                                                                    item[
                                                                        'service_id'] ==
                                                                    serviceId);
                                                          } else {
                                                            selectedServiceIndex
                                                                .add(serviceId);
                                                            selectedServiceData.add(
                                                                serviceListItem);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3) -
                                                          20,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            width:
                                                                selectedServiceIndex
                                                                        .contains(
                                                                            serviceId)
                                                                    ? 2
                                                                    : 1,
                                                            color: (selectedServiceIndex
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
                                                        padding:
                                                            EdgeInsets.all(14),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Container(
                                                              width: 35,
                                                              height: 35,
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/man-hair.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0,
                                                                          9,
                                                                          0,
                                                                          0),
                                                              child: Text(
                                                                serviceListItem[
                                                                    'service_name'],
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          16,
                                                                      letterSpacing:
                                                                          0.0,
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
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  '₹ ${serviceListItem['max_price']}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontSize:
                                                                            12,
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
                                        )));
                              },
                            ),
                          ),
                          Divider(
                            indent: 20, endIndent: 20,
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Location',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: Column(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                        'https://images.unsplash.com/photo-1619468129361-605ebea04b44?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwzfHxtYXB8ZW58MHx8fHwxNzUxNTYwNDU0fDA&ixlib=rb-4.1.0&q=80&w=1080')),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(businessDetail['distance'] +
                                            ' • $businessAddress')),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          openGoogleMapSearch(
                                            businessAddress
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.directions_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 22,
                                            ),
                                          ),
                                        )),
                                  ],
                                )
                              ]))
                        ],
                      ),
                    )),
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
