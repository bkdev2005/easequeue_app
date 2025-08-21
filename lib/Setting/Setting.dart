import 'package:eqlite/About/About_widget.dart';
import 'package:eqlite/AddressBook/AddressBook_widget.dart';
import 'package:eqlite/Auth/Login/Login_widget.dart';
import 'package:eqlite/FavoriteBusiness/FavoriteBusiness_widget.dart';
import 'package:eqlite/Feedback/Feedback_widget.dart';
import 'package:eqlite/Profile/Profile_widget.dart';
import 'package:eqlite/ScannerQr/Scanner_widget.dart';
import 'package:eqlite/SettingPage/setting_widget.dart';
import 'package:eqlite/YourAppointments/YourAppointments_widget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: appBarWidget(context, 'Setting'),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileWidget(backButton: true,)));
                    },
                    child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow:  const [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(
                            0,
                            1,
                          ),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).accent2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).secondary,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                    (FFAppState().user != null)?
                                  'http://43.204.107.110/shared/${FFAppState().user['profile_picture']}': '',
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person_rounded, size: 40, color: Colors.white,); // Show fallback image
                                  },
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (FFAppState().user != null)?
                                  FFAppState().user['full_name']??'Your Name': 'Your Name',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                    fontFamily: 'Inter Tight',
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 0, 0),
                                  child: Text(
                                    (FFAppState().user != null)?
                                    '+91-${FFAppState().user['phone_number']}': '',
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
                  child: Text(
                    'Account',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Inter',
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                navigatePage('Edit Profile', MaterialPageRoute(builder: (context)=> ProfileWidget(backButton: true,)), Icons.account_circle),
                navigatePage('Your Appointments', MaterialPageRoute(builder: (context)=> YourAppointmentsWidget()), Icons.assignment,),
                navigatePage('Favorite Businesses', MaterialPageRoute(builder: (context)=> const FavoriteBusinessWidget()), Icons.favorite_rounded,),
                // navigatePage('Address Book', MaterialPageRoute(builder: (context)=> const AddressBookWidget()), Icons.share_location_outlined,),
                navigatePage('Settings', MaterialPageRoute(builder: (context)=> const SettingPageWidget()), Icons.settings_rounded,),
                navigatePage('Scan Qr', MaterialPageRoute(builder: (context)=> const ScannerQr()), Icons.qr_code_scanner_rounded,),

                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 0),
                  child: Text(
                    'General',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Inter',
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                navigatePage( 'About', MaterialPageRoute(builder: (context)=> AboutWidget()), Icons.help_outline_rounded,),
                navigatePage( 'Send Feedback', MaterialPageRoute(builder: (context)=> FeedbackWidget()), Icons.feedback_outlined,),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                  child:  GestureDetector(
                    onTap: (){
                     setState(() {
                       FFAppState().token = '';
                       FFAppState().user = null;
                     });
                     Navigator.push(context,
                         MaterialPageRoute(builder: (context)=> LoginWidget()));
                    },
                    child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          color: Color(0x3416202A),
                          offset: Offset(
                            0.0,
                            2,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                      shape: BoxShape.rectangle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                              child: Text(
                                'Logout',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                  color: Colors.red,
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color primaryColor = Color(0xff2a4b49);

  Widget navigatePage(String name, MaterialPageRoute pageRoute, IconData iconData){
    return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, pageRoute).then((value) => setState(() { }));
          },
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 5,
                  color: Color(0x3416202A),
                  offset: Offset(
                    0.0,
                    2,
                  ),
                )
              ],
              borderRadius: BorderRadius.circular(12),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    iconData,
                    color: primaryColor,
                    size: 24,
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                      EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Text(
                        name,
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                          color: primaryColor,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.9, 0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
