import 'dart:developer';

import 'package:eqlite/BusinessPage/businessWidget.dart';
import 'package:eqlite/function.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class AppointmentDayWidget extends StatefulWidget {
  const AppointmentDayWidget({super.key});

  @override
  State<AppointmentDayWidget> createState() => _AppointmentDayWidgetState();
}

class _AppointmentDayWidgetState extends State<AppointmentDayWidget> {

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  int day = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

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
      child: Column(
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
                  height: 6,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
      const Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [ Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
            child:  Text('Select appointment day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),]),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: daySelect('Today', 0)
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
            child: daySelect('Tomorrow', 1)
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 25, 20, 20),
            child: FFButtonWidget(
              onPressed: () {
                log('save data');
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> BusinessPageWidget()));
              },
              text: 'Save',
              options: buttonStyle(context)
            ),
          ),
        ],
      ),
    );
  }

  Widget daySelect(String label, int value){
    return GestureDetector( onTap: (){
      setState(() {
        day = value;
      });
    }, child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: (day == value)? Colors.teal : Colors.transparent,
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional(0, 0),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Inter',
              fontSize: 16,
              letterSpacing: 0.0,
              color: (day == value)? Colors.white: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ));
  }
}
