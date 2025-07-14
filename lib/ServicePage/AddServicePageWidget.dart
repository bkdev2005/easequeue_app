import 'dart:developer';

import 'package:eqlite/Component/AddAnotherPerson/AddOtherWidget.dart';
import 'package:eqlite/ServicePage/service_model.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../Component/BusinessDetail/business_info_widget.dart';
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

    log('selectData: ${widget.date}');

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
      businessAddress =
          '${((getJsonField(widget.businessDetail, r'''$.address.unit_number''')).toString() != '') ? (getJsonField(widget.businessDetail, r'''$.address.unit_number''')).toString() + ', ' : ''}${(getJsonField(widget.businessDetail, r'''$.address.building''')).toString()}, ${(getJsonField(widget.businessDetail, r'''$.address.street_1''')).toString()}, ${(getJsonField(widget.businessDetail, r'''$.address.country''')).toString()}-${(getJsonField(widget.businessDetail, r'''$.address.postal_code''')).toString()}';

      final finalDate =
          '${jsonDecode(widget.date)['year']}-${getMonthNumber(jsonDecode(widget.date)['month'])}-${jsonDecode(widget.date)['date'].toString().padLeft(2, '0')}';

      fetchData(
              'business/${businessDetail['uuid']}/services?page=1&page_size=20&queue_date=$finalDate',
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

      fetchData(
              'business_schedule?entity_type=${widget.businessDetail['address']['entity_type']}&entity_id=${widget.businessDetail['address']['entity_id']}',
              context)
          ?.then((response) {
        log('response schedule: ${response['data']}');
        setState(() {
          scheduleData = response['data'];
        });
      });
      if (widget.date != null) {
        log('date: ${widget.date}');
        appointmentDate = jsonDecode(widget.date);
        formatAppointmentDate =
            '${appointmentDate['day']}, ${appointmentDate['date'].toString().padLeft(2, '0')} ${(appointmentDate['month'])}';
      } else {
        DateTime now = DateTime.now();

        String formattedDate = '${DateFormat('EEE').format(now)}, '
            '${now.day.toString().padLeft(2, '0')} '
            '${DateFormat('MMM').format(now)}';
        formatAppointmentDate = formattedDate;
      }

      fetchData('reviews/summary?business_id=${widget.businessDetail['uuid']}',
              context)
          ?.then((response) {
        log('response: $response');
        setState(() {
          ratingData = response['data'];
        });
      });

      isAddedFav = widget.businessDetail['is_favourite'] ?? false;
      mapURL = 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/'
          'pin-s+ff0000(${(getJsonField(widget.businessDetail, r'''$.address.longitude'''))},${(getJsonField(widget.businessDetail, r'''$.address.latitude'''))})/' // note: Mapbox uses LONG,LAT
          '${(getJsonField(widget.businessDetail, r'''$.address.longitude'''))},${(getJsonField(widget.businessDetail, r'''$.address.latitude'''))},14/800x200'
          '?access_token=pk.eyJ1IjoibWtzdXRoYXI5MDE2IiwiYSI6ImNtOWs0dXk0ZzA5cDAya3Bod2I2b2FsZXAifQ.F4-QtkZ1sOj2LpjXuMNJeA';
    }
  }

  dynamic ratingData;
  String mapURL = '';
  bool isAddedFav = false;
  List<dynamic> scheduleData = [];
  dynamic appointmentDate;
  String formatAppointmentDate = '';
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
                    (isAddedFav)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
                  onPressed: () async {
                    await sendData({
                      "user_id": FFAppState().userId,
                      "business_id": widget.businessDetail['uuid']
                    }, 'favourite')
                        .then((value) {
                      setState(() {
                        isAddedFav = !isAddedFav;
                      });
                    });
                  },
                ),
                const SizedBox(
                  width: 6,
                ),
                FlutterFlowIconButton(
                  borderRadius: 40,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
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
                ),
                const SizedBox(
                  width: 6,
                ),
                FlutterFlowIconButton(
                  borderRadius: 40,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.share_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24,
                  ),
                  onPressed: () async {
                    final String placeName = Uri.encodeComponent(businessDetail[
                    'name']);
                    final String googleMapsUrl = "${businessDetail['name']}\nhttps://www.google.com/maps/search/?api=1&query=$placeName";
                    Share.share(googleMapsUrl);
                  },
                ),
                const SizedBox(
                  width: 15,
                )
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
                                    18, 35, 18, 20),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        formatAppointmentDate,
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Material(
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
                                      child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  14, 12, 12, 12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                      child: Padding(
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
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                '${businessDetail['distance_time'] ?? ''}'
                                                                '${(businessDetail['distance_time'] != null && businessDetail['distance'] != null) ? ' - ' : ''}'
                                                                '${businessDetail['distance'] ?? ''}'
                                                                '${(businessDetail['address'] != null) ? ' • ${businessDetail['address']?['street_1'] ?? ''}, ${businessDetail['address']?['city'] ?? ''}' : ''}',
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
                                                        /* Padding(
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
                                                          ),*/
                                                      ],
                                                    ),
                                                  )),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Column(children: [
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFF279D33),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  0),
                                                          topLeft:
                                                              Radius.circular(
                                                                  0),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                8, 4, 5, 4),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              (ratingData['average_rating'] ==
                                                                      0.0)
                                                                  ? 'New'
                                                                  : ratingData[
                                                                      'average_rating'],
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    fontSize:
                                                                        14,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      2,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Icon(
                                                                (((ratingData !=
                                                                                null)
                                                                            ? ratingData[
                                                                                'average_rating']
                                                                            : 0) >
                                                                        0)
                                                                    ? Icons
                                                                        .star_sharp
                                                                    : Icons
                                                                        .star_border_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  ]),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Wrap(
                                                    runSpacing: 8,
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          BusinessInfoWidget(
                                                                        data:
                                                                            scheduleData,
                                                                      ));
                                                                });
                                                          },
                                                          child: Container(
                                                            height: 35,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Colors
                                                                  .grey[200],
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          8,
                                                                          0),
                                                              child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                        '${businessDetail['status']}',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: (businessDetail['status'] != 'Closed') ? Colors.green : Colors.redAccent,
                                                                              fontFamily: 'Inter',
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                    Text(
                                                                        ' • ${businessDetail['status_message']}',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black45,
                                                                              fontFamily: 'Inter',
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                    Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      size: 14,
                                                                    )
                                                                  ]),
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            openGoogleMapSearch(
                                                                businessAddress);
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
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Icon(
                                                                Icons
                                                                    .directions_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
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
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Icon(
                                                                Icons
                                                                    .wifi_calling_3_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 22,
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ),
                                ]),
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
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3) -
                                                            20,
                                                      ),
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
                          const Divider(
                            indent: 20,
                            endIndent: 20,
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
                              padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
                              child: Column(children: [
                                GestureDetector(
                                    onTap: () {
                                      openGoogleMapSearch(businessAddress);
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        height: 150,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              mapURL,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  // Finished loading, show the image
                                                  return child;
                                                }
                                                // While loading, show a circular progress indicator
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  width: double.infinity,
                                                  height: 150,
                                                  alignment: Alignment.center,
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.location_on,
                                                          color: Colors.red,
                                                          size: 40),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Failed to load map',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )))),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            (businessDetail['distance'] ?? '') +
                                                ' • $businessAddress')),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          openGoogleMapSearch(businessAddress);
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
                              ])),
                          const Divider(
                            indent: 20,
                            endIndent: 20,
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Contact',
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
                            padding:
                                EdgeInsetsDirectional.fromSTEB(5, 10, 0, 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          dialNumber(widget
                                              .businessDetail['phone_number']);
                                        },
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText),
                                            child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.call_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 24,
                                                )))),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 7, 0, 0),
                                      child: Text(
                                        'Call',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.whatsappSquare,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 46,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 5, 0, 0),
                                      child: Text(
                                        'WhatsApp',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.instagramSquare,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 46,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 5, 0, 0),
                                      child: Text(
                                        'Instagram',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.facebookSquare,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 46,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 5, 0, 0),
                                      child: Text(
                                        'Facebook',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                                  .divide(SizedBox(width: 20))
                                  .addToStart(SizedBox(width: 15))
                                  .addToEnd(SizedBox(width: 15)),
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (selectedServiceData.isNotEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
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
                                              formatDate: formatAppointmentDate,
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
