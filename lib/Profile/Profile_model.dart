import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'profile_widget.dart' show ProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for yourName widget.
  FocusNode? yourNameFocusNode1;
  TextEditingController? yourNameTextController1;
  String? Function(BuildContext, String?)? yourNameTextController1Validator;
  // State field(s) for yourName widget.
  FocusNode? mobileFocusNode2;
  TextEditingController? mobileTextController2;
  String? Function(BuildContext, String?)? mobileTextController2Validator;
  // State field(s) for yourName widget.
  FocusNode? emailFocusNode3;
  TextEditingController? emailTextController3;
  String? Function(BuildContext, String?)? emailTextController3Validator;
  // State field(s) for yourName widget.
  FocusNode? dobFocusNode4;
  TextEditingController? dobTextController4;
  String? Function(BuildContext, String?)? dobTextController4Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yourNameFocusNode1?.dispose();
    yourNameTextController1?.dispose();

    mobileFocusNode2?.dispose();
    mobileTextController2?.dispose();

    emailFocusNode3?.dispose();
    emailTextController3?.dispose();

    dobFocusNode4?.dispose();
    dobTextController4?.dispose();
  }
}
