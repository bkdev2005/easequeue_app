import 'dart:developer';
import 'package:eqlite/ServicePage/service_model.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../Component/BusinessDetail/business_info_widget.dart';
import '../Component/rating_dailog.dart';
import '../FixAppointment/fix_Appointment_Widget.dart';
import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class AddServicePageWidget extends StatefulWidget {
  const AddServicePageWidget(
      {super.key, this.businessId, this.lat, this.long, this.rescheduleData});
  final String? lat;
  final String? long;
  final String? businessId;
  final dynamic rescheduleData;
  @override
  State<AddServicePageWidget> createState() => _AddServicePageWidgetState();
}

class _AddServicePageWidgetState extends State<AddServicePageWidget> {
  late AddServicePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic businessDetail;
  String businessAddress = '';
  int selectedDateIndex = 0;
  dynamic selectDay;
  String? lat;
  String? long;
  String finalDate = '';
  List<dynamic> next7Days = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddServicePageModel());

    next7Days = getNext7DaysAsMap();
    if (widget.rescheduleData != null) {
      setState(() {
        selectDay =
            jsonDecode(formattedDate(widget.rescheduleData['queue_date']));
      });
      log('select day: $selectDay');
    } else {
      setState(() {
        selectDay = jsonDecode(next7Days.first);
      });
    }
    changeDate();
    if (widget.lat != null && widget.long != null) {
      setState(() {
        lat = widget.lat;
        long = widget.long;
      });
      initBusinessData();
    } else {
      getLocation().then((value) {
        log('location: ${value?[1]}, ${value?[2]}');
        lat = value?[1].toString();
        long = value?[2].toString();
      });
      initBusinessData();
    }
  }

  void initBusinessData() {
    setState(() => isLoading = true);
    fetchData(
            'business/${widget.businessId}?filter_date=$finalDate&user_location=$lat&user_location=$long',
            context)
        ?.then((value) {
      if (value != null) {
        log('business: $value');
        setState(() {
          businessDetail = value['data'];
          socialLinks = businessDetail['social_links'];
        });
        log('social Media: $socialLinks');
        setState(() {
          businessAddress =
              '${getJsonField(businessDetail, r'''$.address.unit_number''') != '' ? '${getJsonField(businessDetail, r'''$.address.unit_number''')}, ' : ''}'
              '${getJsonField(businessDetail, r'''$.address.building''')}, '
              '${getJsonField(businessDetail, r'''$.address.street_1''')}, '
              '${getJsonField(businessDetail, r'''$.address.country''')}-'
              '${getJsonField(businessDetail, r'''$.address.postal_code''')}';
          isLoading = true;
        });
        loadInitialDataFromWidget();
      } else {
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: 'Something went wrong');
      }
    });
  }

  void loadServices(String uuid, {String? date}) {
    final query = date != null
        ? 'business/$uuid/services?page=1&page_size=20&queue_date=$date'
        : 'business/$uuid/services?page=1&page_size=20';

    fetchData(query, context)?.then((value) {
      setState(() {
        serviceList =
            getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
      });

      if (selectedServiceIndex.isEmpty && widget.rescheduleData == null) {
        for (final service in serviceList) {
          if (!service['is_disabled']) {
            setState(() {
              selectedServiceIndex.add(service['service_id']);
              selectedServiceData.add(service);
            });
            break;
          }
        }
      } else if (widget.rescheduleData != null) {
        setState(() {
          selectedServiceIndex =
              (widget.rescheduleData['queue_services_ids']).toList();
        });
        for (final service in serviceList) {
          for (final id in selectedServiceIndex) {
            if (!service['is_disabled'] && service['service_id'] == id) {
              setState(() {
                selectedServiceData.add(service);
              });
            }
          }
        }
        log('selected services: $selectedServiceData');
      }
      setState(() => isLoading = false);
      log('Service: $value');
    });
  }

  void changeDate() {
    final decodedDate = (selectDay);
    log('date: $decodedDate');
    setState(() {
      finalDate =
          '${decodedDate['year']}-${getMonthNumber(decodedDate['month'])}-${decodedDate['date'].toString().padLeft(2, '0')}';
      appointmentDate = decodedDate;
      formatAppointmentDate =
          '${decodedDate['day']}, ${decodedDate['date'].toString().padLeft(2, '0')} ${decodedDate['month']}';
    });
  }

  void loadInitialDataFromWidget() {
    loadServices(businessDetail['uuid'], date: finalDate);
    loadSchedule();
    loadReviews();
    setMapData();
    // if(widget.rescheduleData != null){
    //   selectedServiceIndex = (widget.rescheduleData['queue_services_ids']);
    //   log('selectedService: $selectedServiceIndex');
    // }
  }

  void loadSchedule() {
    fetchData(
      'business_schedule?entity_type=${businessDetail['address']['entity_type']}&entity_id=${businessDetail['address']['entity_id']}',
      context,
    )?.then((response) {
      log('response schedule: ${response['data']}');
      setState(() {
        scheduleData = response['data'];
      });
    });
  }

  void loadReviews() {
    fetchData(
      'reviews/summary?business_id=${businessDetail['uuid']}',
      context,
    )?.then((response) {
      log('response: $response');
      setState(() {
        ratingData = response['data'];
      });
    });
  }

  void setMapData() {
    final lng = getJsonField(businessDetail, r'''$.address.longitude''');
    final lat = getJsonField(businessDetail, r'''$.address.latitude''');
    mapURL =
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/pin-s+ff0000($lng,$lat)/$lng,$lat,14/800x200'
        '?access_token=pk.eyJ1IjoibWtzdXRoYXI5MDE2IiwiYSI6ImNtOWs0dXk0ZzA5cDAya3Bod2I2b2FsZXAifQ.F4-QtkZ1sOj2LpjXuMNJeA';
  }

  dynamic ratingData;
  String mapURL = '';
  bool isAddedFav = false;
  List<dynamic> scheduleData = [];
  List<dynamic> socialLinks = [];
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
          backgroundColor: Color(0xFF37625A),
          automaticallyImplyLeading: false,
          leading: backIcon(context),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                /* FlutterFlowIconButton(
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
                      "business_id": widget.businessId
                    }, 'favourite')
                        .then((value) {
                      setState(() {
                        isAddedFav = !isAddedFav;
                      });
                    });
                  },
                ),*/
                // FlutterFlowIconButton(
                //   borderRadius: 40,
                //   icon: Icon(
                //     Icons.star_rate_sharp,
                //     color: FlutterFlowTheme.of(context).primaryBackground,
                //     size: 24,
                //   ),
                //   onPressed: () {
                //     showDialog(
                //       context: context,
                //       builder: (context) => BusinessRatingDialog(
                //         businessId: widget.businessId!,
                //       ),
                //     );
                //   },
                // ),
                // const SizedBox(
                //   width: 6,
                // ),
                // FlutterFlowIconButton(
                //   borderRadius: 40,
                //   icon: Icon(
                //     Icons.share_rounded,
                //     color: FlutterFlowTheme.of(context).primaryBackground,
                //     size: 24,
                //   ),
                //   onPressed: () async {
                //     final String placeName =
                //         Uri.encodeComponent(businessDetail['name']);
                //     final String googleMapsUrl =
                //         "${businessDetail['name']}\nhttps://www.google.com/maps/search/?api=1&query=$placeName";
                //     Share.share(googleMapsUrl);
                //   },
                // ),
                // const SizedBox(
                //   width: 15,
                // )
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
                        child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                  ),
                                  color: FlutterFlowTheme.of(context).primary),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    15, 10, 15, 18),
                                child: Column(children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
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
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(14, 12, 12, 12),
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
                                                        const EdgeInsetsDirectional
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
                                                                businessDetail[
                                                                        'price_range'] ??
                                                                    '',
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
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  if (ratingData != null)
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
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                (ratingData['average_rating'] ==
                                                                        0.0)
                                                                    ? 'New'
                                                                    : ratingData[
                                                                        'average_rating'],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
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
                                                                  (((ratingData != null)
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
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        '${ratingData['total_ratings']} ratings',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black45,
                                                            fontFamily: 'Inter',
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
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
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          child:
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
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: BusinessInfoWidget(
                                                                                data: scheduleData,
                                                                              ));
                                                                        });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          8,
                                                                          0),
                                                                      child: Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Text((businessDetail['status'].toString().toLowerCase() == 'closed') ? 'Closed' : 'Open',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontSize: 12,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: (businessDetail['status'].toString().toLowerCase() != 'closed') ? Colors.green : Colors.redAccent,
                                                                                      fontFamily: 'Inter',
                                                                                      letterSpacing: 0.0,
                                                                                    )),
                                                                            Expanded(
                                                                                child: Text(' • ${businessDetail['status_message']}',
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontSize: 12,
                                                                                          fontWeight: FontWeight.w400,
                                                                                          color: Colors.black45,
                                                                                          fontFamily: 'Inter',
                                                                                          letterSpacing: 0.0,
                                                                                        ))),
                                                                            const Icon(
                                                                              Icons.keyboard_arrow_down_rounded,
                                                                              size: 18,
                                                                            )
                                                                          ]),
                                                                    ),
                                                                  ))),
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
                                                                  const EdgeInsets
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
                                                                  const EdgeInsets
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
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Text(
                                      "When are you visiting?",
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    )),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 90,
                                  child: ListView(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    scrollDirection: Axis.horizontal,
                                    children: List.generate(next7Days.length,
                                        (index) {
                                      final day = jsonDecode(next7Days[index]);
                                      final isSelected = (day.toString() ==
                                          selectDay.toString());
                                      final isToday = index == 0;
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              right:
                                                  index == next7Days.length - 1
                                                      ? 0
                                                      : 12),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectDay = day;
                                                selectedDateIndex = index;
                                                selectedServiceData.clear();
                                                selectedServiceIndex.clear();
                                              });
                                              changeDate();
                                              loadServices(widget.businessId!,
                                                  date: finalDate);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : Colors.grey[400]!,
                                                  width: isSelected ? 2 : 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    day['day'],
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    day['date'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Container(
                                                    width: 40,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      day['month'],
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                    }),
                                  ),
                                )
                              ]),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                15, 20, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "Which service do you want?",
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                15, 18, 15, 20),
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
                                                        if (widget
                                                                .rescheduleData ==
                                                            null) {
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
                                                                  .add(
                                                                      serviceId);
                                                              selectedServiceData
                                                                  .add(
                                                                      serviceListItem);
                                                            }
                                                          });
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'You can change only date and time not service in reschedule.');
                                                        }
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
                                                                .circular(16),
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
                                                                  const BoxDecoration(
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
                                                                  const EdgeInsetsDirectional
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
                                                                    const EdgeInsetsDirectional
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
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                15, 0, 15, 0),
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
                                        fontWeight: FontWeight.w600,
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
                                  const EdgeInsets.fromLTRB(15, 16, 15, 20),
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
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                15, 0, 15, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Social Media',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 15, 0, 20),
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
                                          sendWhatsAppMessage(
                                              businessDetail['phone_number']);
                                        },
                                        child: Image.asset(
                                          'assets/images/whatsapp.png',
                                          height: 50,
                                        )),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 6, 0, 0),
                                      child: Text(
                                        'WhatsApp',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
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
                                if (socialLinks.isNotEmpty)
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            launchInstagram(
                                                socialLinks[0]['url']);
                                          },
                                          child: Image.asset(
                                            'assets/images/instagram.png',
                                            height: 50,
                                          )),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 6, 0, 0),
                                        child: Text(
                                          'Instagram',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
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
                                if (socialLinks.length == 2)
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            await launchInstagram(
                                                socialLinks[1]['url']);
                                          },
                                          child: Image.asset(
                                            'assets/images/facebook.png',
                                            height: 50,
                                          )),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 6, 0, 0),
                                        child: Text(
                                          'Facebook',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
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

                              date =
                                  '${selectDay['year']}-${getMonthNumber(selectDay['month'])}-${selectDay['date'].toString().padLeft(2, '0')}';

                              log('date select: $date');
                              log('data: ${{
                                'businessName':
                                businessDetail['name'],
                                'formatDate': formatAppointmentDate,
                                'services': selectedServiceData,
                                'date': date,
                                'rescheduleData':
                                widget.rescheduleData,
                                'uuid': FFAppState().userId,
                              }}');
                              if (selectedServiceData.isNotEmpty) {
                                log('services: $selectedServiceData');
                                context.pushNamed('fixAppointment', queryParameters: {
                                  'businessName':
                                  businessDetail['name'],
                                  'formatDate': formatAppointmentDate,
                                  'services': '${selectedServiceData}',
                                  'date': date,
                                  'rescheduleData':
                                  widget.rescheduleData,
                                  'uuid': FFAppState().userId,
                                });
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
