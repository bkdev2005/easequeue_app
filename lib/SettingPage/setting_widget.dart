import 'dart:developer';

import 'package:eqlite/Auth/Login/Login_widget.dart';
import 'package:eqlite/SettingPage/setting_model.dart';
import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Component/Confirmation/permissionConfirmation.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class SettingPageWidget extends StatefulWidget {
  const SettingPageWidget({super.key});

  @override
  State<SettingPageWidget> createState() => _SettingPageWidgetState();
}

class _SettingPageWidgetState extends State<SettingPageWidget> {
  late SettingPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: appBarWidget(context, 'Settings'),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: Text(
                      'Choose what notifications you want to receive below and we will update the settings.',
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                value: _model.switchListTileValue1 ??= true,
                onChanged: (newValue) async {
                  safeSetState(() => _model.switchListTileValue1 = newValue!);
                },
                title: Text(
                  'Push Notifications',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Inter',
                    letterSpacing: 0.0,
                    lineHeight: 2,
                  ),
                ),
                subtitle: Text(
                  'Receive Push notifications from our application on a semi regular basis.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: Color(0xFF8B97A2),
                    letterSpacing: 0.0,
                  ),
                ),
                tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                activeColor: FlutterFlowTheme.of(context).primary,
                activeTrackColor: FlutterFlowTheme.of(context).accent2,
                dense: false,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              value: _model.switchListTileValue2 ??= true,
              onChanged: (newValue) async {
                safeSetState(() => _model.switchListTileValue2 = newValue!);
              },
              title: Text(
                'WhatsApp Notifications',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Inter',
                  letterSpacing: 0.0,
                  lineHeight: 2,
                ),
              ),
              subtitle: Text(
                'Receive email notifications from our marketing team about new features.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  color: Color(0xFF8B97A2),
                  letterSpacing: 0.0,
                ),
              ),
              tileColor: FlutterFlowTheme.of(context).secondaryBackground,
              activeColor: FlutterFlowTheme.of(context).primary,
              activeTrackColor: FlutterFlowTheme.of(context).accent2,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            ),
          ),
          const Divider(
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            child: GestureDetector( onTap: (){
              showDialog(context: context, builder: (context) {
                return const ConfirmationWidget(title: 'Delete Account', subtitle: 'Are you sure want to delete this account?',);
              }).then((value) async{
                if(value){
                  await deleteData({}, 'user/${FFAppState().userId}').then((value) {
                    log('response: $value');
                    log('user_id: ${FFAppState().userId}');
                    log('token: ${FFAppState().token}');
                    if(value){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginWidget()));
                    }else{
                      Fluttertoast.showToast(msg: 'Something went wrong');
                    }
                  });
                }
              });
            },  child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 10, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Color(0xFFFF3333),
                        size: 24,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Text(
                        'Delete account',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Color(0xFFFF1313),
                          fontSize: 16,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          Divider(
            thickness: 1,
          ),
        ],
      ),
    );
  }
}
