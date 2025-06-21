import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:eqlite/Component/Congratulate/congratulation_widget.dart';
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/flutter_flow/flutter_flow_icon_button.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import '../../function.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ConfirmUiWidget extends StatefulWidget {
  const ConfirmUiWidget({super.key, this.response});
  final dynamic response;
  @override
  State<ConfirmUiWidget> createState() => _CongratulationWidgetState();
}

class _CongratulationWidgetState extends State<ConfirmUiWidget> {
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey globalKey = GlobalKey();
  Timer? _timer;
  bool checkTick = false;

  @override
  void initState() {
    super.initState();
    setState((){
      checkTick = true;
    });
    Future.delayed(Duration(seconds: 3)).then((value){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> CongratulationWidget(
        response: widget.response,
      )));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(child: Material(
          child: Container(
              decoration: BoxDecoration(
                color: const Color(0XFFcfffe3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/confirmed.gif')

          ),
        )));
  }
}
