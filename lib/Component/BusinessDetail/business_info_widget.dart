import 'dart:developer';

import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../apiFunction.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'business_info_model.dart';
export 'business_info_model.dart';

class BusinessInfoWidget extends StatefulWidget {
  const BusinessInfoWidget({super.key, required this.data});
  final dynamic data;
  @override
  State<BusinessInfoWidget> createState() => _BusinessInfoWidgetState();
}

class _BusinessInfoWidgetState extends State<BusinessInfoWidget> {
  late BusinessInfoModel _model;
  bool showTime = false;
  List<dynamic> scheduleData = [];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    fetchData('business_schedule?entity_type=${widget.data['address']['entity_type']}&entity_id=${widget.data['address']['entity_id']}',
        context)?.then((response){
      log('response: $response');
      setState((){
        scheduleData = response['data'];
      });
    });
    _model = createModel(context, () => BusinessInfoModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int todayIndex = DateTime.now().weekday % 7;
    final todayData = scheduleData.firstWhere(
          (d) => d['day_of_week'] == (todayIndex-1),
      orElse: () => null,
    );

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack( children: [ Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(15, 5, 2, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.data['name'],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                IconButton(onPressed: () {
                  context.pop();
                }, icon: Icon(Icons.close))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
            child: Container(
              width: double.infinity,
              height: 200,
              child: CarouselSlider(
                items: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/seed/791/600',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/seed/437/600',
                      width: 250,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/seed/601/600',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                carouselController: _model.carouselController ??=
                    CarouselSliderController(),
                options: CarouselOptions(
                  initialPage: 1,
                  viewportFraction: 0.8,
                  disableCenter: true,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  enableInfiniteScroll: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: false,
                  onPageChanged: (index, _) =>
                      _model.carouselCurrentIndex = index,
                ),
              ),
            ),
          ),
          Divider(
            thickness: 0.5,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                  child: Text(
                    '${((getJsonField(widget.data, r'''$.address.unit_number''')).toString() != '') ? (getJsonField(widget.data, r'''$.address.unit_number''')).toString() + ', ' : ''}${(getJsonField(widget.data, r'''$.address.building''')).toString()}, ${(getJsonField(widget.data, r'''$.address.street_1''')).toString()}, ${(getJsonField(widget.data, r'''$.address.country''')).toString()}-${(getJsonField(widget.data, r'''$.address.postal_code''')).toString()}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    openGoogleMapSearch( '${((getJsonField(widget.data, r'''$.address.unit_number''')).toString() != '') ? (getJsonField(widget.data, r'''$.address.unit_number''')).toString() + ', ' : ''}${(getJsonField(widget.data, r'''$.address.building''')).toString()}, ${(getJsonField(widget.data, r'''$.address.street_1''')).toString()}, ${(getJsonField(widget.data, r'''$.address.country''')).toString()}-${(getJsonField(widget.data, r'''$.address.postal_code''')).toString()}',);
                  },
                  icon: const Icon(
                    Icons.near_me_rounded,
                    color: Colors.blue,
                  )),
             const SizedBox(
                width: 5,
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                  child: Icon(
                    Icons.access_time,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 20,
                  ),
                ),
              ),
              if (!showTime && scheduleData.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[todayData['day_of_week']],
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                        ),
                        Text(
                          (todayData['is_open'])
                              ? formatTimeRange(
                              todayData['opening_time'],
                              todayData['closing_time'])
                              : 'Closed',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (showTime && scheduleData.isNotEmpty)
                Expanded(
                    child: Column(
                        children: List.generate(scheduleData.length, (index) {
                  final day = scheduleData[index];
                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            days[day['day_of_week']],
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          Text(
                              (day['is_open'])
                                  ? formatTimeRange(day['opening_time'], day['closing_time'])
                                  : 'Closed',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ]),
                  );
                }))),
              IconButton(
                  onPressed: () {
                    setState(() {
                      showTime = !showTime;
                    });
                  },
                  icon: Icon((showTime)
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded))
            ],
          ),
          Divider(
            thickness: 0.5,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),

          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
                    child: Text(
                      'Available Facilities',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                        onTap: (){
                          dialNumber(widget.data[
                          'phone_number']);
                        },
                        child: Container(
                      height: 40,
                         width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: FlutterFlowTheme.of(context).primaryText
                        ),
                        child: Padding(padding: EdgeInsets.all(8), child: Icon(
                      Icons.call_rounded,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 24,
                    )))),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 7, 0, 0),
                      child: Text(
                        'Call',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
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
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 46,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        'WhatsApp',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
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
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 46,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        'Instagram',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
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
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 46,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        'Facebook',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
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
          const SizedBox(
            height: 20,
          )
        ],
      ),

    ]));
  }



  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
}
