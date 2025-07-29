import 'dart:developer';

import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Feedback_model.dart';
export 'Feedback_model.dart';

class FeedbackWidget extends StatefulWidget {
  const FeedbackWidget({super.key});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  late FeedbackModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeedbackModel());

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
        appBar: appBarWidget(context, 'Feedback'),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 0),
                child: TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: false,
                  obscureText: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: textInputDecoration(context, 'About your experience'),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    letterSpacing: 0.0,
                  ),
                  maxLines: null,
                  minLines: 3,
                  cursorColor: FlutterFlowTheme.of(context).primaryText,
                  validator:
                  _model.textControllerValidator.asValidator(context),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 15, 20, 20),
                child: FFButtonWidget(
                  onPressed: () async{
                    final feedback = _model.textController.text.trim();
                    if(feedback.isNotEmpty){
                    sendData(
                       {
                         "user_id": FFAppState().userId,
                         "comment": _model.textController.text
                       }, 'feedback').then((value) {

                         if(value != null){
                           Fluttertoast.showToast(msg: 'Feedback sent successfully.');
                         }
                    });
                    }else{
                      Fluttertoast.showToast(msg: 'Please enter add feedback');
                    }
                  },
                  text: 'Send',
                  options: buttonStyle(context)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
