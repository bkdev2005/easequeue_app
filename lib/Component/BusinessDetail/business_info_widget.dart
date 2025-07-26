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
  final List<dynamic> data;
  @override
  State<BusinessInfoWidget> createState() => _BusinessInfoWidgetState();
}

class _BusinessInfoWidgetState extends State<BusinessInfoWidget> {
  late BusinessInfoModel _model;
  bool showTime = false;
  List<dynamic> scheduleData = [];
  dynamic todayData;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    for(int i = 0; i<=widget.data.length; i++){
    for(final data in widget.data){
      if(data['day_of_week'] == i){
        scheduleData.add(data);
      }
    }
    }
    int todayIndex = DateTime.now().weekday;
    todayData = scheduleData.firstWhere(
      (d) =>
          d['day_of_week'] == (((todayIndex - 1) == 7) ? 0 : (todayIndex - 1)),
      orElse: () => null,
    );
    _model = createModel(context, () => BusinessInfoModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Stack(children: [
          Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 15, right: 5),
                      child: Text(
                        'Schedule',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      )),
                  IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Expanded(
                      child: Column(
                          children: List.generate(scheduleData.length, (index) {
                    final day = scheduleData[index];
                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 0, 20, 6),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                days[day['day_of_week']],
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),

                              Text(
                                (day['is_open'])
                                    ? buildOpenHours(day)
                                    : 'Closed',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: (day['is_open'])
                                          ? Colors.black
                                          : Colors.redAccent,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ]),
                        const SizedBox(
                          height: 10,
                        ),
                        if (scheduleData.length - 1 != index) Divider()
                      ]),
                    );
                  }))),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ]));
  }

  String formatTime(String time24) {
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final t = TimeOfDay(hour: hour, minute: minute);
    return t.format(context); // e.g. "9:00 AM"
  }

  String buildOpenHours(Map<String, dynamic> dayData) {
    if (dayData['is_open'] == false) {
      return "Closed";
    }

    String openingTime = formatTime(dayData['opening_time']);
    String closingTime = formatTime(dayData['closing_time']);

    List breaks = dayData['break_times'] ?? [];

    if (breaks.isEmpty) {
      return "$openingTime - $closingTime";
    } else {
      String firstBreakStart = formatTime(breaks[0]['start_break']);
      String firstBreakEnd = formatTime(breaks[0]['end_break']);

      return "$openingTime - $firstBreakStart &\n $firstBreakEnd - $closingTime";
    }
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
