import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key, required this.backButton});
  final bool backButton;
  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());

    _model.yourNameTextController1 ??= TextEditingController(text: FFAppState().user['full_name']??'');
    _model.yourNameFocusNode1 ??= FocusNode();

    _model.mobileTextController2 ??= TextEditingController(text: FFAppState().phone);
    _model.mobileFocusNode2 ??= FocusNode();

    _model.emailTextController3 ??= TextEditingController(text: FFAppState().user['email']??'');
    _model.emailFocusNode3 ??= FocusNode();

    _model.dobTextController4 ??= TextEditingController();
    _model.dobFocusNode4 ??= FocusNode();

    imageUrl = 'http://15.206.84.199/shared/${FFAppState().user['profile_picture']}';

    genderSelected = (FFAppState().user['gender'] == 'Male' || FFAppState().user['gender'] == 1)? 1 : (FFAppState().user['gender'] == 'Female' || FFAppState().user['gender'] == 2)? 2 : 3 ;
  }

  int genderSelected = 0;
  String imageUrl = '';

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        centerTitle: !widget.backButton,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        leading: (widget.backButton)? backIcon(context): Container(),
        title: Text(
          (widget.backButton)? 'Profile' : 'New Register',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0.0,
          ),
        ),
        actions: [],
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child:
            SingleChildScrollView( child:
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                      onTap: (){
                        pickImageFile().then((value) async {
                          if(value != null){
                            profileApi(
                              value, 'user/profile-picture').then((value) {
                              log('Response: $value');
                              if(value != null){
                                fetchData('user/me', context)?.then((value) {
                                if(value != null){
                                log('data: $value');
                                if(value['data']!= null){
                                final data = value['data'];
                                setState(() {
                                FFAppState().user = data;
                                FFAppState().userId = data['uuid'];
                                });
                                }}});
                                log('user: ${FFAppState().user}');
                                setState(() {
                                  imageUrl = "http://15.206.84.199/shared/${value['image_url']}";
                                });
                                Future.delayed(Duration(milliseconds: 200)).then((value) {
                                  context.pop();
                                });
                                log('image: $imageUrl');
                              }
                            });
                          }
                        });
                      },
                        child: Stack( children: [ Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Container(
                            width: 90,
                            height: 90,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              imageUrl,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person_rounded, size: 60, color: Colors.white,); // Show fallback image
                              },
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                          SizedBox(height: 105, width: 105, child:
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                ),
                                child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.camera_alt, size: 20, )),
                            ),
                          ))
                        ])
                      )],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _model.yourNameTextController1,
                    focusNode: _model.yourNameFocusNode1,
                    textCapitalization: TextCapitalization.words,
                    obscureText: false,
                    decoration: textInputDecoration(context, 'Your Name'),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
                    validator: _model.yourNameTextController1Validator
                        .asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _model.mobileTextController2,
                    focusNode: _model.mobileFocusNode2,
                    textCapitalization: TextCapitalization.words,
                    obscureText: false,
                    readOnly: true,
                    decoration: textInputDecoration(context, 'Mobile Number'),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black54,
                      letterSpacing: 0.0,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _model.mobileTextController2Validator
                        .asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: _model.emailTextController3,
                    focusNode: _model.emailFocusNode3,
                    obscureText: false,
                    decoration: textInputDecoration(context, 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
                    validator: _model.emailTextController3Validator
                        .asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gender: ', style: TextStyle(fontSize: 16)),
                            gender()
                          ]
                  )
                )),
              ],
            ))),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
              child: FFButtonWidget(
                onPressed: () async{
                  String name = _model.yourNameTextController1!.text.trim();
                  String phone = _model.mobileTextController2!.text.trim();
                  String email = _model.emailTextController3!.text.trim();
                  log('email: ${email.isNotEmpty}');

                  if(name.isNotEmpty) {
                    dynamic callApi = await putData(
                        (email.isNotEmpty)?
                        {
                          "full_name": name,
                          "country_code": "+91",
                          "phone_number": phone,
                          "email": email,
                          "gender": genderSelected
                        } :
                        {
                          "full_name": name,
                          "country_code": "+91",
                          "phone_number": phone,
                          "gender": genderSelected
                        },
                        'user/${FFAppState().userId}');

                    if(callApi != null) {

                      fetchData('user/${FFAppState().userId}', context)?.then((value) {
                        log('value: ${getJsonField(value, r'''$.data''')}');
                        setState(() {
                          FFAppState().user = getJsonField(value, r'''$.data''');
                        });
                      });
                      if(widget.backButton != true){
                        setState(() {
                          FFAppState().fistTimeUser = true;
                        });
                      navigateTo(context, const HomePageWidget());
                      }else{
                        setState(() {
                          FFAppState().fistTimeUser = false;
                        });
                       context.pop();
                      }
                    }
                  }else{
                    Fluttertoast.showToast(msg: 'Please enter your name');
                  }

                },
                text: 'Save',
                options: buttonStyle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget gender(){
    List<String> genderTypes = ['Male', 'Female', 'Other' ];
    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 12,
      spacing: 20,
      children: List.generate(genderTypes.length, (index) {
        return GestureDetector(
            onTap: (){
              setState(() {
                genderSelected = index+1;
              });
              log('gender: ${genderSelected}');
            },
            child: Padding(padding: EdgeInsets.all(8), child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon( (genderSelected == index+1)?
          Icons.radio_button_checked_rounded: Icons.radio_button_off,
          color: FlutterFlowTheme.of(context).primary,
          size: 22,
          ),
          Padding(padding: const EdgeInsets.only(left: 10), child:
          Text(genderTypes[index], style: const TextStyle(fontSize: 16),),)
        ],)));
      }),
    );
  }
}
