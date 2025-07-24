import 'dart:developer';

import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../ServicePage/AddServicePageWidget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'globaSearch_model.dart';


class GlobalSearchWidget extends StatefulWidget {
  const GlobalSearchWidget({super.key});

  static String routeName = 'globalSearch';
  static String routePath = '/globalSearch';

  @override
  State<GlobalSearchWidget> createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends State<GlobalSearchWidget> {
  late GlobalSearchModel _model;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> businessList = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GlobalSearchModel());
    _speech = stt.SpeechToText();
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  void toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            _model.textController = TextEditingController(text: result.recognizedWords);
          });
          fetchData('search?search_str=${result.recognizedWords}', context)?.then((value) {
            log('response: $value');
            setState(() {
              businessList = getJsonField(value, r'''$.data[:]''', true);
            });
          });
        });

      }
    }
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
          toolbarHeight: 70,
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child:TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    onChanged: (_) {
                    setState(() {
                      businessList.clear();
                    });
                    fetchData('search?search_str=$_', context)?.then((value) {
                      log('response: $value');
                      if(value != null){
                      setState(() {
                        businessList = getJsonField(value, r'''$.data[:]''', true);
                      });
                      }
                    });
                    if(_.isEmpty){
                      setState(() {
                        businessList.clear();
                      });
                    }
                    },
                    autofocus: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                      hintText: 'Search service or business',
                      hintStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        letterSpacing: 0.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                      contentPadding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 1),
                      prefixIcon: InkWell(
                        onTap: () async {
                         context.pop();
                         },
                        child:Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 24,
                        color: FlutterFlowTheme.of(context).primaryText,
                      )),
                      suffixIcon: _model.textController!.text.isNotEmpty
                          ? GestureDetector(

                        onTap: () async {
                          _model.textController?.clear();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.clear,
                          size: 22,
                        ),
                      )
                          : GestureDetector(
                        onTap: () async {
                          toggleListening();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.mic,
                          size: 22,
                        ),
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
              ],
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child:
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                itemCount: businessList.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final businessItem = businessList[index];
                  return  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddServicePageWidget(
                                  businessDetail: businessItem,
                                  date: null,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 6),
                              padding: const EdgeInsets.fromLTRB(
                                  15, 8, 15, 8),
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding:
                                        EdgeInsets.only(top: 3),
                                        child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                  Colors.black26,
                                                ),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(5)),
                                            child: (businessItem[
                                            'profile_picture'] !=
                                                null)
                                                ? Image.network(
                                              'http://43.204.107.110/shared/${businessItem['profile_picture']}',
                                              fit: BoxFit.cover,
                                            )
                                                : Padding(
                                                padding:
                                                EdgeInsets
                                                    .all(8),
                                                child: Image.asset(
                                                    'assets/images/images.png')))),
                                    // Business Info
                                    Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(left: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                businessItem[
                                                'name'] ??
                                                    'N/A',
                                                style: FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  fontSize: 18,
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                  FontWeight.w500,
                                                ),
                                              ),
                                              if (businessItem[
                                              'address'] !=
                                                  null)
                                                Text(
                                                  businessItem[
                                                  'address']
                                                  ['street_1'] ??
                                                      '',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style:
                                                  FlutterFlowTheme.of(
                                                      context)
                                                      .bodyMedium
                                                      .override(
                                                    fontSize: 14,
                                                    fontFamily:
                                                    'Inter',
                                                    letterSpacing:
                                                    0.0,
                                                  ),
                                                ),
                                              Row(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .max,
                                                  children: [
                                                    Text('${businessItem[
                                                    'status']}',
                                                        style: FlutterFlowTheme.of(
                                                            context)
                                                            .bodyMedium
                                                            .override(
                                                          fontSize:
                                                          12,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          color: (businessItem[
                                                          'status'] != 'Closed')? Colors.green :
                                                          Colors.redAccent,
                                                          fontFamily:
                                                          'Inter',
                                                          letterSpacing:
                                                          0.0,
                                                        )),
                                                    Expanded(child: Text(' • ${businessItem[
                                                    'status_message']}',
                                                        style: FlutterFlowTheme.of(
                                                            context)
                                                            .bodyMedium
                                                            .override(
                                                          fontSize:
                                                          12,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          color:
                                                          Colors.black45,
                                                          fontFamily:
                                                          'Inter',
                                                          letterSpacing:
                                                          0.0,
                                                        )),
                                                    )]),
                                            ],
                                          ),
                                        )),


                                    // Info Icon
                                    // const Icon(Icons.info_outline_rounded, color: Colors.black54, size: 20,),

                                  ])),
                        ),
                      ));
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme
                            .of(context)
                            .secondaryBackground,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://picsum.photos/seed/577/600',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service name',
                                    style: FlutterFlowTheme
                                        .of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 3, 0, 0),
                                    child: Text(
                                      'See all business',
                                      style: FlutterFlowTheme
                                          .of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }))
            ],
          ),
        ),
      ),
    );
  }
}
