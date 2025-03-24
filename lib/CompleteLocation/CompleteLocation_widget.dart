import 'dart:developer';

import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';

import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'CompleteLocation_model.dart';


class BusinessCompletelocationWidget extends StatefulWidget {
  const BusinessCompletelocationWidget({super.key, this.location, this.buildingName, this.postalCode, this.latitude, this.longitude, this.address, this.id});
  final String? location;
  final String? buildingName;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final dynamic? address;
  final String? id;

  @override
  State<BusinessCompletelocationWidget> createState() =>
      _BusinessCompletelocationWidgetState();
}

class _BusinessCompletelocationWidgetState
    extends State<BusinessCompletelocationWidget> {
  late BusinessCompletelocationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int addressType = 0;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessCompletelocationModel());

    _model.textController1 ??= TextEditingController(text: (widget.address != null)? widget.address['unit_number']??'': '');
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController(text: (widget.address != null)? widget.address['floor']??'': '');
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController(text: (widget.address != null)? widget.address['building']??'': widget.buildingName);
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController(text: (widget.address != null)? widget.address['postal_code']??'': widget.postalCode);
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController(text: (widget.address != null)? widget.address['street_2']??'': widget.location);
    _model.textFieldFocusNode5 ??= FocusNode();

    if(widget.address != null){
    addressType = widget.address['address_type'] == 'HOME'? 0: widget.address['address_type'] == 'WORK'? 1: 2;
    longitude = widget.address['longitude']?? 0;
    latitude = widget.address['latitude']?? 0;
    }else{
      longitude = widget.longitude?? 0;
      latitude = widget.latitude?? 0;
    }

    log('address: ${widget.address}');
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
          child: Column( children: [
            Expanded(child: SingleChildScrollView( child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Address Details',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(0, 20, 15, 0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              autofocus: false,
                              obscureText: false,
                              decoration: textInputDecoration(context, 'Shop/Plot Number'),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                              keyboardType: TextInputType.text,
                              cursorColor:
                              FlutterFlowTheme.of(context).primaryText,
                              validator: _model.textController1Validator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                            child: TextFormField(
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              autofocus: false,
                              obscureText: false,
                              decoration: textInputDecoration(context, 'Floor'),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                              keyboardType: TextInputType.number,
                              cursorColor:
                              FlutterFlowTheme.of(context).primaryText,
                              validator: _model.textController2Validator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                            child: TextFormField(
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              autofocus: false,
                              textCapitalization: TextCapitalization.sentences,
                              obscureText: false,
                              decoration: textInputDecoration(context, 'Building/Mall/Complex Name'),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.0,
                              ),
                              cursorColor:
                              FlutterFlowTheme.of(context).primaryText,
                              validator: _model.textController3Validator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      child: TextFormField(
                        controller: _model.textController4,
                        focusNode: _model.textFieldFocusNode4,
                        autofocus: false,
                        obscureText: false,
                        decoration:  textInputDecoration(context, 'Pincode'),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          letterSpacing: 0.0,
                        ),
                        keyboardType: TextInputType.number,
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        validator: _model.textController4Validator
                            .asValidator(context),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      child: TextFormField(
                        controller: _model.textController5,
                        focusNode: _model.textFieldFocusNode5,
                        autofocus: false,
                        obscureText: false,
                        decoration:  textInputDecoration(context, 'Complete Address'),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          letterSpacing: 0.0,
                        ),
                        maxLines: null,
                        minLines: 2,
                        keyboardType: TextInputType.streetAddress,
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        validator: _model.textController5Validator
                            .asValidator(context),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Address Type',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Row(children: [
                      Material(
                        borderRadius: BorderRadius.circular(30),
                          elevation: 2,
                          child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  addressType = 0;
                                });
                              },
                              child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: (addressType == 0)? FlutterFlowTheme.of(context).primary: FlutterFlowTheme.of(context).primaryBackground
                        ),
                        child: Padding( 
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text('Home', style: TextStyle(
                            color:  (addressType == 0)? Colors.white : Colors.black,
                            fontSize: 16
                          ),),),
                      ))),
              Padding(padding: EdgeInsets.only(left: 12),
                child: Material(
                        borderRadius: BorderRadius.circular(30),
                          elevation: 2,
                          child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  addressType = 1;
                                });
                              },
                              child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: (addressType == 1)? FlutterFlowTheme.of(context).primary: FlutterFlowTheme.of(context).primaryBackground
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text('Work', style: TextStyle(
                            color:  (addressType == 1)? Colors.white : Colors.black,
                            fontSize: 16
                          ),),),
                      )))),
              Padding(padding: EdgeInsets.only(left: 12),
                child: Material(
                        borderRadius: BorderRadius.circular(30),
                          elevation: 2,
                          child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  addressType = 2;
                                });
                              },
                              child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: (addressType == 2)? FlutterFlowTheme.of(context).primary: FlutterFlowTheme.of(context).primaryBackground
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Text('Other', style: TextStyle(
                            color:  (addressType == 2)? Colors.white : Colors.black,
                            fontSize: 16
                          ),),),
                      )))),

                    ],),
                    )
                  ],
                ),
              ),
            ],
          ))),
            
            Padding(padding: EdgeInsets.only(
                left: 20, right: 20, bottom: 20, top: 10), 
              child: FFButtonWidget(
                text: 'Save',
                onPressed: () async{
                  if(widget.id != null){
                    putData(
                        {
                          "unit_number": _model.textController1.text,
                          "floor": _model.textController2.text,
                          "building": _model.textController3.text,
                          "street_1": _model.textController3.text,
                          "street_2": _model.textController5.text,
                          "city": _model.textController5.text,
                          "district": "string",
                          "state": "string",
                          "postal_code": _model.textController4.text,
                          "country": "India",
                          "address_type": addressType == 0? 'HOME': addressType == 1? 'WORK': 'OTHER',
                          "latitude": latitude.toString(),
                          "longitude": longitude.toString(),
                          "entity_type": "USER",
                          "entity_id": FFAppState().userId
                        }, 'address/${widget.id}').then((value) {
                      context.pop(value);
                      log('value: $value');
                    });
                  }else{
                  sendData(
                      {
                        "unit_number": _model.textController1.text,
                        "floor": _model.textController2.text,
                        "building": _model.textController3.text,
                        "street_1": _model.textController3.text,
                        "street_2": _model.textController5.text,
                        "city": _model.textController5.text,
                        "district": "string",
                        "state": "string",
                        "postal_code": _model.textController4.text,
                        "country": "India",
                        "address_type": addressType == 0? 'HOME': addressType == 1? 'WORK': 'OTHER',
                        "latitude": latitude.toString(),
                        "longitude": longitude.toString(),
                        "entity_type": "USER",
                        "entity_id": FFAppState().userId
                      }, 'address').then((value) {
                        context.pop(value);
                        context.pop(value);
                        log('value: $value');
                  });
                }
                },
                options: buttonStyle(context),
              ),)
          
          ]),
        ),
      ),
    );
  }
}
