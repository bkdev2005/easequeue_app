import 'dart:developer';
import 'package:eqlite/flutter_flow/nav/nav.dart';

import '../CompleteLocation/CompleteLocation_widget.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'New_Address_model.dart';


class BusinessLocationWidget extends StatefulWidget {
  const BusinessLocationWidget({super.key});

  @override
  State<BusinessLocationWidget> createState() => _BusinessLocationWidgetState();
}

class _BusinessLocationWidgetState extends State<BusinessLocationWidget> {
  late BusinessLocationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool showLoad = false;
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessLocationModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

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
          title: Text(
            'Location',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
            top: true,
            child: Stack( children: [ Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                  child: TextFormField(
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                      hintText: 'Search location',
                      hintStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF4F4F4),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                    validator:
                    _model.textControllerValidator.asValidator(context),
                  ),
                ),
                Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                    child: GestureDetector( onTap: () async{
                      setState(() {
                        showLoad = true;
                      });
                      List<dynamic>? location = await getLocation();
                      setState(() {
                        showLoad = false;
                      });
                      log('location: $location');
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=> BusinessCompletelocationWidget(
                            buildingName: location?[0]?.first,
                            location: location?[0][1], postalCode: location?[0][2],
                            latitude: location?[1], longitude: location?[2],
                          )));
                    },
                      child: Material( elevation: 2,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                size: 24,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                child: Text(
                                  'Use current location',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
                Padding(padding: EdgeInsets.all(20), child:
                FFButtonWidget(text: 'Add other location',
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=> BusinessCompletelocationWidget()));
                    },
                    options: buttonStyle(context)))
              ],
            ),
              if(showLoad)
                Center(child: loading(context))
            ])),
      ),
    );
  }
}
