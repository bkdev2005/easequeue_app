import 'dart:developer';

import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';

import '../../apiFunction.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'AddOtherModel.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddAnotherCustomerWidget extends StatefulWidget {
  const AddAnotherCustomerWidget({super.key});

  @override
  State<AddAnotherCustomerWidget> createState() =>
      _AddAnotherCustomerWidgetState();
}

class _AddAnotherCustomerWidgetState extends State<AddAnotherCustomerWidget> {
  late AddAnotherCustomerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddAnotherCustomerModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
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
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 15, 0, 0),
                child: Text('Enter guest user detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: TextFormField(
              controller: _model.textController1,
              focusNode: _model.textFieldFocusNode1,
              textCapitalization: TextCapitalization.words,
              autofocus: false,
              obscureText: false,
              decoration: textInputDecoration(context, 'Name'),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                fontSize: 16,
                letterSpacing: 0.0,
              ),
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              validator: _model.textController1Validator.asValidator(context),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
            child: TextFormField(
              controller: _model.textController2,
              focusNode: _model.textFieldFocusNode2,
              autofocus: false,
              obscureText: false,
              decoration: textInputDecoration(context, 'Phone number'),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                fontSize: 16,
                letterSpacing: 0.0,
              ),
              keyboardType: TextInputType.phone,
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              validator: _model.textController2Validator.asValidator(context),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 25, 20, 20),
            child: FFButtonWidget(
              onPressed: () {
                final name = _model.textController1.text.trim();
                final phone = _model.textController2.text.trim();
                if(name.isNotEmpty){
                  if(phone.isNotEmpty){
                    if(phone.length == 10){
                sendData(
                {
                  "full_name": name,
                  "country_code": "+91",
                  "phone_number": phone
                }, 'appointee').then((value){
                  if(value != null){
                    log('value: $value');
                    final uuid = value['uuid'];
                    context.pop(value);
                  }else{
                    Fluttertoast.showToast(msg: 'Something went wrong');
                  }
                });
                    }
                    else{
                      Fluttertoast.showToast(msg: 'Please enter correct phone number');
                    }
                  }else{
                    Fluttertoast.showToast(msg: 'Please enter phone number');
                  }
                }else{
                  Fluttertoast.showToast(msg: 'Please enter name');
                }
              },
              text: 'Save',
              options: buttonStyle(context)
            ),
          ),
        ],
      ),
    );
  }
}
