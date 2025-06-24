
import 'dart:developer';

import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/Profile/Profile_widget.dart';
import 'package:eqlite/app_state.dart';
import 'package:eqlite/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../Auth/Login/Login_widget.dart';
import '../apiFunction.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if(FFAppState().token == ''){
       Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginWidget()));
      });
      } else if(FFAppState().token != '' && checkNull(FFAppState().user['full_name']) == false){

        navigateTo(context, ProfileWidget(backButton: false));
      }else{
        final storeToken = await sendData({}, 'store-token/?user_id=${FFAppState().user['uuid']}&token=${FFAppState().fcmToken}').then((response){
          log('response: $response');
        });
        navigateTo(context, HomePageWidget());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Image.asset('assets/images/GOLDEN (2).gif'),)
    );
  }
}
